# Script: Statistical Analysis
# Author: Evyatar Cohen
# Date: 09/02/2025
# מטרה: ניתוח נתונים עבור קישורי ריח-צליל

# התקנת חבילות בשביל משימת הבונוס
if (!requireNamespace("ggridges", quietly = TRUE)) install.packages("ggridges")
if (!requireNamespace("skimr", quietly = TRUE)) install.packages("skimr")

# טעינת חבילות
library(tidyverse)
library(ggplot2)
library(ggdist)
library(pROC)
library(ggridges)   # הצגת נתונים אחרת - משימת בונוס
library(skimr)      # הצגת נתונים מפורטת - משימת בונוס

# גרף הצגת נתונים מקדימה
initial_exploration_plot <- ggplot(
  processed_data, aes(x = odor, y = rating, fill = odor)
) +
  geom_boxplot() +
  theme_minimal() +
  labs(
    title = "Initial Exploration: Boxplot of Ratings by Odor",
    x = "Odor Type",
    y = "Sound Rating"
  )

# הצגת ושמירת הגרף
print(initial_exploration_plot)
ggsave("initial_exploration.png", initial_exploration_plot, width = 10, height = 6)


# פונקציית עיבוד נתונים
preprocess_data <- function(data) {
  data |> 
    pivot_longer(
      cols = -sub_num, 
      names_to = c("odor", "trial"),
      names_pattern = "(.+)_([123])",
      values_to = "rating"
    ) |> 
    mutate(
      rating_z = (rating - mean(rating, na.rm = TRUE)) / sd(rating, na.rm = TRUE),
      odor = factor(odor),
      trial = factor(trial)
    ) |> 
    filter(rating >= 100 & rating <= 5000)  # ניקוי חריגים
}

# טעינת וניקוי נתונים
raw_data <- readxl::read_excel("just data exp1.xlsx")
processed_data <- preprocess_data(raw_data)

# חישוב עקביות ומדדים תיאוריים
model_data <- processed_data |> 
  group_by(sub_num, odor) |> 
  mutate(
    rating_sd = sd(rating),
    consistency_score = rating_sd / mean(rating)  # מדד עקביות יחסי
  ) |> 
  ungroup() |> 
  mutate(
    # יצירת משתנה דיכוטומי לפי חציון העקביות
    high_consistency = as.factor(ifelse(consistency_score < median(consistency_score, na.rm = TRUE), 1, 0))
  ) |> 
  # הסרת שורות עם NA
  drop_na(high_consistency, rating_z, odor)

# בדיקת נתונים חסרים
missing_data <- colSums(is.na(model_data))
cat("\nMissing Data Summary:\n")
print(missing_data)

# רגרסיה ליניארית
linear_model <- lm(rating_z ~ odor, data = model_data)

# בדיקת נורמליות
shapiro_test <- shapiro.test(residuals(linear_model))

# רגרסיה לוגיסטית
logistic_model <- glm(
  high_consistency ~ odor,
  family = binomial(link = "logit"),
  data = model_data
)

# הוספת הסתברויות חזויות לאותו סט נתונים
model_data <- model_data |> 
  mutate(
    predicted_prob = predict(logistic_model, type = "response")
  )

# יצירת עקומת ROC
roc_obj <- roc(model_data$high_consistency, model_data$predicted_prob)

# גרף התפלגות דירוגים
rating_plot <- ggplot(
  model_data,
  aes(x = odor, y = rating)
) +
  stat_halfeye(
    aes(fill = odor),
    adjust = 0.5,
    width = 0.6,
    .width = c(0.5, 0.95)
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = "none"
  ) +
  labs(
    title = "Distribution of Sound Ratings by Odor",
    x = "Odor Type",
    y = "Sound Rating"
  )

# הצגת וגם שמירת הגרף
print(rating_plot)
ggsave("rating_distribution.png", rating_plot, width = 10, height = 6)

#  גרף צפיפות
ridge_plot <- ggplot(
  model_data, 
  aes(x = rating, y = odor, fill = odor)
) +
  geom_density_ridges() +
  theme_minimal() +
  labs(
    title = "Density Distribution of Sound Ratings by Odor",
    x = "Sound Rating",
    y = "Odor Type"
  )

# הצגת וגם שמירת הגרף
print(ridge_plot)
ggsave("rating_density_ridges.png", ridge_plot, width = 10, height = 6)

# גרף ROC
roc_plot <- ggroc(roc_obj) +
  theme_minimal() +
  labs(
    title = "ROC Curve for Consistency Prediction",
    x = "False Positive Rate",
    y = "True Positive Rate"
  )

# הצגת וגם שמירת הגרף
print(roc_plot)
ggsave("roc_curve.png", roc_plot, width = 8, height = 6)

# הדפסת תוצאות
cat("\nLinear Regression Summary:\n")
print(summary(linear_model))

cat("\nShapiro-Wilk Normality Test:\n")
print(shapiro_test)

cat("\nLogistic Regression Summary:\n")
print(summary(logistic_model))

cat("\nAUC for ROC curve:\n")
print(auc(roc_obj))

# בונוס: סיכום נתונים מפורט
cat("\nDetailed Data Summary (skimr):\n")
print(skim(model_data))
