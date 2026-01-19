-- Objective Question 1
SELECT 
COLUMN_NAME, DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'ball_by_ball'; 


-- Objective Question 2
SELECT 
    SUM(COALESCE(b.Runs_Scored, 0)) 
    + SUM(COALESCE(e.Extra_Runs, 0)) AS total_runs_with_extras
FROM Matches m
JOIN Ball_by_Ball b 
    ON m.Match_Id = b.Match_Id 
LEFT JOIN Extra_Runs e 
    ON b.Match_Id = e.Match_Id
    AND b.Over_Id = e.Over_Id
    AND b.Ball_Id = e.Ball_Id
    AND b.Innings_No = e.Innings_No
WHERE 
    m.Season_Id = 6
    AND b.Team_Batting = 2;  

-- Objective Question 3

select count(distinct p.player_id) as Total_players_above25 from player p
join player_match pm
on p.Player_id=pm.Player_id
join Matches m
on m.Match_id=pm.Match_id
join Season s
on s.Season_id=m.Season_id
where Season_Year=2014 and timestampdiff(year,DOB,'2014-01-01')>25;

-- Objective Question 4


select count(*) as Matches_Won_By_RCB from matches m
join season s
on m.Season_id=s.Season_id
where Season_year=2013 and 
Match_Winner = (select team_id from team where team_name='Royal Challengers Bangalore');

-- Objective Question 5

with last4season as (
select Season_id from season
order by Season_Year desc
limit 4
),
recent_matches as (
select match_id from matches
where season_id in (select season_id from last4season)
),
player_stats as (select p.player_id,player_name,
sum(runs_scored) as total_runs_scored,
count(*) as Balls_Faced
 from player p
join ball_by_ball b
on p.player_id=b.striker
where match_id in (select match_id from recent_matches) 
AND b.Runs_Scored IS NOT NULL 
group by player_id,player_name)

select player_name,
round((total_runs_scored/Balls_Faced)*100,2) as strike_rate 
from player_stats
order by strike_rate desc
limit 10;


-- Objective Question 6

WITH total_runs AS (
    SELECT
        b.Striker AS Player_Id,
        SUM(b.Runs_Scored) AS Total_Runs
    FROM Ball_by_Ball b
    WHERE b.Runs_Scored IS NOT NULL
    GROUP BY b.Striker
),
matches_played AS (
    SELECT
        pm.Player_Id,
        COUNT(DISTINCT pm.Match_Id) AS Matches_Played
    FROM Player_Match pm
    GROUP BY pm.Player_Id
)

SELECT
    p.Player_Name,
    ROUND(tr.Total_Runs / mp.Matches_Played, 2) AS Avg_Runs_Per_Match
FROM total_runs tr
JOIN matches_played mp ON tr.Player_Id = mp.Player_Id
JOIN Player p ON p.Player_Id = tr.Player_Id
ORDER BY Avg_Runs_Per_Match DESC;

-- Objective Question 7

WITH total_wickets AS (
    SELECT
        b.Bowler AS Player_Id,
        COUNT(*) AS Total_Wickets
    FROM Wicket_Taken w
    JOIN Ball_by_Ball b
        ON w.Match_Id = b.Match_Id
       AND w.Over_Id = b.Over_Id
       AND w.Ball_Id = b.Ball_Id
       AND w.Innings_No = b.Innings_No
    GROUP BY b.Bowler
),
matches_played AS (
    SELECT
        Player_Id,
        COUNT(DISTINCT Match_Id) AS Matches_Played
    FROM Player_Match
    GROUP BY Player_Id
)

SELECT
    p.Player_Name,
    ROUND(tw.Total_Wickets / mp.Matches_Played, 2) AS Avg_Wickets_Per_Match
FROM total_wickets tw
JOIN matches_played mp
    ON tw.Player_Id = mp.Player_Id
JOIN Player p
    ON p.Player_Id = tw.Player_Id
ORDER BY Avg_Wickets_Per_Match DESC;


-- Objective Question 8


