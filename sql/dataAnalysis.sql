-- ----------------------------------------------------------
--                       Data Analysis 
-- ----------------------------------------------------------

-- ------------------------ Content ------------------------------------------------------
-- Part 1: Individual analysis for each location
-- 1. Proportions of room type
-- 2. Commercialised index by neighbourhood_group in percentage
-- 3. Commercialised index by neighbourhood in percentage
-- 4. Commercialised index by neighbourhood_group
-- 5. Commercialised index by neighbourhood
-- 6. Geographich location for commercialised property by neighbourhood_group
-- 7. geographich location for commercialised property by neighbourhood

-- Part 2. Combined tables
-- 8. Combine data for table : Proportions of room type
--    8.1 Create blank table
--    8.2 Add data into table
-- 9. Combine data for table: Commercialised Index
--    9.1 Create blank table
--    9.2 Add data into table
-- 10. Combine data for table: Geographical location
--    10.1 Create blank table
--    10.2 Add data into table

-- Part 3: Aggregate tables for visualisation
-- 11. Aggregate Entire-home listing and commercialised index
--     11.1 Create the room-type summary table
--     11.2 Create the commercialisation summary table
--     11.3 Join the two tables
-- 12. Join table of housing-market indicators and city-level Airbnb market indicators
-- ----------------------------------------------------------------------------------------

-- 1. Number of Airbnb Listings by Room Type and Neighbourhood
SELECT 
    room_type,
    COUNT(room_type) AS 'Room type count',
    SUM(COUNT(record_id)) OVER () AS 'Total listing',
    ROUND(
        COUNT(record_id) / SUM(COUNT(record_id)) OVER () * 100,
        2
    ) AS 'Percentage'
FROM listingLondonCleanDrop
GROUP BY room_type
ORDER BY room_type;

-- 2. Commercialised index by neighbourhood_group in percentage
SELECT 
    SUM(
        CASE 
            WHEN calculated_host_listings_count = 1 THEN 0
            ELSE 1
        END
    ) AS 'Count of people listing >1 property', 
    
    count(record_id) as 'total listing', 
    
    SUM(
        CASE 
            WHEN calculated_host_listings_count = 1 THEN 0
            ELSE 1
        END
    ) / count(record_id) as 'percentage'
    
FROM listingLondonCleanDrop
;

-- 3. Commercialised index by neighbourhood in percentage
SELECT 
	neighbourhood AS 'Neighbourhood',
    SUM(
        CASE 
            WHEN calculated_host_listings_count = 1 THEN 0
            ELSE 1
        END
    ) AS 'Count of people listing >1 property', 
    
    count(record_id) as 'total listing', 
    
    SUM(
        CASE 
            WHEN calculated_host_listings_count = 1 THEN 0
            ELSE 1
        END
    ) / count(record_id) as 'percentage'
    
FROM listingLondonCleanDrop
GROUP BY neighbourhood
ORDER BY neighbourhood
;

-- 4. Commercialised index by neighbourhood_group
SELECT 
    calculated_host_listings_count AS 'Host Listing Count',
    COUNT(calculated_host_listings_count) AS 'Total Count',
    GREATEST(
        1,
        ROUND(
            COUNT(calculated_host_listings_count) / calculated_host_listings_count
        )
    ) AS "No of Host"
FROM listingLondonCleanDrop
GROUP BY calculated_host_listings_count
ORDER BY calculated_host_listings_count
;

-- 5. Commercialised index by neighbourhood
SELECT 
    neighbourhood AS 'Neighbourhood',
    
    SUM(
        CASE 
            WHEN calculated_host_listings_count = 1 THEN 1
            ELSE 0
        END
    ) AS 'No. of people listing 1 property',
    
    COUNT(record_id) AS 'Total listing',
    
    ROUND(
        SUM(
            CASE 
                WHEN calculated_host_listings_count = 1 THEN 0
                ELSE 1
            END
        ) / COUNT(record_id),
        2
    ) AS 'Commercialised index'

FROM listingLondonCleanDrop
GROUP BY neighbourhood
ORDER BY neighbourhood ASC;

-- 6. Geographich location for commercialised property by neighbourhood_group
SELECT latitude,longitude,room_type, calculated_host_listings_count
FROM listingLondonCleanDrop
WHERE calculated_host_listings_count != 1;

-- 7. geographich location for commercialised property by neighbourhood
SELECT neighbourhood,latitude,longitude,room_type, calculated_host_listings_count
FROM listingLondonCleanDrop
WHERE calculated_host_listings_count != 1
Order by neighbourhood;

