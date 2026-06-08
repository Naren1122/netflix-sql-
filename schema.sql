
CREATE TABLE netflix_titles (
    show_id INT PRIMARY KEY,
    type VARCHAR(50),
    title VARCHAR(500),
    director VARCHAR(500),
    cast_members TEXT,           
    country VARCHAR(500),
    date_added DATE,              
    release_year INT,
    rating float,
    duration NUMERIC,             
    genres VARCHAR(500),
    language VARCHAR(100),
    description TEXT,
    popularity float,
    vote_count INT,
    vote_average NUMERIC(5,3),
    budget BIGINT,                
    revenue BIGINT                
);


select * from netflix_titles