use ipl;
WITH player_runs AS (
    SELECT
        pm.Player_Id,
        SUM(b.Runs_Scored) AS Total_Runs,
        COUNT(DISTINCT pm.Match_Id) AS Matches_Played,
        SUM(b.Runs_Scored) / COUNT(DISTINCT pm.Match_Id) AS Avg_Runs
    FROM Player_Match pm
    LEFT JOIN Ball_by_Ball b
        ON pm.Player_Id = b.Striker
       AND pm.Match_Id = b.Match_Id
    GROUP BY pm.Player_Id
),
overall_avg_runs AS (
    SELECT AVG(Avg_Runs) AS overall_avg
    FROM player_runs
),
player_wickets AS (
    SELECT
        b.Bowler AS Player_Id,
        COUNT(*) AS Total_Wickets,
	 count(Player_Out)/count(distinct w.match_id) as avg_wickets
    FROM Wicket_Taken w
    JOIN Ball_by_Ball b
        ON w.Match_Id = b.Match_Id
       AND w.Over_Id = b.Over_Id
       AND w.Ball_Id = b.Ball_Id
       AND w.Innings_No = b.Innings_No
    GROUP BY b.Bowler
),
overall_avg_wickets AS (
    SELECT AVG(Total_Wickets) AS overall_avg_wk
    FROM player_wickets
)
SELECT
    p.Player_Name,
    r.Avg_Runs,
    w.Total_Wickets,
     avg_wickets
FROM player_runs r
JOIN player_wickets w
    ON r.Player_Id = w.Player_Id
JOIN overall_avg_runs oar
JOIN overall_avg_wickets oaw
JOIN Player p
    ON p.Player_Id = r.Player_Id
WHERE r.Avg_Runs > oar.overall_avg
  AND w.Total_Wickets > oaw.overall_avg_wk
ORDER BY r.Avg_Runs DESC, w.Total_Wickets DESC;



-- Objective Question 9



CREATE TABLE rcb_record (
    Venue_Id INT PRIMARY KEY,
    Venue_Name VARCHAR(450),
    Wins INT,
    Losses INT
);
INSERT INTO rcb_record (Venue_Id, Venue_Name, Wins, Losses)
SELECT
    v.Venue_Id,
    v.Venue_Name,
    SUM(CASE WHEN m.Match_Winner = rcb.Team_Id THEN 1 ELSE 0 END) AS Wins,
    SUM(CASE 
            WHEN m.Match_Winner IS NOT NULL 
             AND m.Match_Winner <> rcb.Team_Id
             AND (m.Team_1 = rcb.Team_Id OR m.Team_2 = rcb.Team_Id)
         THEN 1 ELSE 0 END) AS Losses
FROM Matches m
JOIN Venue v 
    ON m.Venue_Id = v.Venue_Id
JOIN Team rcb 
    ON rcb.Team_Name = 'Royal Challengers Bangalore'
WHERE m.Team_1 = rcb.Team_Id
   OR m.Team_2 = rcb.Team_Id
GROUP BY v.Venue_Id, v.Venue_Name;
select * from rcb_record;



-- Objective Question 10

SELECT 
    bs.Bowling_skill AS Bowling_Style,
    COUNT(*) AS Total_Wickets
FROM bowling_style bs
JOIN player p
    ON p.bowling_skill = bs.bowling_id
JOIN ball_by_ball b
    ON b.bowler = p.player_id
JOIN wicket_taken w
    ON w.match_id = b.match_id
   AND w.over_id = b.over_id
   AND w.ball_id = b.ball_id
   AND w.innings_no = b.innings_no
GROUP BY bs.Bowling_skill
ORDER BY Total_Wickets DESC;


-- Objective Question 11

WITH team_runs AS (
    SELECT
        m.Season_Id,
        b.Team_Batting AS Team_Id,
        SUM(b.Runs_Scored) AS Total_Runs
    FROM Ball_by_Ball b
    JOIN Matches m ON b.Match_Id = m.Match_Id
    WHERE b.Runs_Scored IS NOT NULL
    GROUP BY m.Season_Id, b.Team_Batting
),

