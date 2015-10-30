PLAYER_STATS = load '../csv/part-r-00000' using PigStorage(',') as (name:chararray, country:chararray, span:chararray, matches:int, inns:int, NO:int, runs:int, HS:int, average:float, hundreds:int, fifties:int, zeroes:int, format:chararray, skill:chararray);
POPULATION_1 = load '../csv/population.csv' using PigStorage(',') as (rank:int, country:chararray, population:int);

--by_format_skill_and_runs = group PLAYER_STATS by (format, skill, runs);
--dump by_format_skill_and_runs;

TEST = filter PLAYER_STATS by (format == 'Test');
TEST_BATTING = filter TEST by (skill == 'Batting');
TEST_BATTING_ORDERED = order TEST_BATTING by runs desc;

-- All Test Batsmen Ever.. 
TEST_BATTING_SUMMARY = foreach TEST_BATTING_ORDERED generate name, country, runs;

PLAYER_COUNTRY_RANK_TOTAL = join TEST_BATTING_SUMMARY by country left outer, POPULATION_1 by country;
RANK_GROUPING = group PLAYER_COUNTRY_RANK_TOTAL by rank;
BY_RANK_COUNTS = foreach RANK_GROUPING generate 
    FLATTEN(group) AS (rank),
    COUNT(PLAYER_COUNTRY_RANK_TOTAL) AS rank_count;
store BY_RANK_COUNTS into 'myoutput_total' using PigStorage (',');

-- Top 100 Test Batsmen..
TOP_100_TEST_BATSMEN = limit TEST_BATTING_ORDERED 100;

TEST_BATTING_SUMMARY = foreach TOP_100_TEST_BATSMEN generate name, country, runs;
PLAYER_COUNTRY_RANK_TOTAL = join TEST_BATTING_SUMMARY by country left outer, POPULATION_1 by country;
RANK_GROUPING = group PLAYER_COUNTRY_RANK_TOTAL by rank;

BY_RANK_COUNTS = foreach RANK_GROUPING generate
    FLATTEN(group) AS (rank),
    COUNT(PLAYER_COUNTRY_RANK_TOTAL) AS rank_count;

store BY_RANK_COUNTS into 'myoutput_100' using PigStorage (',');

-- Top 10 Test Batsmen..
TOP_10_TEST_BATSMEN = limit TEST_BATTING_ORDERED 10;

TEST_BATTING_SUMMARY = foreach TOP_10_TEST_BATSMEN generate name, country, runs;
PLAYER_COUNTRY_RANK_TOTAL = join TEST_BATTING_SUMMARY by country left outer, POPULATION_1 by country;
RANK_GROUPING = group PLAYER_COUNTRY_RANK_TOTAL by rank;

BY_RANK_COUNTS = foreach RANK_GROUPING generate
    FLATTEN(group) AS (rank),
    COUNT(PLAYER_COUNTRY_RANK_TOTAL) AS rank_count;

store BY_RANK_COUNTS into 'myoutput_10' using PigStorage (',');
