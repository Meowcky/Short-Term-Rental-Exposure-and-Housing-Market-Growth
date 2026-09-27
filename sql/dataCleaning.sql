-- ----------------------------------------------------------
--                       Data Cleaning 
-- ----------------------------------------------------------

-- ------------------------ Content ------------------------
-- 1. Create blank table
-- 2. Insert data from raw file to table
-- 3. Delete duplicate data
--    3.1 Check duplicate data
--    3.2 Create stage2 table to handle duplicate
--    3.3 Insert data to stage2 table
--    3.4 Add unique record_id
--    3.5 Copy data with unique record_id
-- 4. Check whether there are any duplicate record IDs
-- 5. Create clean drop table
--    5.1 Insert data to a clean drop table
-- ----------------------------------------------------------

-- 1. Create blank table
CREATE TABLE `listinglondonStage1` (
  `id` int DEFAULT NULL,
  `name` varchar(500) DEFAULT NULL,
  `host_id` int DEFAULT NULL,
  `host_profile_id` varchar(100) DEFAULT NULL,
  `host_name` varchar(255) DEFAULT NULL,
  `neighbourhood_group` varchar(255) DEFAULT NULL,
  `neighbourhood` varchar(255) DEFAULT NULL,
  `latitude` decimal(10,7) DEFAULT NULL,
  `longitude` decimal(10,7) DEFAULT NULL,
  `room_type` varchar(100) DEFAULT NULL,
  `price` decimal(10,2) DEFAULT NULL,
  `minimum_nights` int DEFAULT NULL,
  `number_of_reviews` int DEFAULT NULL,
  `last_review` varchar(50) DEFAULT NULL,
  `reviews_per_month` decimal(10,2) DEFAULT NULL,
  `calculated_host_listings_count` int DEFAULT NULL,
  `availability_365` int DEFAULT NULL,
  `number_of_reviews_ltm` int DEFAULT NULL,
  `license` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 2. Insert data from raw file to table
INSERT listinglondonStage1
SELECT *
FROM listinglondon;

-- 3. Delete duplicate data

-- 3.1 Check duplicate data
WITH duplicate_cte AS
(
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY
                   id,
                   name,
                   host_id,
                   host_profile_id,
                   host_name,
                   neighbourhood_group,
                   neighbourhood,
                   latitude,
                   longitude,
                   room_type,
                   price,
                   minimum_nights,
                   number_of_reviews,
                   last_review,
                   reviews_per_month,
                   calculated_host_listings_count,
                   availability_365,
                   number_of_reviews_ltm,
                   license
           ) AS row_num
    FROM listingLondonStage1
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

-- 3.2 Create stage2 table to handle duplicate
CREATE TABLE `listinglondonstage2` (
  `id` int DEFAULT NULL,
  `name` varchar(500) DEFAULT NULL,
  `host_id` int DEFAULT NULL,
  `host_profile_id` varchar(100) DEFAULT NULL,
  `host_name` varchar(255) DEFAULT NULL,
  `neighbourhood_group` varchar(255) DEFAULT NULL,
  `neighbourhood` varchar(255) DEFAULT NULL,
  `latitude` decimal(10,7) DEFAULT NULL,
  `longitude` decimal(10,7) DEFAULT NULL,
  `room_type` varchar(100) DEFAULT NULL,
  `price` decimal(10,2) DEFAULT NULL,
  `minimum_nights` int DEFAULT NULL,
  `number_of_reviews` int DEFAULT NULL,
  `last_review` varchar(50) DEFAULT NULL,
  `reviews_per_month` decimal(10,2) DEFAULT NULL,
  `calculated_host_listings_count` int DEFAULT NULL,
  `availability_365` int DEFAULT NULL,
  `number_of_reviews_ltm` int DEFAULT NULL,
  `license` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 3.3 Insert data to stage2 table
INSERT INTO listinglondonstage2 (
    id,
    name,
    host_id,
    host_profile_id,
    host_name,
    neighbourhood_group,
    neighbourhood,
    latitude,
    longitude,
    room_type,
    price,
    minimum_nights,
    number_of_reviews,
    last_review,
    reviews_per_month,
    calculated_host_listings_count,
    availability_365,
    number_of_reviews_ltm,
    license
)
SELECT
    id,
    name,
    host_id,
    host_profile_id,
    host_name,
    neighbourhood_group,
    neighbourhood,
    latitude,
    longitude,
    room_type,
    price,
    minimum_nights,
    number_of_reviews,
    last_review,
    reviews_per_month,
    calculated_host_listings_count,
    availability_365,
    number_of_reviews_ltm,
    license
FROM (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY
                   id,
                   name,
                   host_id,
                   host_profile_id,
                   host_name,
                   neighbourhood_group,
                   neighbourhood,
                   latitude,
                   longitude,
                   room_type,
                   price,
                   minimum_nights,
                   number_of_reviews,
                   last_review,
                   reviews_per_month,
                   calculated_host_listings_count,
                   availability_365,
                   number_of_reviews_ltm,
                   license
               ORDER BY id
           ) AS row_num
    FROM listingLondonStage1
) AS duplicate_cte
WHERE row_num = 1;

-- 3.4 Add unique record_id
ALTER TABLE listinglondonstage2
ADD COLUMN record_id INT FIRST;

SET @row_number = 0;

-- 3.5 Copy data with unique record_id
UPDATE listinglondonstage2
SET record_id = (@row_number := @row_number + 1)
ORDER BY id, name, host_id;

ALTER TABLE listinglondonstage2
ADD UNIQUE (record_id);

-- 4. Check whether there are any duplicate record IDs
SELECT record_id, COUNT(*) AS count
FROM listinglondonstage2
GROUP BY record_id
HAVING COUNT(*) > 1;

-- 5. Create clean drop table
CREATE TABLE `listingLondonCleanDrop` (
  `record_id` int DEFAULT NULL,
  `id` int DEFAULT NULL,
  `host_id` int DEFAULT NULL,
  `host_profile_id` varchar(50) DEFAULT NULL,
  `neighbourhood_group` varchar(255) DEFAULT NULL,
  `neighbourhood` varchar(255) DEFAULT NULL,
  `latitude` decimal(10,7) DEFAULT NULL,
  `longitude` decimal(10,7) DEFAULT NULL,
  `room_type` varchar(100) DEFAULT NULL,
  `calculated_host_listings_count` int DEFAULT NULL,
  UNIQUE KEY `record_id` (`record_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 5.1 Insert data to a clean drop table
INSERT INTO listingLondonCleanDrop (
    record_id,
    id,
    host_id,
    host_profile_id,
    neighbourhood_group,
    neighbourhood,
    latitude,
    longitude,
    room_type,
    calculated_host_listings_count
)
SELECT
    record_id,
    id,
    host_id,
    host_profile_id,
    neighbourhood_group,
    neighbourhood,
    latitude,
    longitude,
    room_type,
    calculated_host_listings_count
FROM listinglondonstage2;