team_wickets AS (
    SELECT
        m.Season_Id,
        b.Team_Bowling AS Team_Id,
        COUNT(*) AS Total_Wickets
    FROM Wicket_Taken w
    JOIN Ball_by_Ball b
       ON w.Match_Id = b.Match_Id
      AND w.Over_Id = b.Over_Id
      AND w.Ball_Id = b.Ball_Id
      AND w.Innings_No = b.Innings_No
    JOIN Matches m ON b.Match_Id = m.Match_Id
    GROUP BY m.Season_Id, b.Team_Bowling
),



season_summary AS (
    SELECT
        r.Season_Id,
        r.Team_Id,
        r.Total_Runs,
        w.Total_Wickets
    FROM team_runs r
    JOIN team_wickets w
        ON r.Season_Id = w.Season_Id
       AND r.Team_Id = w.Team_Id
),
with_prev AS (
    SELECT
        ss.Team_Id,
        ss.Season_Id,
        ss.Total_Runs,
        ss.Total_Wickets,
        LAG(ss.Total_Runs) OVER (PARTITION BY ss.Team_Id ORDER BY ss.Season_Id) AS Prev_Runs,
        LAG(ss.Total_Wickets) OVER (PARTITION BY ss.Team_Id ORDER BY ss.Season_Id) AS Prev_Wickets
    FROM season_summary ss
)
SELECT
    t.Team_Name,
    wp.Season_Id,
    wp.Total_Runs,
    wp.Total_Wickets,
    wp.Prev_Runs,
    wp.Prev_Wickets,
    CASE
        WHEN wp.Prev_Runs IS NULL THEN 'No Previous Data'
        WHEN wp.Total_Runs > wp.Prev_Runs AND wp.Total_Wickets > wp.Prev_Wickets THEN 'Better'
        WHEN wp.Total_Runs < wp.Prev_Runs AND wp.Total_Wickets < wp.Prev_Wickets THEN 'Worse'
        ELSE 'Mixed'
    END AS Performance_Status
FROM with_prev wp
JOIN Team t ON wp.Team_Id = t.Team_Id
ORDER BY t.Team_Name, wp.Season_Id;


-- Objective Question 12


-- 1. Win Percentage for Each Team
WITH matches_played AS (
    SELECT team_1 AS team_id, match_id, match_winner FROM matches
    UNION ALL
    SELECT team_2 AS team_id, match_id, match_winner FROM matches
)
SELECT
    t.team_name,
    ROUND(
        (SUM(CASE WHEN mp.team_id = mp.match_winner THEN 1 ELSE 0 END) / COUNT(*)) * 100,
        2
    ) AS win_percentage
FROM matches_played mp
JOIN team t ON t.team_id = mp.team_id
GROUP BY t.team_id, t.team_name
ORDER BY win_percentage DESC;


-- 2.  Average Runs per Match

SELECT 
    t.team_name,
    ROUND(SUM(b.runs_scored) / COUNT(DISTINCT m.match_id), 2) AS avg_runs_per_match
FROM ball_by_ball b
JOIN matches m 
    ON b.match_id = m.match_id
JOIN team t 
    ON b.team_batting = t.team_id
WHERE b.runs_scored IS NOT NULL   
GROUP BY t.team_id, t.team_name
ORDER BY avg_runs_per_match DESC;

-- 3. Average Wickets per Match

SELECT 
    t.team_name,
    COUNT(*) / COUNT(DISTINCT m.match_id) AS avg_wickets_per_match
FROM wicket_taken w
JOIN ball_by_ball b
    ON w.match_id = b.match_id
   AND w.over_id = b.over_id
   AND w.ball_id = b.ball_id
   AND w.innings_no = b.innings_no
JOIN matches m 
    ON w.match_id = m.match_id
JOIN team t 
    ON b.team_bowling = t.team_id
GROUP BY t.team_id, t.team_name
ORDER BY avg_wickets_per_match DESC;

