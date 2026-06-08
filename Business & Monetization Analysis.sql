'''17.	Build a financial leaderboard displaying the top 10 movies with a budget over 10 million dollars
ranked by their absolute return on investment percentage.'''

SELECT 
    show_id,
    title,
    budget,
    revenue,
    -- Calculate ROI %: ((Revenue - Budget) / Budget) * 100
    ROUND(
        CAST(((revenue - budget) * 100.0 / budget) AS numeric), 
        2
    ) AS roi_percentage
FROM 
    netflix_titles
WHERE 
    type = 'Movie'
    AND budget > 10000000 -- Excludes anything 10M or below
ORDER BY 
    roi_percentage DESC
LIMIT 10;

'''18.	Identify the top 5 high-value directors who have directed at least 3 movies, ordered by the total
cumulative global revenue their films have generated.'''

SELECT 
    director,
    -- Count total movies to verify they hit our minimum requirement
    COUNT(*) AS total_movies_directed,
    -- Sum total revenue across all their projects
    SUM(revenue) AS cumulative_global_revenue,
    -- Provide an average baseline as extra operational context
    ROUND(CAST(AVG(revenue) AS numeric), 2) AS average_revenue_per_movie
FROM 
    netflix_titles
WHERE 
    type = 'Movie'
    AND director IS NOT NULL 
    AND director != ''
GROUP BY 
    director
HAVING 
    COUNT(*) >= 3 -- Keep only directors with a track record of 3+ movies
ORDER BY 
    cumulative_global_revenue DESC
LIMIT 5;

'''19.	Calculate the average audience popularity score generated per million dollars of budget spent
for every distinct genre that has at least 10 titles.'''

SELECT 
    genres,
    COUNT(*) AS total_titles,
    -- Average popularity generated per $1M of budget spent
    ROUND(
        CAST(AVG(popularity / (budget / 1000000.0)) AS numeric), 
        4
    ) AS popularity_per_million_spent
FROM 
    netflix_titles
WHERE 
    budget > 0 -- Essential safeguard to completely eliminate Division-by-Zero errors
GROUP BY 
    genres
HAVING 
    COUNT(*) >= 10 -- Only target established genres with 10 or more titles
ORDER BY 
    popularity_per_million_spent DESC;


'''20.	Uncover hidden gem movies that have an exceptional user rating above 7.5 and over 1,000 votes, 
but fall below the platforms median popularity score. '''

WITH MedianPopularity AS (
    -- Calculate the exact middle baseline of platform popularity using a percentile window function
    SELECT 
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY popularity) AS platform_median_popularity
    FROM 
        netflix_titles
)
SELECT 
    t.show_id,
    t.title,
    t.vote_average,
    t.vote_count,
    t.popularity,
    ROUND(CAST(m.platform_median_popularity AS numeric), 4) AS platform_median_popularity_cutoff
FROM 
    netflix_titles t
CROSS JOIN 
    MedianPopularity m
WHERE 
    t.type = 'Movie'
    AND t.vote_average > 7.5 -- Must have exceptional critical acclaim
    AND t.vote_count > 1000   -- Must have enough votes to prove it isn't an accidental fluke
    AND t.popularity < m.platform_median_popularity -- Must be criminally under-seen/under-promoted
ORDER BY 
    t.vote_average DESC;


'''21.	Compare the combined average popularity, user rating, and total revenue of original 
English-language content against all non-English international content combined. '''

SELECT 
    CASE 
        WHEN language = 'en' THEN 'Original English Content'
        ELSE 'Non-English International Content'
    END AS content_classification,
    COUNT(*) AS total_titles,
    ROUND(CAST(AVG(popularity) AS numeric), 2) AS average_popularity,
    ROUND(CAST(AVG(vote_average) AS numeric), 2) AS average_user_rating,
    SUM(revenue) AS total_global_revenue,
    ROUND(CAST(AVG(revenue) AS numeric), 2) AS average_revenue_per_title
FROM 
    netflix_titles
WHERE 
    language IS NOT NULL 
    AND language != ''
GROUP BY 
    CASE 
        WHEN language = 'en' THEN 'Original English Content'
        ELSE 'Non-English International Content'
    END;


'''22.	Determine the optimal content release schedule by ranking the calendar months based on the
total volume and average popularity of the titles dropped.'''

