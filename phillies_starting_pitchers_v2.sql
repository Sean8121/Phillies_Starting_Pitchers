--Basic year over year calculation for ERA while on the Phillies
SELECT Name, AVG(ERA) as AverageWithPhillies
FROM phillies_starting_pitchers_no20
WHERE Tm = 'PHI'
GROUP BY Name

-- Basic year over year calculation for ERA while NOT on the Phillies
SELECT Name, AVG(ERA) as AverageNotOnPhillies
FROM phillies_starting_pitchers_no20
WHERE Tm NOT like 'PHI' AND Tm NOT like 'TOT%'
GROUP BY Name


-- For accurate ERA analysis, adding two yearly averages is incorrect
-- To correctly show True ERA while on/off the Phillies, total innings pitched and total ER (earned runs) must be averaged

--Attempt to calculate True ERA by adding ER and IP while with every team that isn't PHI
SELECT Name, SUM(IP) as TotalInningsPitched, SUM(ER) as TotalER
FROM phillies_starting_pitchers_no20
WHERE Tm NOT like 'TOT%' AND Tm not like 'PHI'
GROUP BY Name


--Use previous table as CTE to calculate True ERA while not with PHI


WITH NonPHI_ERA (Name, TotalInningsPitched, TotalER)
as
(
SELECT Name, SUM(IP) as TotalInningsPitched, SUM(ER) as TotalER
FROM phillies_starting_pitchers_no20
WHERE Tm NOT like 'TOT%' AND Tm not like 'PHI'
GROUP BY Name
)
SELECT *, (TotalER/TotalInningsPitched)*9 as NonPHI_ERA
FROM NonPHI_ERA


--Attempt to calculate True ERA by adding up ER and IP while with Tm is PHI
SELECT Name, SUM(IP) as TotalInningsPitched, SUM(ER) as TotalER
FROM phillies_starting_pitchers
WHERE Tm = 'PHI'
GROUP BY Name

--Use previous table as CTE to calculate ERA while with PHI
WITH PHI_ERA (Name, TotalInningsPitched, TotalER)
as
(SELECT Name, SUM(IP) as TotalInningsPitched, SUM(ER) as TotalER
FROM phillies_starting_pitchers
WHERE Tm = 'PHI'
GROUP BY Name)
SELECT *, (TotalER/TotalInningsPitched)*9 as PHI_ERA
FROM PHI_ERA



-- Create two tables using the CTEs above


--Create NonPHI_ERA Table
DROP Table if exists #NonPHI_ERA
Create Table #NonPHI_ERA
(
Name nvarchar(255),
TotalNonPHIInningsPitched float,
TotalNonPHIER float
)

Insert into #NonPHI_ERA
SELECT Name, SUM(IP) as TotalInningsPitched, SUM(ER) as TotalER
FROM phillies_starting_pitchers_no20
WHERE Tm NOT like 'TOT%' AND Tm not like 'PHI'
GROUP BY Name

SELECT *
FROM #NonPHI_ERA

--Create PHI_ERA Table


DROP Table if exists #PHI_ERA
Create Table #PHI_ERA
(
Name nvarchar(255),
TotalPHIInningsPitched float,
TotalPHIER float
)

Insert into #PHI_ERA
SELECT Name, SUM(IP) as TotalInningsPitched, SUM(ER) as TotalER
FROM phillies_starting_pitchers_no20
WHERE Tm = 'PHI'
GROUP BY Name

SELECT *
FROM #PHI_ERA

--JOIN PHI Innings and ER with NonPHI Innings and ER

SELECT p.*, ((TotalPHIER/TotalPHIInningsPitched)*9) as PHI_ERA, np.TotalNonPHIInningsPitched, np.TotalNonPHIER, ((TotalNonPHIER/TotalNonPHIInningsPitched)*9) as NonPHI_ERA
FROM #PHI_ERA as p
FULL JOIN #NonPHI_ERA as np
ON p.Name = np.Name




-- Comparing HR rates when on Phillies vs off


--HR and IP for PHI
SELECT Name, SUM(HR) as TotalHRWhenPHI, SUM(ip) as TotalIPWhenPHI
FROM phillies_starting_pitchers_no20
WHERE Tm = 'PHI'
GROUP BY Name


-- HR and IP for Non-PHI
SELECT Name, SUM(HR) as TotalHRWhenNonPHI, SUM(ip) as TotalIPWhenNonPHI
FROM phillies_starting_pitchers_no20
WHERE Tm NOT like 'PHI' AND Tm NOT like 'TOT%'
GROUP BY Name


-- CTE HR and IP and HR_Per_9 for PHI
WITH PHI_HRperIP (Name, TotalHRWhenPHI, TotalIPWhenPHI)
as
(
SELECT Name, SUM(HR) as TotalHRWhenPHI, SUM(ip) as TotalIPWhenPHI
FROM phillies_starting_pitchers_no20
WHERE Tm = 'PHI'
GROUP BY Name
)
SELECT *, ((TotalHRWhenPHI*9)/TotalIPWhenPHI) as PHI_HR_Per_9
FROM PHI_HRperIP



-- CTE HR and IP and HR_Per_9 for NonPHI
WITH NonPHI_HRperIP (Name, TotalHRWhenNonPHI, TotalIPWhenNonPHI)
as
(
SELECT Name, SUM(HR) as TotalHRWhenNonPHI, SUM(ip) as TotalIPWhenNonPHI
FROM phillies_starting_pitchers_no20
WHERE Tm NOT like 'PHI' AND Tm NOT like 'TOT%'
GROUP BY Name
)
SELECT *, ((TotalHRWhenNonPHI*9)/TotalIPWhenNonPHI) as NonPHI_HR_Per_9
FROM NonPHI_HRperIP


-- Create two tables using the CTEs above

--Create PHI_HR9 Table


DROP Table if exists #PHI_HR9
Create Table #PHI_HR9
(
Name nvarchar(255),
TotalIPWhenPHI float,
TotalHRWhenPHI float
)

Insert into #PHI_HR9
SELECT Name, SUM(ip) as TotalIPWhenPHI, SUM(HR) as TotalHRWhenPHI
FROM phillies_starting_pitchers_no20
WHERE Tm = 'PHI'
GROUP BY Name

SELECT *
FROM #PHI_HR9


-- Create NonPHI_HR9 Table

DROP Table if exists #NonPHI_HR9
Create Table #NonPHI_HR9
(
Name nvarchar(255),
TotalHRWhenNonPHI float,
TotalIPWhenNonPHI float
)

Insert into #NonPHI_HR9
SELECT Name, SUM(HR) as TotalHRWhenNonPHI, SUM(ip) as TotalIPWhenNonPHI
FROM phillies_starting_pitchers_no20
WHERE Tm NOT like 'PHI' AND Tm NOT like 'TOT%'
GROUP BY Name

SELECT *
FROM #NonPHI_HR9


-- Join PHI_HR9 and NonPHI_HR9

SELECT ph.*, ((TotalHRWhenPHI*9)/TotalIPWhenPHI) as PHI_HR_Per_9, nph.TotalIPWhenNonPHI, nph.TotalHRWhenNonPHI, ((TotalHRWhenNonPHI*9)/TotalIPWhenNonPHI) as NonPHI_HR_Per_9
FROM #PHI_HR9 as ph
FULL JOIN #NonPHI_HR9 as nph
ON ph.Name = nph.Name