-- 4.Run Rate


WITH team_balls AS (
    SELECT
        t.team_id,
        t.team_name,
        SUM(b.runs_scored) AS total_runs,
        COUNT(b.runs_scored) AS legal_balls
    FROM ball_by_ball b
    JOIN matches m ON b.match_id = m.match_id
    JOIN team t ON b.team_batting = t.team_id
    WHERE b.runs_scored IS NOT NULL   -- only legal balls count
    GROUP BY t.team_id, t.team_name
)

SELECT
    team_name,
    ROUND(total_runs / (legal_balls / 6), 2) AS run_rate
FROM team_balls
ORDER BY run_rate DESC;



-- 5. Toss kpi

SELECT 
    t.team_name,
    td.toss_name AS toss_decision,
    ROUND(
        (SUM(CASE WHEN m.toss_winner = m.match_winner THEN 1 ELSE 0 END) 
        / NULLIF(COUNT(*), 0)) * 100, 
        2
    ) AS win_percentage_after_toss_decision
FROM matches m
JOIN team t 
    ON m.toss_winner = t.team_id
JOIN toss_decision td
    ON m.toss_decide = td.toss_id
GROUP BY 
    t.team_name, 
    td.toss_name
ORDER BY 
    t.team_name ASC, 
    td.toss_name ASC;


-- Objective Question 13

WITH bowler_venue_wickets AS (
    SELECT
        b.Bowler AS Bowler_Id,
        v.Venue_Name,
        COUNT(*) AS Wickets
    FROM Wicket_Taken w
    JOIN Ball_by_Ball b
        ON w.Match_Id = b.Match_Id
       AND w.Over_Id = b.Over_Id
       AND w.Ball_Id = b.Ball_Id
       AND w.Innings_No = b.Innings_No
    JOIN Matches m 
        ON b.Match_Id = m.Match_Id
    JOIN Venue v 
        ON m.Venue_Id = v.Venue_Id
    GROUP BY b.Bowler, v.Venue_Name
),
bowler_venue_avg AS (
    SELECT
        Bowler_Id,
        Venue_Name,
        AVG(Wickets) AS Avg_Wickets
    FROM bowler_venue_wickets
    GROUP BY Bowler_Id, Venue_Name
)
SELECT
    p.Player_Name,
    bv.Venue_Name,
    ROUND(bv.Avg_Wickets, 2) AS Avg_Wickets,
    RANK() OVER (PARTITION BY bv.Venue_Name ORDER BY bv.Avg_Wickets DESC) AS Rank_In_Venue
FROM bowler_venue_avg bv
JOIN Player p
    ON p.Player_Id = bv.Bowler_Id
ORDER BY bv.Venue_Name, Rank_In_Venue;



-- Objective Question 14

SELECT
p.Player_Name,
s.Season_Year,
SUM(b.Runs_Scored) AS Total_Runs
FROM
Ball_by_Ball b
JOIN Matches m ON b.Match_Id = m.Match_Id
JOIN Season s ON m.Season_Id = s.Season_Id
JOIN Player p ON b.Striker = p.Player_Id
GROUP BY
p.Player_Name, s.Season_Year
ORDER BY
p.Player_Name, s.Season_Year;

-- 2
SELECT
p.Player_Name,
s.Season_Year,
COUNT(w.Player_Out) AS Total_Wickets
FROM
Ball_by_Ball b
JOIN Wicket_Taken w ON b.Match_Id = w.Match_Id
AND b.Over_Id = w.Over_Id
AND b.Ball_Id = w.Ball_Id
AND b.Innings_No = w.Innings_No
JOIN Matches m ON b.Match_Id = m.Match_Id
JOIN Season s ON m.Season_Id = s.Season_Id
JOIN Player p ON b.Bowler = p.Player_Id
GROUP BY
p.Player_Name, s.Season_Year
ORDER BY
p.Player_Name, s.Season_Year;


-- Objective Question 15