-- 8. Combine tables for table : Proportions of room type
-- 8.1 Create blank table
CREATE TABLE AirbnbRoomTypeSummary (
    neighbourhood_group VARCHAR(255),
    neighbourhood VARCHAR(255),
    room_type VARCHAR(100),
    room_type_count INT,
    total_listing INT,
    percentage DECIMAL(10,2)
);

-- 8.2 Add data into table
INSERT INTO AirbnbRoomTypeSummary (
    neighbourhood_group,
    neighbourhood,
    room_type,
    room_type_count,
    total_listing,
    percentage
)

SELECT 
    neighbourhood_group,
    neighbourhood,
    room_type,
    COUNT(record_id) AS room_type_count,
    SUM(COUNT(record_id)) OVER () AS total_listing,
    ROUND(
        COUNT(record_id) / SUM(COUNT(record_id)) OVER () * 100,
        2
    ) AS percentage
FROM listingLondonCleanDrop
GROUP BY neighbourhood_group, neighbourhood, room_type

UNION ALL

SELECT 
    neighbourhood_group,
    neighbourhood,
    room_type,
    COUNT(record_id),
    SUM(COUNT(record_id)) OVER (),
    ROUND(
        COUNT(record_id) / SUM(COUNT(record_id)) OVER () * 100,
        2
    )
FROM listinggreatermanchestercleandrop
GROUP BY neighbourhood_group, neighbourhood, room_type

UNION ALL

SELECT 
    neighbourhood_group,
    neighbourhood,
    room_type,
    COUNT(record_id),
    SUM(COUNT(record_id)) OVER (),
    ROUND(
        COUNT(record_id) / SUM(COUNT(record_id)) OVER () * 100,
        2
    )
FROM listingedinburghdropclean
GROUP BY neighbourhood_group, neighbourhood, room_type

UNION ALL

SELECT 
    neighbourhood_group,
    neighbourhood,
    room_type,
    COUNT(record_id),
    SUM(COUNT(record_id)) OVER (),
    ROUND(
        COUNT(record_id) / SUM(COUNT(record_id)) OVER () * 100,
        2
    )
FROM listingsbristolcleandrop
GROUP BY neighbourhood_group, neighbourhood, room_type;

-- 9. Combine data for table: Commercialised Index
-- 9.1 Create a blank table
CREATE TABLE CombinedCommercialisedIndex (
    neighbourhood_group VARCHAR(255),
    Neighbourhood VARCHAR(255),
    `No. of people listing 1 property` INT,
    `Total listing` INT,
    `Commercialised index` DECIMAL(10,2)
);

-- 9.2 Add data into table
INSERT INTO CombinedCommercialisedIndex (
    neighbourhood_group,
    Neighbourhood,
    `No. of people listing 1 property`,
    `Total listing`,
    `Commercialised index`
)

-- 1. Edinburgh
SELECT 
    neighbourhood_group,
    neighbourhood AS Neighbourhood,
    
    SUM(
        CASE 
            WHEN calculated_host_listings_count = 1 THEN 1
            ELSE 0
        END
    ) AS `No. of people listing 1 property`,
    
    COUNT(record_id) AS `Total listing`,
    
    ROUND(
        SUM(
            CASE 
                WHEN calculated_host_listings_count = 1 THEN 0
                ELSE 1
            END
        ) / COUNT(record_id),
        2
    ) AS `Commercialised index`

FROM listingedinburghdropclean
GROUP BY neighbourhood_group, neighbourhood


UNION ALL


-- 2. Greater Manchester
SELECT 
    neighbourhood_group,
    neighbourhood AS Neighbourhood,
    
    SUM(
        CASE 
            WHEN calculated_host_listings_count = 1 THEN 1
            ELSE 0
        END
    ) AS `No. of people listing 1 property`,
    
    COUNT(record_id) AS `Total listing`,
    
    ROUND(
        SUM(
            CASE 
                WHEN calculated_host_listings_count = 1 THEN 0
                ELSE 1
            END
        ) / COUNT(record_id),
        2
    ) AS `Commercialised index`

FROM listingGreaterManchesterCleanDrop
GROUP BY neighbourhood_group, neighbourhood


UNION ALL


-- 3. London
SELECT 
    neighbourhood_group,
    neighbourhood AS Neighbourhood,
    
    SUM(
        CASE 
            WHEN calculated_host_listings_count = 1 THEN 1
            ELSE 0
        END
    ) AS `No. of people listing 1 property`,
    
    COUNT(record_id) AS `Total listing`,
    
    ROUND(
        SUM(
            CASE 
                WHEN calculated_host_listings_count = 1 THEN 0
                ELSE 1
            END
        ) / COUNT(record_id),
        2
    ) AS `Commercialised index`

