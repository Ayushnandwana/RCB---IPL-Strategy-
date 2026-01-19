# RCB — IPL Strategy (SQL Project)

## 📌 Project Overview
This project uses **SQL-based analysis** on historical IPL data to build a winning strategy for **Royal Challengers Bangalore (RCB)**. The analysis focuses on team performance, player impact, venue trends, toss decisions, and match-phase patterns to generate actionable insights.

## 🎯 Objectives
- Analyze RCB performance across seasons
- Identify **top run-scorers and wicket-takers**
- Compare performance while **chasing vs defending**
- Study **venue-wise** win trends and scoring patterns
- Evaluate **toss impact** on match results
- Provide data-backed strategy recommendations

## 🛠 Tech Stack
- **SQL (MySQL)**
- Dataset: IPL match + ball-by-ball data (CSV / Kaggle)

## 🗂 Dataset Description
### `matches.csv`
Contains match-level details such as:
- season, date, venue
- teams, toss winner, toss decision
- winner, win margin, result type

### `deliveries.csv`
Contains ball-by-ball details such as:
- match_id, innings, over, ball
- batter, bowler, runs, extras
- wicket type, player dismissed

## 🔍 Key SQL Analysis Performed
### ✅ Team Performance
- Season-wise win/loss trend for RCB
- Head-to-head performance vs top teams
- Chasing vs defending success rate

### ✅ Batting Insights
- Top RCB batters by total runs and strike rate
- Powerplay (1–6), Middle (7–15), Death (16–20) scoring analysis
- Best partnerships and consistency analysis

### ✅ Bowling Insights
- Top RCB bowlers by wickets and economy rate
- Powerplay and death overs wicket-taking impact
- Opponent wicket patterns (dismissal types)

### ✅ Toss & Venue Strategy
- Toss win vs match win relationship
- Venue-wise chasing success rate
- Average 1st innings score by venue

## 📌 Sample Insights (Example)
- RCB performs better chasing at specific high-scoring venues
- Certain bowlers are more effective in death overs (lower economy + higher wickets)
- Powerplay run rate has strong correlation with match outcome

## 🚀 Recommendations (Final Output)
- Prefer chasing at venues where chasing win % is high
- Use strike bowlers in powerplay to maximize early wickets
- Promote high strike-rate batters for death overs acceleration

## ▶️ How to Run
1. Import dataset into MySQL
2. Execute scripts in order from `SQL/01_data_cleaning.sql`
3. View results in SQL output tables / exported CSVs

## 👤 Author
**Ayush Nandwana**  
Data Analyst | SQL | Power BI  
