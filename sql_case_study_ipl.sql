SELECT * FROM iplplayers;

--total spend on players for each team

SELECT team,SUM(price_in_cr) as total_price_in_cr
FROM iplplayers
GROUP BY team
ORDER BY total_price_in_cr desc;

--top 3 highest paide all-rounders across all teams

SELECT player,role,price_in_cr
FROM iplplayers
WHERE role = 'All-rounder'
ORDER BY price_in_cr desc
LIMIT 3;


--highest-priced-player in each team

SELECT player,team,price_in_cr
FROM(
SELECT *,DENSE_RANK() OVER (PARTITION By team ORDER BY price_in_cr desc ) as highest_paid_rank
FROM iplplayers
)
WHERE highest_paid_rank = 1;

-- rank players by price within each team and list top 2 for every team

WITH rank_by_team as
(
SELECT *,ROW_number() OVER (PARTITION By team ORDER BY price_in_cr desc ) as rank_of_players
FROM iplplayers
)
SELECT player,team,price_in_cr,rank_of_players
FROM rank_by_team
WHERE rank_of_players in (1,2);

--most expensive player and second most expensive players name and price for each team

WITH rank_by_team as
(
SELECT *,ROW_number() OVER (PARTITION By team ORDER BY price_in_cr desc ) as rank_of_players
FROM iplplayers
)
SELECT 
team,
MAX(CASE WHEN rank_of_players = 1 THEN player END) AS MostExpensivePlayer,
MAX(CASE WHEN rank_of_players = 1 THEN price_in_cr END) AS HighestPrice,
MAX(CASE WHEN rank_of_players = 2 THEN player END) AS SEcondMostExpensivePlayer,
MAX(CASE WHEN rank_of_players = 2 THEN price_in_cr END) AS SecondHighestPrice
FROM rank_by_team
GROUP BY team;

--each persons percentage price to total spending

SELECT player,team,price_in_cr,ROUND(price_in_cr*100/SUM(price_in_cr) OVER (PARTITION BY team),2) || '%' as contribution_percentage
FROM iplplayers;

 /*classify player as  high medium or low based on certain rules rule 1: price > 15cr then high, price between 5 and 15 then medium  else low 
 and then find out how many players in each category in each team*/
 
WITH player_cat AS 
(SELECT team,player,price_in_cr,
CASE 
	WHEN price_in_cr > 15 THEN 'High'
	WHEN price_in_cr >= 5 THEN 'Medium'
	ELSE 'Low'
END as player_category
FROM iplplayers)

SELECT team,player_category,COUNT(*)
FROM player_cat
GROUP BY team,player_category
ORDER BY team,player_category;

--find avg players of indians and compare with avg of overseas

SELECT
'Indian' as player_type,AVG(price_in_cr) as avg_price
FROM iplplayers
where type like '%Indian%'
UNION
SELECT 
'Overseas' as player_type,avg(price_in_Cr) as Overseas_avg
FROM iplplayers
WHERE type LIKE '%Overseas%';

--players who earn more than avg in their team

SELECT player,team,price_in_cr
FROM iplplayers i1
WHERE price_in_cr > (SELECT AVG(price_in_cr) FROM iplplayers i2
						WHERE i1.team = i2.team);

-- find most expensive player and price using correlated subquery for each role

SELECT player,role,price_in_cr
FROM iplplayers i1
WHERE price_in_cr = (SELECT MAX(price_in_cr) FROM iplplayers i2
						WHERE i1.role = i2.role)