-- 1
SELECT 
p.Player_Name,
v.Venue_Name,
SUM(b.Runs_Scored) AS Total_Runs
FROM 
    Ball_by_Ball b
JOIN Matches m ON b.Match_Id = m.Match_Id
JOIN Venue v ON m.Venue_Id = v.Venue_Id
JOIN Player p ON b.Striker = p.Player_Id
GROUP BY 
    p.Player_Name, v.Venue_Name
Order by Total_Runs desc
Limit 10;

-- 2 
SELECT
p.Player_Name,
v.Venue_Name,
COUNT(w.Player_Out) AS Total_Wickets
FROM
Ball_by_Ball b
JOIN Wicket_Taken w ON b.Match_Id = w.Match_Id
AND b.Over_Id = w.Over_Id
AND b.Ball_Id = w.Ball_Id
AND b.Innings_No = w.Innings_No
JOIN Matches m ON b.Match_Id = m.Match_Id
JOIN Venue v ON m.Venue_Id = v.Venue_Id
JOIN Player p ON b.Bowler = p.Player_Id
GROUP BY
p.Player_Name, v.Venue_Name
Order by Total_wickets desc
Limit 10;




-- SUBJECTIVE ANSWERS


-- SUBJECTIVE QUESTION 1

WITH Toss_Win_Stats AS (
    SELECT v.Venue_Name,
           td.Toss_Name AS Toss_Decision,
           COUNT(*) AS Total_Matches,
           SUM(CASE WHEN m.Match_Winner = m.Toss_Winner THEN 1 ELSE 0 END) AS Matches_Won_After_Toss,
           (SUM(CASE WHEN m.Match_Winner = m.Toss_Winner THEN 1 ELSE 0 END) / COUNT(*)) * 100 AS Win_Percentage
    FROM matches m
    INNER JOIN toss_decision td ON m.Toss_Decide = td.Toss_Id
    INNER JOIN venue v ON m.Venue_Id = v.Venue_Id
    GROUP BY v.Venue_Name, td.Toss_Name
)
SELECT Venue_Name,
       Toss_Decision,
       Total_Matches,
       Matches_Won_After_Toss,
       Win_Percentage
FROM Toss_Win_Stats
WHERE Total_Matches >= 10
ORDER BY Win_Percentage DESC, Total_Matches DESC;


-- SUBJECTIVE QUESTION 2


SELECT
p.Player_Name,
ROUND(SUM(b.Runs_Scored) * 1.0 / COUNT(DISTINCT m.Match_Id), 2) AS Avg_Runs_Per_Match
FROM
Ball_by_Ball b
JOIN Matches m ON b.Match_Id = m.Match_Id
JOIN Player p ON b.Striker = p.Player_Id
GROUP BY
p.Player_Name
HAVING 
COUNT(DISTINCT m.Match_Id) >= 5  -- filters out players who played too few matches
ORDER BY
 Avg_Runs_Per_Match DESC
LIMIT 10;

SELECT
p.Player_Name,
COUNT(w.Player_Out) AS Total_Wickets
FROM
Ball_by_Ball b
JOIN Wicket_Taken w ON b.Match_Id = w.Match_Id
AND b.Over_Id = w.Over_Id
AND b.Ball_Id = w.Ball_Id
AND b.Innings_No = w.Innings_No
JOIN Player p ON b.Bowler = p.Player_Id
GROUP BY
p.Player_Name
ORDER BY 
Total_Wickets DESC
LIMIT 10;


-- SUBJECTIVE QUESTION 3

