-- Analyzing Kickstarter Projects (Dataquest guided project)

-- Step 2: Initial Selection of Rows and Columns
SELECT main_category, goal, backers, pledged
FROM ksprojects
LIMIT 10

-- Step 3: Filtering by Category
SELECT main_category, goal, backers, pledged
  FROM ksprojects
  WHERE state IN ( 'failed', 'canceled', 'suspended')
 LIMIT 10;

-- Step 4: Filtering by Quantity
SELECT main_category, backers, pledged, goal
 FROM ksprojects
WHERE state IN ('failed', 'canceled', 'suspended') 
AND backers >= 100 and pledged >= 20000

LIMIT 10;

-- Step 5: Ordering Results
SELECT main_category, backers, pledged, goal, pledged/goal as pct_pledged
  FROM ksprojects
 WHERE state IN ('failed')
   AND backers >= 100 AND pledged >= 20000
   ORDER BY main_category, pct_pledged DESC
 LIMIT 10;

-- Step 6: Applying Conditional Logic
SELECT main_category, backers, pledged, goal, 
       pledged/goal AS pct_pledged,
       CASE
       WHEN pledged/goal  >= 1 THEN "Fully funded"
       WHEN pledged/goal BETWEEN .75 AND 1 THEN "Nearly funded"
       ELSE "Not nearly funded"
       END AS funding_status 
  FROM ksprojects
 WHERE state IN ('failed')
       AND backers >= 100 AND pledged >= 20000
 ORDER BY main_category, pct_pledged DESC
 LIMIT 10;
