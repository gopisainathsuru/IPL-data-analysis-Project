use ipl;

show tables from ipl;
select * from ipl_bidder_details;
select * from ipl_bidder_points;
select * from ipl_bidding_details;
select * from ipl_match;
select * from ipl_match_schedule;
select * from ipl_player;
select * from ipl_stadium;
select * from ipl_team;
select * from ipl_team_players;
select * from ipl_team_standings;
select * from ipl_tournament;
select * from ipl_user;

-- 1. Show the percentage of wins of each bidder in the order of highest to lowest 
-- percentage.

select bidder_id, 
round((count(if(bid_status='Won',1,null))/count(BIDDER_ID))*100,2) as Won_Percentage
from ipl_bidding_details 
group by BIDDER_ID
order by Won_Percentage desc;

-- 2. Display the number of matches conducted at each stadium with stadium name, city 
-- from the database.

select t1.stadium_name,
t1.city,
count(t2.match_id) as Number_of_matches
from ipl_stadium t1 left join ipl_match_schedule t2 using(stadium_id)
group by t1.STADIUM_NAME,t1.CITY;


-- 3. In a given stadium, what is the percentage of wins by a team which has won the 
-- toss?
-- analysis
# Edge Case: where count of ipl_match is 120 but count of ipl_match_schedule is 122 (where 2 scheduled matches got cancelled)
# scheduled_id = (10082, 10008)  and match_id = (1110, 1016) are cancelled but count in the total column to get the percentage

-- win by a team and won the toss : calculated by win_team and win_toss / total(win_team and win_toss | lost_team and lost_toss | got_cancelled)

select C.STADIUM_NAME,
round((count(if(MATCH_WINNER = TOSS_WINNER,1,null))/count(*))*100,2) as won_percentage
from IPL_MATCH A inner join IPL_MATCH_SCHEDULE B inner join IPL_STADIUM C
on A.MATCH_ID = B.MATCH_ID and B.STADIUM_ID = C.STADIUM_ID
group by C.STADIUM_ID;

-- 4. Show the total bids along with bid team and team name.

select t1.bid_team, t2.team_name, count(*) as total_bids
from ipl_bidding_details t1 inner join ipl_team t2 on t1.bid_team=t2.team_id
group by t1.bid_team,t2.team_name order by t1.bid_team;

-- 5. Show the team id who won the match as per the win details.

select TEAM_ID, TEAM_NAME,WIN_DETAILS
from IPL_MATCH A inner join IPL_TEAM B
on A.WIN_DETAILS like concat('%',B.REMARKS,'%');

-- 6. Display total matches played, total matches won and total matches lost by team 
-- along with its team name.

select t1.team_id, team_name, sum(matches_played), sum(matches_won), sum(matches_lost) from ipl_team_standings t1 left join ipl_team t2 using(team_id) group by t1.team_id,team_name;

-- 7. Display the bowlers for Mumbai Indians team.

select t1.team_id, t1.team_name, t3.player_id, t3.player_name
from ipl_team t1 join ipl_team_players t2 join ipl_player t3 on (t1.team_id=t2.team_id and t2.player_id=t3.player_id)
where t2.player_role ='Bowler' and t1.team_name='Mumbai Indians';

-- 8. How many all-rounders are there in each team, Display the teams with more than 4 
-- all-rounder in descending order.

select replace(REMARKS,'TEAM - ','') as REMARKS, count(*) as total
from IPL_TEAM_PLAYERS
where PLAYER_ROLE like '%All-Rounder%'
group by REMARKS
having total > 4
order by total desc;