WITH Player_Stats AS (
  SELECT
      p.Player_Name,
      COUNT(DISTINCT m.Match_Id) AS Matches_Played,
      -- Batting metrics
      SUM(bbb.Runs_Scored) AS Total_Runs,
      AVG(bbb.Runs_Scored) AS Avg_Runs_Per_Ball,
      (SUM(bbb.Runs_Scored) /COUNT(bbb.ball_id ))* 100.0  AS Strike_Rate,
      -- Bowling metrics
      COUNT(wt.Player_Out) AS Total_Wickets
      FROM player p
  INNER JOIN ball_by_ball bbb ON p.Player_Id = bbb.Striker OR p.Player_Id = bbb.Bowler
  INNER JOIN matches m ON bbb.Match_Id = m.Match_Id
  LEFT JOIN wicket_taken wt
         ON bbb.Match_Id = wt.Match_Id
        AND bbb.Over_Id = wt.Over_Id
        AND bbb.Ball_Id = wt.Ball_Id
  GROUP BY p.Player_Name
)
SELECT
    Player_Name,
    Matches_Played,
    Total_Runs,
    ROUND(Avg_Runs_Per_Ball, 2) AS Avg_Runs_Per_Ball,
    ROUND(Strike_Rate, 2) AS Strike_Rate,
    Total_Wickets
FROM Player_Stats
WHERE Matches_Played > 10
ORDER BY
    Total_Runs DESC
LIMIT 10;

-- SUBJECTIVE QUESTION 4

WITH player_stats AS (
    SELECT
        p.Player_Id,
        p.Player_Name,
        SUM(CASE 
              WHEN b.Striker = p.Player_Id 
              THEN b.Runs_Scored 
              ELSE 0 
            END) AS total_runs,
        COUNT(CASE 
                WHEN b.Bowler = p.Player_Id 
                 AND w.Player_Out IS NOT NULL 
                THEN 1 
              END) AS total_wickets
    FROM player p
    JOIN ball_by_ball b
      ON p.Player_Id IN (b.Striker, b.Bowler)
    LEFT JOIN wicket_taken w
      ON b.Match_Id = w.Match_Id
     AND b.Over_Id = w.Over_Id
     AND b.Ball_Id = w.Ball_Id
     AND b.Innings_No = w.Innings_No
    GROUP BY p.Player_Id, p.Player_Name
)

SELECT *
FROM player_stats
WHERE total_runs > 500
  AND total_wickets >= 35
ORDER BY (total_runs + total_wickets * 20) DESC;


-- SUBJECTIVE QUESTION 5

