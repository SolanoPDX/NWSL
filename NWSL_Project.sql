	--Querying all of the data to make sure it imported correctly.

SELECT *
FROM nwsl..NWSL_Data$


SELECT *
FROM nwsl..NWSL_Players$

	--Selecting some data I want to highlight. 

SELECT person_id, season, team_id, gls, min
FROM nwsl..NWSL_Data$
ORDER BY gls DESC

	--Looking at goals per minute to find the most efficient players in a single season, scoring-wise

--SELECT person_id, season, team_id, gls, min, (gls/min)
--FROM NWSL_Project..NWSL_Data$
--ORDER BY gls DESC

	--Tried running the query above, got "Error converting data type nvarchar to float." After a Google search, need to get rid of my NULL values.

--SELECT person_id, season, team_id, ISNULL(gls,0) AS goals, ISNULL(min,0) AS minutes 
--INTO nwsl_data_no_nulls
--FROM nwsl..NWSL_Data$
--ORDER BY goals DESC

	--Tried the above. Ended up going back to the Excel document, used "Find and Replace" to replace the NULL's and #N/A's values to "0".

SELECT person_id, season, team_id, gls, min, (gls/min) AS goals_per_minute
FROM nwsl..NWSL_Data$
WHERE min<>0
ORDER BY goals_per_minute DESC

	--Setting a minimum amount of minutes to be eligible to show up in the table


SELECT person_id, season, team_id, gls, min, (gls/min) AS goals_per_minute
FROM nwsl..NWSL_Data$
WHERE min > 90 --(90 minutes is the length of a full soccer game)
ORDER BY goals_per_minute DESC

	--Realizing because the values are so small (scoring goals is hard!), goals per 90 min might be a better measure

SELECT person_id, season, team_id, gls, min, (gls/(min/90)) AS goals_per_90
INTO nwsl_data_90
FROM nwsl..NWSL_Data$
WHERE min > 90 AND gls > 0 --getting rid of players who did not score at all to clean up table
ORDER BY goals_per_90 DESC

		--Joining two tables on person_id in order to get the names of the players in the table

SELECT nwsl_data_90.person_id, NWSL_Players$.player, nwsl_data_90.season, nwsl_data_90.team_id, nwsl_data_90.gls, nwsl_data_90.min, nwsl_data_90.goals_per_90
INTO nwsl_players_90
FROM nwsl..nwsl_data_90
JOIN NWSL_Players$ ON nwsl_data_90.person_id = NWSL_Players$.person_id
ORDER BY goals_per_90 DESC

		--Last query will be combining the goals scored for each player from 2013 to 2019 using a GROUP BY

SELECT player, SUM(gls) AS agg_goals, SUM(min) AS agg_minutes, (SUM(gls))/(SUM(min)/90) AS agg_goals_per_90
INTO nwsl_agg
FROM nwsl_players_90
WHERE min > 0
GROUP BY player
ORDER BY agg_goals_per_90 DESC


SELECT player, SUM(agg_goals) AS aggregate_goals, SUM(agg_minutes) AS aggregate_minutes, SUM(agg_goals_per_90) AS aggregate_goals_per_90
INTO nwsl_aggregate
FROM nwsl_agg
WHERE agg_minutes > 1980 --1980 minutes is approximately a full seasons worth of minutes
GROUP BY player
ORDER BY SUM(agg_goals_per_90) DESC

	--The above query tells us that Sam Kerr was the most efficient goalscorer between 2013 and 2019.



--All data comes from nwslR, an R package that contains datasets for the National Women's Soccer League by adror1.
--https://github.com/adror1/nwslR