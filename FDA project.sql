USE fda_data;

#__TASK-1__#

#1): Determine the number of drugs approved each year and provide insights into the yearly trends.
SELECT ActionType, YEAR(ActionDate) AS "Approval_year", COUNT(DISTINCT(ApplNo)) AS "Drugs_approved"
FROM regactiondate WHERE ActionType = "AP"
GROUP BY Approval_year ORDER BY Approval_year DESC;

SELECT ActionType, YEAR(docdate) AS "Approval_year", COUNT(AppDocID) AS "Drugs_Approved"
FROM appdoc WHERE ActionType = "AP"
GROUP BY Approval_year ORDER BY Drugs_Approved DESC;

#______________________________________________________________________________________________________#

#2): Identify the top three years that got the highest and lowest approvals, 
###in descending and ascending order, respectively.

## Top 3 Highest approval
SELECT YEAR(docdate) AS "approval_year", COUNT(AppDocID) AS "num_of_approvals"
FROM appdoc
GROUP BY YEAR(docdate) ORDER BY num_of_approvals DESC LIMIT 3;

SELECT YEAR(actiondate) AS "Approval_Year", COUNT(ApplNo) AS "num_of_approvals"
FROM regactiondate
GROUP BY Approval_Year ORDER BY num_of_approvals DESC LIMIT 3;

## Top 3 Lowest Approval
SELECT YEAR(docdate) AS "approval_year", COUNT(AppDocID) AS "num_approvals"
FROM appdoc
GROUP BY YEAR(docdate) ORDER BY num_approvals ASC LIMIT 3;

SELECT YEAR(actiondate) AS "Approval_Year", COUNT(ApplNo) AS "num_of_approvals"
FROM regactiondate
GROUP BY YEAR(actiondate) ORDER BY num_of_approvals ASC LIMIT 3;

#____________________________________________________________________________________________________#

## 3.): Explore approval trends over the years based on sponsors. 

SELECT YEAR(r.ActionDate) AS "approval_year",a.SponsorApplicant, COUNT(a.Applno) AS "num_approvals"
FROM application AS a INNER JOIN regactiondate AS r ON a.Applno = r.Applno
GROUP BY YEAR(r.ActionDate),SponsorApplicant ORDER BY num_approvals DESC;

SELECT ac.SponsorApplicant, YEAR(docdate) AS "approval_year", COUNT(AppDocID) AS "total_approvals"
FROM appdoc AS a INNER JOIN application AS ac ON a.AppDocID = ac.applno
GROUP BY ac.SponsorApplicant, YEAR(docdate) ORDER BY total_approvals DESC;

## 3.a.) Approvals from other tables
SELECT Actiontype,COUNT(ApplNo) AS "total_approvals"
FROM application GROUP BY ActionType;

SELECT ActionType, COUNT(AppDocID) AS "total_approvals"
FROM appdoc GROUP BY ACtionType;

SELECT ActionType, COUNT(ApplNo) AS "total_approvals"
FROM regactiondate GROUP BY ActionType;

# 3.b.) Sponsors Visualization
SELECT ac.SponsorApplicant AS "Sponsors", COUNT(a.AppDocID) AS "total_approvals"
FROM appdoc AS a INNER JOIN application AS ac ON a.AppDocID = ac.applno
GROUP BY ac.sponsorapplicant ORDER BY total_approvals DESC;

SELECT SponsorApplicant AS "Sponsors", COUNT(ApplNo) AS "total_approvals"
FROM application GROUP BY SponsorApplicant ORDER BY total_approvals DESC;

#__________________________________________________________________________________________________#

#4.): Rank sponsors based on the total number of approvals they received each year between 1939 and 1960.
SELECT a.sponsorapplicant, r.ActionType, YEAR(r.ActionDate) AS "Approval_Year", COUNT(r.ActionType) AS "Total_Approval"
FROM regactiondate AS r INNER JOIN application AS a ON r.ApplNo = a.Applno
WHERE YEAR(r.Actiondate) BETWEEN 1939 AND 1960 AND r.ActionType = "AP"
GROUP BY r.ActionType, Approval_Year, a.sponsorapplicant
ORDER BY Approval_Year ASC;

SELECT approval_year, SponsorApplicant, num_of_approvals,
RANK() OVER (PARTITION BY approval_year ORDER BY num_of_approvals DESC) AS "rank_sponsor"
FROM (SELECT YEAR(r.ActionDate) AS "approval_year", a.SponsorApplicant,COUNT(r.ApplNo) AS "num_of_approvals"
FROM regactiondate AS r INNER JOIN application AS a ON r.ApplNo = a.ApplNo
WHERE YEAR(r.ActionDate) BETWEEN 1939 AND 1960 
GROUP BY YEAR(r.ActionDate), a.SponsorApplicant) AS subquery ORDER BY rank_sponsor ASC;

#==========================================================================================================#
#####
##__TASK-2__##

## 1): Group products based on MarketingStatus. Provide meaningful insights into the segmentation patterns.
SELECT ProductMktStatus, COUNT(ProductNo) AS "ProductCount"
FROM product
GROUP BY ProductMktStatus;

#____________________________________________________________________________________________________#

