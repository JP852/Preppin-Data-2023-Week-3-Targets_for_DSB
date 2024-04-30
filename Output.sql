-- For the transactions file:
    -- Filter the transactions to just look at DSB (help)
        -- These will be transactions that contain DSB in the Transaction Code field
    -- Rename the values in the Online or In-person field, Online of the 1 values and In-Person for the 2 values
    -- Change the date to be the quarter (help)
    -- Sum the transaction values for each quarter and for each Type of Transaction (Online or In-Person) (help)
-- For the targets file:
    -- Pivot the quarterly targets so we have a row for each Type of Transaction and each Quarter (help)
    -- Rename the fields
    -- Remove the 'Q' from the quarter field and make the data type numeric (help)
-- Join the two datasets together (help)
    -- You may need more than one join clause!
-- Remove unnecessary fields
-- Calculate the Variance to Target for each row 

WITH CTE AS (
SELECT
SUM(VALUE) AS TOTAL_VALUE
,CASE WHEN ONLINE_OR_IN_PERSON = '1' THEN 'Online' ELSE 'In-Person' END AS ONLINE_OR_IN_PERSON
,QUARTER(DATE(transaction_date,'dd/MM/yyyy HH24:MI:SS')) AS QUARTER
FROM PD2023_WK01 AS CTE
WHERE LEFT(transaction_code,3) = 'DSB'
GROUP BY 
CASE WHEN ONLINE_OR_IN_PERSON = '1' THEN 'Online' ELSE 'In-Person' END
,QUARTER(DATE(transaction_date,'dd/MM/yyyy HH24:MI:SS'))
)

SELECT T.online_or_in_person
,RIGHT(T.quarter,1)::int AS QUARTER
,target
,CTE.TOTAL_VALUE
,CTE.TOTAL_VALUE - T.TARGET AS Variance_to_Target
FROM PD2023_WK03_TARGETS as T
UNPIVOT(target FOR QUARTER IN (Q1,Q2,Q3,Q4))
INNER JOIN CTE AS CTE
ON T.ONLINE_OR_IN_PERSON = CTE.ONLINE_OR_IN_PERSON
AND RIGHT(T.quarter,1)::int = CTE.QUARTER
