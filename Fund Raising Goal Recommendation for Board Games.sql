

/* 1.	Are the goals for dollars raised significantly different between campaigns that are successful and unsuccessful? */

select 
	AVG(goal),
	outcome from campaign 
WHERE outcome = 'failed' OR outcome = 'successful'
group by outcome;


/*2.	What are the top/bottom 3 categories with the most backers? What are the top/bottom 3 subcategories by backers? */

-- top 3 categories with most backers
SELECT
	category.name,
    SUM(backers)
FROM campaign
	LEFT JOIN sub_category
		ON campaign.sub_category_id = sub_category.id
	LEFT JOIN category
		ON sub_category.category_id = category.id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 3;

-- bottom  3 categories with most backers 
SELECT
	category.name,
    SUM(backers)
FROM campaign
	LEFT JOIN sub_category
		ON campaign.sub_category_id = sub_category.id
	LEFT JOIN category
		ON sub_category.category_id = category.id
GROUP BY 1
ORDER BY 2 ASC
LIMIT 3;

-- top 3 sub-categories with most backers
SELECT
	sub_category.name,
    SUM(backers)
FROM campaign
	LEFT JOIN sub_category
		ON campaign.sub_category_id = sub_category.id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 3;

-- bottom 3 sub-categories with most backers
SELECT
	sub_category.name,
    SUM(backers)
FROM campaign
	LEFT JOIN sub_category
		ON campaign.sub_category_id = sub_category.id
GROUP BY 1
ORDER BY 2 ASC
LIMIT 3;

/*3.	What are the top/bottom 3 categories that have raised the most money? 
What are the top/bottom 3 subcategories that have raised the most money? */

-- top 3 categories with most money raised
SELECT
	category.name,
    SUM(pledged) As Total_pledged
FROM campaign
	LEFT JOIN sub_category
		ON campaign.sub_category_id = sub_category.id
	LEFT JOIN category
		ON sub_category.category_id = category.id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 3;

-- bottom 3 categories with most money raised
SELECT
	category.name,
    SUM(pledged) As Total_pledged
FROM campaign
	LEFT JOIN sub_category
		ON campaign.sub_category_id = sub_category.id
	LEFT JOIN category
		ON sub_category.category_id = category.id
GROUP BY 1
ORDER BY 2 ASC
LIMIT 3;

-- top 3 sub-categories with most money raised
SELECT
	sub_category.name,
    SUM(pledged) As Total_pledged
FROM campaign
	LEFT JOIN sub_category
		ON campaign.sub_category_id = sub_category.id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 3;

-- bottom 3 sub-categories with most money raised
SELECT
	sub_category.name,
    SUM(pledged) As Total_pledged
FROM campaign
	LEFT JOIN sub_category
		ON campaign.sub_category_id = sub_category.id
GROUP BY 1
ORDER BY 2 ASC
LIMIT 3;


/* Modified queries for visualization*/ 

-- ranking of sub_category based based on total pledged dollars and backers. 
SELECT
	sub_category.name,
    SUM(pledged) As Total_pledged, 
    SUM(backers)
FROM campaign
	LEFT JOIN sub_category
		ON campaign.sub_category_id = sub_category.id
GROUP BY 1
ORDER BY 2 DESC;



/* 4.	What was the amount the most successful board game company raised? How many backers did they have? */

SELECT * FROM sub_category
WHERE name LIKE '%game%';

SELECT
	campaign.name,
    pledged,
    backers
FROM campaign LEFT JOIN sub_category
	ON campaign.sub_category_id = sub_category.id
WHERE sub_category.name = 'Tabletop Games'
AND outcome = 'successful'
ORDER BY pledged DESC
LIMIT 1;


/* 5.	Rank the top three countries with the most successful campaigns in terms of dollars (total amount pledged), 
and in terms of the number of campaigns backed. */

SELECT
	country.name,
    SUM(pledged)
FROM campaign LEFT JOIN country
	ON campaign.country_id = country.id
GROUP BY 1
ORDER by 2 DESC
LIMIT 3
;

/* modified queries for data visualiation*/
-- A ranking of country based on total pledged with counts of campaigns and outcome 
SELECT
	country.name,
    outcome,
    COUNT(DISTINCT campaign.id),
    SUM(pledged)
FROM campaign LEFT JOIN country
	ON campaign.country_id = country.id
WHERE backers > 0
GROUP BY 1,2
ORDER by 4 DESC
LIMIT 100;

/*6.	Do longer, or shorter campaigns tend to raise more money? Why? */

SELECT
	DATEDIFF(deadline, launched) As Duration,
    pledged
FROM campaign;

/*Final Business Questions
/1.	What is a realistic Kickstarter campaign goal (in dollars) should the company aim to raise?
2.	How many backers will be needed to meet their goal?
3.	How many backers can the company realistically expect, based on trends in their category? */



/* In order to answer the above three questions, we need to extract the counts of backers and total 
dollar pledged of successful tabletop campaigns. Then to analyze the median and average dollar pledged to identify the
reasonable funding goal. Also to establish a regression analysis to find out the number of backers needed to meet the goal.  */
SELECT
	backers,
    pledged
FROM campaign LEFT JOIN sub_category
	ON campaign.sub_category_id = sub_category.id
WHERE sub_category.name = 'Tabletop Games'
AND outcome = 'successful';

/* Find the average number of backers of boardgame campaigns*/
SELECT
	AVG(backers)
FROM campaign LEFT JOIN sub_category
	ON campaign.sub_category_id = sub_category.id
WHERE sub_category.name = 'Tabletop Games'; -- 446.87 backers

/* apply 447 backers to regression analysis to find out the estimated funding can be raised */

/* Other Queries that help analyze the dataset */

/* proportions of currencies */
select
	currency_id, 
    count(id)
FROM campaign
GROUP BY 1;

/*last deadline. Tells the timeliness of the dataset*/
select min(deadline) from campaign;