## 2): Calculate the total number of applications for each MarketingStatus year-wise after the year 2010. 
SELECT YEAR(a.DocDate) AS "Application_Year", p.ProductMktStatus, COUNT(a.AppDocID) AS "Total_Applications"
FROM appdoc AS a INNER JOIN product AS p ON a.ApplNo = p.ApplNo
WHERE YEAR(a.DocDate) > 2010
GROUP BY Application_Year, p.ProductMktStatus ORDER BY Application_Year, p.ProductMktStatus DESC;

SELECT YEAR(r.ActionDate) AS "Application_Year", p.ProductMktStatus, COUNT(r.ApplNo) AS "Total_Application"
FROM regactiondate AS r INNER JOIN product AS p ON r.ApplNo = p.ApplNo
WHERE YEAR(r.ActionDate) > 2010
GROUP BY Application_Year, p.ProductMktStatus ORDER BY Application_Year, p.ProductMktStatus DESC;

#___________________________________________________________________________________________________#

## 3): Identify the top MarketingStatus with the maximum number of applications and analyze its trend over time.

# Max no of Application over the years.
SELECT p.ProductMktStatus, YEAR(a.DocDate) AS "Year", COUNT(a.AppDocID) AS "Num_of_Applications"
FROM appdoc AS a INNER JOIN product AS p ON a.ApplNo = p.Applno
GROUP BY p.ProductMktStatus, Year;

# Top MarketingStatus with max no of application over the time and analyze trend.
#a):-
SELECT p.ProductMktStatus, YEAR(a.DocDate) AS "Year", COUNT(a1.ApplNo) AS "Num_of_Applications"
FROM appdoc AS a INNER JOIN product AS p INNER JOIN application AS a1 ON a.ApplNo = p.Applno AND p.ApplNo = a1.ApplNo
GROUP BY p.ProductMktStatus, YEAR(a.DocDate)
HAVING COUNT(a1.ApplNo) = (SELECT MAX(AppCount) FROM (SELECT COUNT(a1.ApplNo) AS "AppCount" FROM appdoc
AS a INNER JOIN product AS p INNER JOIN application AS a1 ON a.ApplNo = p.Applno AND p.ApplNo = a1.ApplNo
GROUP BY p.ProductMktStatus, YEAR(a.DocDate)) AS Counts);

#b):-
SELECT p.ProductMktStatus, YEAR(a.DocDate) AS "Year", COUNT(a1.ApplNo) AS "Total_Application",
(CASE WHEN ProductMktStatus = 1 THEN "MARKETED" WHEN ProductMktStatus = 2 THEN "WITHDRAWN"
WHEN ProductMktStatus = 3 THEN "PENDING" ELSE "PRE-MARKED" END) AS "Market_Status"
FROM product AS p INNER JOIN appdoc AS a INNER JOIN application AS a1
ON p.ApplNo = a.ApplNo AND a.ApplNo = a1.ApplNo 
GROUP BY Year, p.ProductMktStatus ORDER BY Total_Application DESC;

#=======================================================================================================#

##__TASK-3__##  Analyzing Products.
###

#1): Categorize Products by dosage form and analyze their distribution.
SELECT dosage, form, COUNT(ProductNo) AS "NumberOfProducts"
FROM product
GROUP BY dosage, form ORDER BY NumberOfProducts DESC;

#_______________________________________________________________________________________________________#

#2): Calculate the total number of approvals for each dosage form and identify the most successful forms.
SELECT p.dosage, p.form, YEAR(r.ActionDate), COUNT(r.ApplNo) AS "TotalApprovals"
FROM product AS p INNER JOIN regactiondate AS r 
ON p.ApplNo = r.ApplNo WHERE ActionType = "AP"
GROUP BY p.dosage, YEAR(r.ActionDate), p.form
ORDER BY TotalApprovals DESC;

#_____________________________________________________________________________________________________#

#3): Investigate yearly trends related to successful forms.
SELECT ProductNo, Count(ApplNo) AS TotalCount FROM product
GROUP BY ProductNo ORDER BY TotalCount DESC; 
 
SELECT p.productno, p.form, YEAR(r.actiondate) AS "ApprovalYears", count(r.applno) AS "TotalApprovals",
(CASE WHEN productno <= 10 THEN "MostSuccessForm" ELSE "SuccessForm" END ) AS "Successful_Forms"
FROM product AS p INNER JOIN regactiondate AS r ON p.applno = r.applno 
GROUP BY YEAR(r.actiondate), p.form, productno  ORDER BY totalapprovals DESC;

##=====================================================================================================##
#Task 4): Exploring Therapeutic Classes and Approval Trends
###

#1): Analyze drug approvals based on therapeutic evaluation code (TE_Code).
SELECT p.TEcode, COUNT(a.ApplNo) AS "DrugApprovals"
FROM product AS p INNER JOIN application AS a 
ON p.ApplNo = a.ApplNo  WHERE ActionType = "AP"
GROUP BY p.TEcode ORDER BY DrugApprovals DESC;

#______________________________________________________________________________________________________#

#2): Determine the therapeutic evaluation code (TE_Code) with the highest number of Approvals in each year.
SELECT Year, TECode, MAX(Approvals) AS "MaxApprovals"
FROM (SELECT YEAR(r.ActionDate) AS "Year", p.TECode, COUNT(r.ApplNo) AS "Approvals"
FROM product AS p INNER JOIN application AS a INNER JOIN regactiondate AS r
ON p.ApplNo = a.ApplNo AND a.ApplNo = r.ApplNo 
GROUP BY Year, TECode) AS ApprovalCounts GROUP BY Year, TECode;


                                     #### TASK ENDED ####