FROM listingLondonCleanDrop
GROUP BY neighbourhood_group, neighbourhood


UNION ALL


-- 4. Bristol
SELECT 
    neighbourhood_group,
    neighbourhood AS Neighbourhood,
    
    SUM(
        CASE 
            WHEN calculated_host_listings_count = 1 THEN 1
            ELSE 0
        END
    ) AS `No. of people listing 1 property`,
    
    COUNT(record_id) AS `Total listing`,
    
    ROUND(
        SUM(
            CASE 
                WHEN calculated_host_listings_count = 1 THEN 0
                ELSE 1
            END
        ) / COUNT(record_id),
        2
    ) AS `Commercialised index`

FROM listingsbristolcleandrop
GROUP BY neighbourhood_group, neighbourhood;

-- 10. Combine data for table: Geographical location
--    10.1 Create blank table
CREATE TABLE AirbnbCommercialListings (
    neighbourhood_group VARCHAR(255),
    neighbourhood VARCHAR(255),
    latitude DECIMAL(10,7),
    longitude DECIMAL(10,7),
    room_type VARCHAR(100),
    calculated_host_listings_count INT
);

INSERT INTO AirbnbCommercialListings (
    neighbourhood_group,
    neighbourhood,
    latitude,
    longitude,
    room_type,
    calculated_host_listings_count
)

-- 10.2 Add data into table
-- London
SELECT 
    neighbourhood_group,
    neighbourhood,
    latitude,
    longitude,
    room_type,
    calculated_host_listings_count
FROM listingLondonCleanDrop
WHERE calculated_host_listings_count != 1

UNION ALL

-- Greater Manchester
SELECT 
    neighbourhood_group,
    neighbourhood,
    latitude,
    longitude,
    room_type,
    calculated_host_listings_count
FROM listinggreatermanchestercleandrop
WHERE calculated_host_listings_count != 1

UNION ALL

-- Edinburgh
SELECT 
    neighbourhood_group,
    neighbourhood,
    latitude,
    longitude,
    room_type,
    calculated_host_listings_count
FROM listingedinburghdropclean
WHERE calculated_host_listings_count != 1

UNION ALL

-- Bristol
SELECT 
    neighbourhood_group,
    neighbourhood,
    latitude,
    longitude,
    room_type,
    calculated_host_listings_count
FROM listingsbristolcleandrop
WHERE calculated_host_listings_count != 1;

-- 11. Aggregate Entire-home listing and commercialised index
-- 11.1 Create the room-type summary table
CREATE TABLE LondonRoomTypeSummary AS
SELECT  
    'London' AS neighbourhood_group,
    room_type, 
    COUNT(room_type) AS room_type_count, 
    SUM(COUNT(record_id)) OVER () AS total_listing, 
    ROUND( 
        COUNT(record_id) / SUM(COUNT(record_id)) OVER () * 100, 
        2 
    ) AS percentage 
FROM listingLondonCleanDrop 
GROUP BY room_type;

-- 11.2 Create the commercialisation summary table
CREATE TABLE LondonCommercialisedSummary AS
SELECT 
    'London' AS neighbourhood_group,

    SUM( 
        CASE  
            WHEN calculated_host_listings_count = 1 THEN 0 
            ELSE 1 
        END 
    ) AS count_listing_more_than_1_property,  
    
    COUNT(record_id) AS total_listing,  
    
    ROUND(
        SUM( 
            CASE  
                WHEN calculated_host_listings_count = 1 THEN 0 
                ELSE 1 
            END 
        ) / COUNT(record_id) * 100,
        2
    ) AS commercialised_index
    
FROM listingLondonCleanDrop;

-- 11.3 Join the two tables
SELECT
    r.neighbourhood_group,
    r.percentage AS `Entire-home listing`,
    c.commercialised_index AS `Commercialised index`
FROM LondonRoomTypeSummary r
JOIN LondonCommercialisedSummary c
    ON r.neighbourhood_group = c.neighbourhood_group
WHERE r.room_type = 'Entire home/apt';

-- 12. Join table of housing-market indicators and city-level Airbnb market indicators
SELECT
    a.neighbourhood_group,
    a.`Entire-home listing`,
    a.`Commercialised index`,
    h.`Concentrated relative to housing stock`,
    h.`Price Index of Private Rent Changes (Jun 25 vs Jul 20)`,
    h.`Housing Price Index (Jun 25 vs Jul 20)`
FROM AirbnbMarketIndicators a
JOIN HousingMarketIndicators h
    ON (
        a.neighbourhood_group = h.city
        OR (
            a.neighbourhood_group = 'Greater Manchester'
            AND h.city = 'Manchester'
        )
    );