SELECT
Player_Name,
COUNT(*) AS Matches_Played,
SUM(CASE WHEN Team_Id = Match_Winner THEN 1 ELSE 0 END) AS Matches_Won,
ROUND(SUM(CASE WHEN Team_Id = Match_Winner THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Win_Percentage
FROM (
SELECT DISTINCT
m.Match_Id,
p.Player_Name,
pb.Team_Batting AS Team_Id,
m.Match_Winner
FROM Ball_by_Ball pb
JOIN Matches m ON pb.Match_Id = m.Match_Id
JOIN Player p ON pb.Striker = p.Player_Id
) AS player_matches
GROUP BY Player_Name
HAVING Matches_Played >= 10
ORDER BY Win_Percentage DESC
Limit 10;

-- SUBJECTIVE QUESTION 6

WITH rcb_matches AS (
    SELECT
        Match_Id,
        Season_Id
    FROM Matches
    WHERE Team_1 = 2 OR Team_2 = 2
),

rcb_runs AS (
    SELECT
        m.Season_Id,
        SUM(b.Runs_Scored) AS total_runs,
        COUNT(DISTINCT b.Match_Id) AS total_matches
    FROM rcb_matches m
    JOIN Ball_by_Ball b
      ON m.Match_Id = b.Match_Id
    WHERE b.Team_Batting = 2
    GROUP BY m.Season_Id
),

rcb_bowling AS (
    SELECT
        m.Season_Id,
        COUNT(w.Player_Out) AS total_wickets,
        COUNT(DISTINCT b.Match_Id) AS matches_bowled,
        SUM(b.Runs_Scored + COALESCE(er.Extra_Runs, 0)) AS runs_conceded,
        COUNT(DISTINCT CONCAT(b.Match_Id, b.Innings_No, b.Over_Id)) AS total_overs
    FROM rcb_matches m
    JOIN Ball_by_Ball b
      ON m.Match_Id = b.Match_Id
    LEFT JOIN Extra_Runs er
      ON b.Match_Id = er.Match_Id
     AND b.Over_Id = er.Over_Id
     AND b.Ball_Id = er.Ball_Id
     AND b.Innings_No = er.Innings_No
    LEFT JOIN Wicket_Taken w
      ON b.Match_Id = w.Match_Id
     AND b.Over_Id = w.Over_Id
     AND b.Ball_Id = w.Ball_Id
     AND b.Innings_No = w.Innings_No
    WHERE b.Team_Bowling = 2
    GROUP BY m.Season_Id
)

SELECT
    r.Season_Id,
    r.total_runs,
    b.total_wickets,
    ROUND(r.total_runs / r.total_matches, 2) AS avg_runs_per_match,
    ROUND(b.total_wickets / b.matches_bowled, 2) AS avg_wickets_per_match,
    ROUND(b.runs_conceded / NULLIF(b.total_overs, 0), 2) AS economy_rate
FROM rcb_runs r
JOIN rcb_bowling b
  ON r.Season_Id = b.Season_Id
ORDER BY r.Season_Id;



-- SUBJECTIVE QUESTION 7


SELECT
 v.Venue_Name, 
ROUND(SUM(b.Runs_Scored) * 1.0 / COUNT(b.Ball_Id), 2) AS Avg_Runs_Per_Ball 
FROM Ball_by_Ball b 
JOIN Matches m 
ON b.Match_Id = m.Match_Id 
JOIN Venue v 
ON m.Venue_Id = v.Venue_Id
GROUP BY v.Venue_Name 
ORDER BY Avg_Runs_Per_Ball DESC;




-- SUBJECTIVE QUESTION 8

SELECT 
    t.Team_Name AS Team,
    v.Venue_Name AS Home_Venue,
    COUNT(*) AS Matches_Played_At_Home,
    SUM(CASE WHEN m.Match_Winner = t.Team_Id THEN 1 ELSE 0 END) AS Wins_At_Home,
    ROUND(
        SUM(CASE WHEN m.Match_Winner = t.Team_Id THEN 1 ELSE 0 END) * 100.0 /
        COUNT(*), 
        2
    ) AS Win_Percentage_At_Home
FROM Matches m
JOIN Venue v 
    ON m.Venue_Id = v.Venue_Id
JOIN Team t 
    ON t.Team_Id = 2  
WHERE 
    v.Venue_Name LIKE '%Chinnaswamy%'
    AND (m.Team_1 = t.Team_Id OR m.Team_2 = t.Team_Id)
GROUP BY 
    t.Team_Name, v.Venue_Name
ORDER BY 
    Win_Percentage_At_Home DESC;




-- SUBJECTIVE QUESTION 9

WITH RCB_Performance AS (
    SELECT
        m.Season_Id,
        COUNT(m.Match_Id) AS Matches_Played,
        SUM(CASE WHEN m.Match_Winner = t.Team_Id THEN 1 ELSE 0 END) AS Matches_Won,
        SUM(CASE WHEN m.Match_Winner != t.Team_Id THEN 1 ELSE 0 END) AS Matches_Lost,
        (SUM(CASE WHEN m.Match_Winner = t.Team_Id THEN 1 ELSE 0 END) / COUNT(m.Match_Id)) * 100 AS Win_Percentage
    FROM matches m
    INNER JOIN team t ON t.Team_Id = m.Team_1 OR t.Team_Id = m.Team_2
    WHERE t.Team_Name = 'Royal Challengers Bangalore'
    GROUP BY m.Season_Id
)
SELECT
    s.Season_Year,
    rp.Matches_Played,
    rp.Matches_Won,
    rp.Matches_Lost,
    rp.Win_Percentage
FROM RCB_Performance rp
INNER JOIN season s ON rp.Season_Id = s.Season_Id
ORDER BY s.Season_Year;

-- SUBJECTIVE QUESTION 11

UPDATE matches
SET Opponent_Team = 'Delhi_Daredevils'
WHERE Opponent_Team = 'Delhi_Capitals';