WITH MonthlyIngestionStats AS (
    SELECT 
        -- Safely pull the month number from the text date
        EXTRACT(MONTH FROM CAST(NULLIF(TRIM(date_added), '') AS DATE)) AS release_month_number,
        COUNT(*) AS total_titles_dropped,
        AVG(popularity) AS average_popularity_score
    FROM 
        netflix_titles
    WHERE 
        date_added IS NOT NULL 
        AND TRIM(date_added) != ''
    GROUP BY 
        EXTRACT(MONTH FROM CAST(NULLIF(TRIM(date_added), '') AS DATE))
)
SELECT 
    release_month_number,
    total_titles_dropped,
    ROUND(CAST(average_popularity_score AS numeric), 2) AS average_popularity,
    -- Rank months by total volume of drops
    RANK() OVER (ORDER BY total_titles_dropped DESC) AS volume_rank,
    -- Rank months by audience engagement/hype
    RANK() OVER (ORDER BY average_popularity_score DESC) AS popularity_rank
FROM 
    MonthlyIngestionStats
ORDER BY 
    popularity_rank ASC;


'''23.	Segment the entire catalog into strategic marketing quadrants classifying each title as 
either a Global Blockbuster, Cult Classic, Mainstream Flop, or Niche/Indie piece based on ratings 
and vote counts.'''

WITH PlatformBaselines AS (
    -- Calculate standard benchmarks to slice our matrix evenly
    SELECT 
        AVG(vote_average) AS global_avg_rating,
        -- Using 500 votes as an operational threshold for high public exposure
        500 AS exposure_threshold 
    FROM 
        netflix_titles
)
SELECT 
    t.show_id,
    t.title,
    t.vote_average,
    t.vote_count,
    CASE 
        WHEN t.vote_count >= b.exposure_threshold AND t.vote_average >= b.global_avg_rating THEN 'Global Blockbuster'
        WHEN t.vote_count < b.exposure_threshold AND t.vote_average >= b.global_avg_rating THEN 'Cult Classic / Niche Gem'
        WHEN t.vote_count >= b.exposure_threshold AND t.vote_average < b.global_avg_rating THEN 'Mainstream Flop'
        ELSE 'Niche / Unknown Indie'
    END AS marketing_quadrant
FROM 
    netflix_titles t
CROSS JOIN 
    PlatformBaselines b
ORDER BY 
    t.vote_count DESC;



'''24.	Assess financial risk by finding the percentage of movies within each genre combination that 
completely failed to break even on their production budget.'''

SELECT 
    genres,
    COUNT(*) AS total_tracked_movies,
    -- Count how many movies made less revenue than their original budget cost
    SUM(CASE WHEN revenue < budget THEN 1 ELSE 0 END) AS failed_to_breakeven_count,
    -- Calculate the exact percentage of commercial failure
    ROUND(
        CAST(SUM(CASE WHEN revenue < budget THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS numeric), 
        2
    ) AS financial_failure_rate_percentage
FROM 
    netflix_titles
WHERE 
    type = 'Movie'
    -- Only evaluate records where full financial tracking profiles are complete
    AND budget > 0 
    AND revenue > 0
GROUP BY 
    genres
HAVING 
    COUNT(*) >= 5 -- Only look at genre paths with a realistic sample size
ORDER BY 
    financial_failure_rate_percentage DESC;


'''25.	Track content quality trajectory by calculating the year-over-year percentage change in the
platforms average user ratings and popularity metrics.'''
	
WITH YearlyAverages AS (
    SELECT 
        release_year,
        AVG(vote_average) AS avg_rating,
        AVG(popularity) AS avg_popularity
    FROM 
        netflix_titles
    GROUP BY 
        release_year
)
SELECT 
    release_year,
    ROUND(CAST(avg_rating AS numeric), 2) AS current_year_avg_rating,
    ROUND(CAST(avg_popularity AS numeric), 2) AS current_year_avg_popularity,
    
    -- 1. Year-Over-Year Change in Critical User Ratings
    ROUND(
        CAST(
            (avg_rating - LAG(avg_rating) OVER (ORDER BY release_year ASC)) 
            * 100.0 / LAG(avg_rating) OVER (ORDER BY release_year ASC) 
        AS numeric), 
        2
    ) AS yoy_rating_pct_change,
    
    -- 2. Year-Over-Year Change in Audience Hype/Popularity
    ROUND(
        CAST(
            (avg_popularity - LAG(avg_popularity) OVER (ORDER BY release_year ASC)) 
            * 100.0 / LAG(avg_popularity) OVER (ORDER BY release_year ASC) 
        AS numeric), 
        2
    ) AS yoy_popularity_pct_change    
FROM 
    YearlyAverages
ORDER BY 
    release_year DESC;