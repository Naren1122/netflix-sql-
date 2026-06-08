'''9.	Calculate the total count and percentage breakdown of Movies versus TV Shows added to the platform
for each release year over the last 15 years'''

SELECT 
    release_year,
   
    COUNT(*) AS total_content,
    
    -- 2. Count and percentage of Movies
    SUM(CASE WHEN type = 'Movie' THEN 1 ELSE 0 END) AS movie_count,
    ROUND(SUM(CASE WHEN type = 'Movie' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS movie_percentage,
    
    -- 3. Count and percentage of TV Shows
    SUM(CASE WHEN type = 'TV Show' THEN 1 ELSE 0 END) AS tv_show_count,
    ROUND(SUM(CASE WHEN type = 'TV Show' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS tv_show_percentage
FROM 
    netflix_titles
WHERE 
    -- Filter for the last 15 years dynamically relative to the current year
    release_year >= EXTRACT(YEAR FROM CURRENT_DATE) - 15
GROUP BY 
    release_year
ORDER BY 
    release_year DESC;

'''10.	Find the top 10 countries with the highest total volume of streaming content on the platform,
excluding unknown values.'''	

SELECT 
    country,
    COUNT(*) AS total_titles
FROM 
    netflix_titles
WHERE 
   
    country IS NOT NULL 
    AND country != '' 
    AND country != 'Unknown'
GROUP BY 
    country
-- Order from the highest volume to the lowest
ORDER BY 
    total_titles DESC
-- Restrict the output to only the top 10 records
LIMIT 10;


'''
11.	Generate a running cumulative total of all titles added to the platform over time, ordered 
chronologically by the date they were added.'''

WITH DailyAdditions AS (
    SELECT 
        date_added,
        COUNT(*) AS titles_added_today
    FROM 
        netflix_titles
    WHERE 
        date_added IS NOT NULL
    GROUP BY 
        date_added
)
SELECT 
    date_added,
    titles_added_today,
    -- Calculate the running cumulative total over chronological time
    SUM(titles_added_today) OVER (
        ORDER BY date_added 
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_total_catalog
FROM 
    DailyAdditions
ORDER BY 
    date_added ASC;


'''12.	Create a distribution profile of user satisfaction by grouping the vote_average column into 1-point
interval buckets and counting the total titles in each bucket.'''	

WITH PopularityQuartiles AS (
    SELECT 
        title,
        vote_average,
        vote_count,
        popularity,
        -- Slice the data into 4 equal groups based on popularity
        NTILE(4) OVER (ORDER BY popularity DESC) AS popularity_quartile
    FROM 
        netflix_titles
)
SELECT 
    popularity_quartile,
    COUNT(*) AS total_titles,
    MIN(popularity) AS min_popularity_in_tier,
    MAX(popularity) AS max_popularity_in_tier,
    ROUND(AVG(vote_average), 2) AS average_rating,
    ROUND(AVG(vote_count), 0) AS average_vote_count
FROM 
    PopularityQuartiles
GROUP BY 
    popularity_quartile
ORDER BY 
    popularity_quartile ASC;


'''
13.	Divide the catalog into popularity quartiles to compare the average critical rating and average 
vote count across different tiers of audience exposure.
'''	

SELECT 
    language,
    -- Count the number of titles available in each language
    COUNT(*) AS total_titles,
    -- Cast the double precision averages to numeric so ROUND() works perfectly
    ROUND(CAST(AVG(popularity) AS numeric), 2) AS average_popularity,
    ROUND(CAST(AVG(vote_count) AS numeric), 0) AS average_vote_count
FROM 
    netflix_titles
WHERE 
    -- Exclude English ('en') to look strictly at international content
    language != 'en' 
    AND language IS NOT NULL 
    AND language != ''
GROUP BY 
    language
ORDER BY 
    total_titles DESC
LIMIT 5;


'''14.	Identify the top 5 most common original languages on the platform excluding English, along 
with their average popularity and total vote counts.'''

SELECT 
    language,
    -- Total count to find the most common languages
    COUNT(*) AS total_titles,
    -- Average popularity (casted to numeric for rounding)
    ROUND(CAST(AVG(popularity) AS numeric), 2) AS average_popularity,
    -- Total sum of all votes accumulated by this language group
    SUM(vote_count) AS total_vote_counts
FROM 
    netflix_titles
WHERE 
    -- Exclude English and filter out blank/null values
    language != 'en' 
    AND language IS NOT NULL 
    AND language != ''
GROUP BY 
    language
ORDER BY 
    total_titles DESC
LIMIT 5;

'''15.	Isolate all outlier blockbuster movies whose production budget is greater than three standard
deviations above the global average budget.'''

WITH MovieBudgetStats AS (
    SELECT 
        AVG(budget) AS global_avg_budget,
        STDDEV(budget) AS global_stddev_budget
    FROM 
        netflix_titles
    WHERE 
        type = 'Movie' 
        AND budget > 0 -- Focus only on movies with real financial records
)
SELECT 
    t.show_id,
    t.title,
    t.release_year,
    t.budget,
    ROUND(CAST(s.global_avg_budget AS numeric), 2) AS movie_market_avg,
    ROUND(CAST((s.global_avg_budget + (3 * s.global_stddev_budget)) AS numeric), 2) AS outlier_threshold
FROM 
    netflix_titles t
CROSS JOIN 
    MovieBudgetStats s
WHERE 
    t.type = 'Movie' 
    -- Keep only movies that cross the 3 standard deviations line
    AND t.budget > (s.global_avg_budget + (3 * s.global_stddev_budget))
ORDER BY 
    t.budget DESC;


