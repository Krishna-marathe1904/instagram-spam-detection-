create database instagram_db;
use instagram_db;

CREATE TABLE profiles (
    profile_pic BOOLEAN,
    username_numeric_ratio FLOAT,
    fullname_word_count INT,
    fullname_numeric_ratio FLOAT,
    name_eq_username BOOLEAN,
    desc_length INT,
    has_external_url BOOLEAN,
    is_private BOOLEAN,
    post_count INT,
    follower_count INT,
    following_count INT,
    is_fake BOOLEAN
);

-- Check total records
SELECT COUNT(*) AS total_profiles FROM profiles;

-- View sample data
SELECT * FROM profiles LIMIT 5;

-------------------------- 1. Basic Profile Statistics----------------------------------

-- (1) How many fake vs genuine profiles are in our dataset?
SELECT 
    IF(is_fake=1, 'Fake', 'Genuine') AS profile_type,
    COUNT(*) AS count,
    ROUND(COUNT(*)*100.0/(SELECT COUNT(*) FROM profiles), 2) AS percentage
FROM profiles
GROUP BY is_fake;

-- (2) What's the average number of followers for each profile type?
SELECT 
    IF(is_fake=1, 'Fake', 'Genuine') AS profile_type,
    ROUND(AVG(follower_count), 2) AS avg_followers,
    ROUND(AVG(following_count), 2) AS avg_following,
    ROUND(AVG(post_count), 2) AS avg_posts
FROM profiles
GROUP BY is_fake;


-------------------------- 2. Profile Characteristics Analysis----------------------------------

-- (3) How often do profiles have pictures?
SELECT 
    IF(is_fake=1, 'Fake', 'Genuine') AS profile_type,
    SUM(profile_pic) AS with_profile_pic,
    COUNT(*) - SUM(profile_pic) AS without_profile_pic,
    ROUND(SUM(profile_pic)*100.0/COUNT(*), 2) AS percentage_with_pic
FROM profiles
GROUP BY is_fake;

-- (4) What percentage of profiles have external URLs?
SELECT 
    IF(is_fake=1, 'Fake', 'Genuine') AS profile_type,
    SUM(has_external_url) AS with_url,
    COUNT(*) - SUM(has_external_url) AS without_url,
    ROUND(SUM(has_external_url)*100.0/COUNT(*), 2) AS percentage_with_url
FROM profiles
GROUP BY is_fake;


-------------------------- 3. Username and Naming Patterns----------------------------------

-- (5)Do fake profiles use more numbers in usernames?
SELECT 
    IF(is_fake=1, 'Fake', 'Genuine') AS profile_type,
    ROUND(AVG(username_numeric_ratio)*100, 2) AS avg_numeric_percentage,
    MIN(username_numeric_ratio*100) AS min_numeric,
    MAX(username_numeric_ratio*100) AS max_numeric
FROM profiles
GROUP BY is_fake;

-- (6) How often do profile names match usernames?
SELECT 
    IF(is_fake=1, 'Fake', 'Genuine') AS profile_type,
    SUM(name_eq_username) AS name_matches_username,
    ROUND(SUM(name_eq_username)*100.0/COUNT(*), 2) AS percentage_match
FROM profiles
GROUP BY is_fake;


-------------------------- 4. Engagement Metrics----------------------------------

-- (7) What's the average follower-to-following ratio?
SELECT 
    IF(is_fake=1, 'Fake', 'Genuine') AS profile_type,
    ROUND(AVG(follower_count/NULLIF(following_count, 1)), 2) AS follower_following_ratio
FROM profiles
WHERE following_count > 0
GROUP BY is_fake;

-- (8) Which profiles have suspiciously high follower counts with few posts?
SELECT 
    IF(is_fake=1, 'Fake', 'Genuine') AS profile_type,
    COUNT(*) AS suspicious_profiles,
    ROUND(COUNT(*)*100.0/SUM(COUNT(*)) OVER(), 2) AS percentage
FROM profiles
WHERE follower_count > 1000 AND post_count < 10
GROUP BY is_fake;



-------------------------- 5. Advanced Pattern Detection----------------------------------

-- (9) Can we identify potentially mislabeled genuine profiles?
SELECT 
    COUNT(*) AS potentially_fake
FROM profiles
WHERE is_fake = 0 AND (
    (username_numeric_ratio > 0.4) OR
    (follower_count > 10000 AND following_count < 100) OR
    (following_count > 5000 AND follower_count < 100) OR
    (desc_length < 10 AND post_count > 100)
);
