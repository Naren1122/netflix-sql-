''' 
1.  Write a query to remove the accidental leading whitespace and trim all trailing or leading whitespaces from its text values. 
'''

SELECT 
    show_id,
    TRIM(type) AS type,
    TRIM(title) AS title,
    TRIM(director) AS director,
    TRIM("cast_members") AS cast_members,
    TRIM(country) AS country,
    date_added,
    release_year, 
    rating, 
    duration,
    TRIM(genres) AS genres,
    TRIM(language) AS language,
    TRIM(description) AS description,
    popularity,
    vote_count, 
    vote_average, 
    budget,
    revenue 
FROM 
    netflix_titles;



'''2. Deduplicate the dataset by identifying movies with the exact same title and release year, 
keeping only the record that has the highest popularity score.
'''	
WITH RankedMovies AS (
    SELECT 
        show_id,
        type,
        title,
        director,
        cast_members,
        country,
        date_added,
        release_year,
        rating,
        duration,
        genres,
        language,
        description,
        popularity,
        vote_count,
        vote_average,
        budget,
        revenue,
        ROW_NUMBER() OVER (
            PARTITION BY title, release_year
            ORDER BY popularity DESC
        ) AS row_num
    FROM netflix_titles
)
SELECT 
    type,
    title,
    rating,
    duration,
    genres,
    language,
    description
FROM RankedMovies
WHERE row_num = 1;

'''
3.	Replace all missing or null values in the director and country columns with the fallback
placeholders 'Unknown' and 'Global Release' respectively.'''

SELECT 
    show_id,
    type,
    title,
    COALESCE(director, 'Unknown') AS director,
    cast_members,
    COALESCE(country, 'Global Release') AS country,
    date_added,
    release_year,
    rating,
    duration,
    genres,
    language,
    description,
    popularity,
    vote_count,
    vote_average,
    budget,
    revenue
FROM 
    netflix_titles;

'''4.	Extract only the primary producing nation by isolating the first country listed before the 
comma in the country column.'''	

SELECT 
    type,
    title,
    director,
    cast_members,
    -- Extract everything before the first comma, or keep the full text if there is no comma
    CASE 
        WHEN country LIKE '%,%' THEN SUBSTRING(country FROM 1 FOR POSITION(',' IN country) - 1)
        ELSE country 
    END AS primary_country

FROM 
    netflix_titles;


'''
5. Convert the text-based date_added column into a proper SQL Date format and break it down into
year, month, and day-of-week attributes.
'''	

SELECT 
    show_id,
    type,
    title,
    -- 1. Convert the text column to an actual DATE data type
    CAST(date_added AS DATE) AS clean_date_added,
    
    -- 2. Extract the calendar year
    EXTRACT(YEAR FROM CAST(date_added AS DATE)) AS added_year,
    
    -- 3. Extract the calendar month number (1 to 12)
    EXTRACT(MONTH FROM CAST(date_added AS DATE)) AS added_month,
    
    -- 4. Extract the day of the week (e.g., Sunday = 0 or 1 depending on system)
    EXTRACT(DOW FROM CAST(date_added AS DATE)) AS added_day_of_week
FROM 
    netflix_titles;

'''6.	Write an audit query to verify that the duration column is completely empty across all rows and
replace it conditionally with an estimated value based on genre.'''	

SELECT 
    COUNT(*) AS total_records,
    COUNT(duration) AS non_null_durations,
    SUM(CASE WHEN duration IS NULL THEN 1 ELSE 0 END) AS null_count,
    (SUM(CASE WHEN duration IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) AS null_percentage
FROM 
    netflix_titles;


'''7.Calculate the exact percentage of titles where the budget, revenue, or both are recorded as 
zero, segmented by content type.
'''	

SELECT 
    type,
    COUNT(*) AS total_titles,
    -- 1. Track titles with zero budget
    SUM(CASE WHEN budget = 0 THEN 1 ELSE 0 END) AS zero_budget_count,
    ROUND(SUM(CASE WHEN budget = 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS zero_budget_percentage,
    
    -- 2. Track titles with zero revenue
    SUM(CASE WHEN revenue = 0 THEN 1 ELSE 0 END) AS zero_revenue_count,
    ROUND(SUM(CASE WHEN revenue = 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS zero_revenue_percentage,
    
    -- 3. Track titles where both values are missing/zero
    SUM(CASE WHEN budget = 0 AND revenue = 0 THEN 1 ELSE 0 END) AS both_zero_count,
    ROUND(SUM(CASE WHEN budget = 0 AND revenue = 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS both_zero_percentage
FROM 
    netflix_titles
GROUP BY 
    type;

'''8.	Filter out any records where the title or description columns contain non-standard alphanumeric 
characters or corrupted text symbols.'''	

SELECT title, description
FROM netflix_titles
WHERE COALESCE(title, '') ~ '[^[:alnum:][:space:][:punct:]]'
   OR COALESCE(description, '') ~ '[^[:alnum:][:space:][:punct:]]';