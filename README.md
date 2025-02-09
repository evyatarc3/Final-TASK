# README: ניתוח סטטיסטי עבור קישורי ריח-צליל

## סקירה כללית
פרויקט זה מנתח את הקשר בין ריחות לתפיסת צלילים. התהליך כולל עיבוד מקדים, חישוב סטטיסטיקות תיאוריות, ביצוע רגרסיות ויצירת ויזואליזציות ומדדים מתקדמים כמו עקומת ROC.

---

## נתונים ומבנה
- **קובץ נתונים**: `just data exp1.xlsx`
  - דירוגי צלילים לפי ריח וניסיונות משתתפים.

- **קבצי פלט**:
  - `rating_distribution.png`: גרף התפלגות דירוגי הצלילים.
  - `rating_density_ridges.png`: גרף צפיפות דירוגים.
  - `roc_curve.png`: עקומת ROC לניבוי עקביות.

---

## התקנה
התקנת חבילות הדרושות:
```r
if (!requireNamespace("ggridges", quietly = TRUE)) install.packages("ggridges")
if (!requireNamespace("skimr", quietly = TRUE)) install.packages("skimr")
```

טעינת ספריות:
```r
library(tidyverse)
library(ggplot2)
library(ggdist)
library(pROC)
library(ggridges)
library(skimr)
```

---

## תהליך הניתוח
1. **עיבוד נתונים**:
   - ניקוי וסינון ערכים קיצוניים באמצעות הפונקציה `preprocess_data`.
   
2. **סטטיסטיקה תיאורית**:
   - חישוב סטיית תקן ומדד עקביות יחסי.
   - קיבוץ הנתונים לפי משתתף וריח.

3. **ניתוחים סטטיסטיים**:
   - רגרסיה ליניארית: `rating_z ~ odor`.
   - בדיקת נורמליות (מבחן Shapiro-Wilk).
   - רגרסיה לוגיסטית: `high_consistency ~ odor`.

4. **תחזיות ו-ROC**:
   - חישוב הסתברויות חזויות והפקת עקומת ROC.

5. **ויזואליזציה**:
   - יצירת גרפים להצגת התפלגות הדירוגים וצפיפות הנתונים.
   - שמירת הפלטים בקבצי PNG.

6. **סיכום פלט**:
   - תוצאות הניתוחים והבדיקות מוצגות בסיכום מודפס.

---

## הרצה
1. הנחת קובץ הנתונים (`just data exp1.xlsx`) בתיקיית העבודה.
2. הרצת הסקריפט בסביבת R.
3. הצגת הגרפים וצפייה בתוצאות הסיכום.

---

## דוגמה לפלט
- **גרפים**:
  - ![rating_distribution.png](rating_distribution.png)
  - ![rating_density_ridges.png](rating_density_ridges.png)
  - ![roc_curve.png](roc_curve.png)

- **תוצאות מודפסות**: סיכומי רגרסיות, בדיקת נורמליות וערך ה-AUC.



## מחבר
אביתר כהן

