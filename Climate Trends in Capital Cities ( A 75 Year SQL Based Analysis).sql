
-- =============================================================
-- Project: Climate Trends in Capital Cities (1950–2024)
-- Name: Ankita Basu
-- Description: SQL-based analysis of global weather patterns using 75 years of daily climate data
-- =============================================================
CREATE DATABASE weather;
USE weather;
SET SQL_SAFE_UPDATEs = 0;
UPDATE daily_data 
SET sunset = STR_TO_DATE(sunset, '%d-%m-%Y %H:%i');

-- =============================================================
-- SECTION 1: GLOBAL TEMPERATURE TRENDS
-- Objective: Analyze average temperature change globally from 1950 to 2024
-- =============================================================
-- Global average temperature trend per year
SELECT year,
ROUND(AVG(temperature_2m_mean), 2) AS avg_global_temp
FROM daily_data
WHERE year BETWEEN 1950 AND 2024
GROUP BY year
ORDER BY year;

-- Fastest Warming Capital Cities (1950–2024)
SELECT city_name, 
       MAX(year) - MIN(year) AS years_covered,
       MAX(avg_temp) - MIN(avg_temp) AS temp_rise
FROM ( SELECT city_name, year, 
    ROUND(AVG(temperature_2m_mean), 2) 
    AS avg_temp
    FROM daily_data
    GROUP BY city_name, year
) yearly_avg
GROUP BY city_name
ORDER BY temp_rise DESC
LIMIT 10;

-- Extreme Weather Events

-- Cities with Most Heatwave Days (> 40°C)
SELECT city_name,
    COUNT(*) AS heatwave_days
FROM daily_data
WHERE temperature_2m_max > 40
GROUP BY city_name
ORDER BY heatwave_days DESC
LIMIT 10;

-- Cities with Highest Total Precipitation
SELECT city_name,
    ROUND(SUM(precipitation_sum), 2) 
    AS total_precipitation
FROM daily_data
GROUP BY city_name
ORDER BY total_precipitation DESC
LIMIT 10;

-- Impact of Latitude or Altitude

-- Average Temperature vs Latitude
SELECT 
    ROUND(c.latitude, 0) AS latitude_band,
    ROUND(AVG(d.temperature_2m_mean), 2) AS avg_temperature
FROM daily_data d
INNER JOIN cities c ON d.city_name = c.city_name
WHERE d.year BETWEEN 1950 AND 2024
GROUP BY ROUND(c.latitude, 0)
ORDER BY latitude_band;

-- Shrinking Winters – Compare Winter Temps Across Years

SELECT city_name, EXTRACT(MONTH FROM sunrise) AS month, ROUND(AVG(temperature_2m_mean), 2) AS avg_temp
FROM daily_data
WHERE city_name IN ('Moscow', 'Delhi') AND EXTRACT(MONTH FROM sunrise) IN (12, 1, 2)
GROUP BY city_name, month;

-- Solar Energy Potential
-- Cities with most sunshine hours per year
SELECT city_name, ROUND(AVG(sunshine_duration), 2) AS avg_sunshine
FROM daily_data
GROUP BY city_name
ORDER BY avg_sunshine DESC;












-- Average temperature per city over time
SELECT city_name, year,
       ROUND(AVG(temperature_2m_mean), 2) AS avg_temp
FROM daily_data
WHERE year BETWEEN 1950 AND 2024
GROUP BY city_name, year
ORDER BY city_name, year ;


-- Cities with Highest Snow Accumulation
SELECT city_name,
    ROUND(SUM(snowfall_sum), 2) AS total_snowfall
FROM daily_data
GROUP BY city_name
ORDER BY total_snowfall DESC
LIMIT 10;

-- Cities with Most Consecutive Heatwave Days
SELECT city_name, year, COUNT(*) AS heatwave_days
FROM daily_data
WHERE temperature_2m_max > 40
GROUP BY city_name, year
ORDER BY heatwave_days DESC
LIMIT 10;

--  Uneven Sunshine – Average Sunshine by Region
SELECT
    d.city_name,
    ROUND(c.latitude, 0) AS lat_band,
    ROUND(AVG(d.sunshine_duration), 2) AS avg_sunshine
FROM daily_data d
INNER JOIN cities c ON d.city_name = c.city_name
GROUP BY d.city_name, lat_band
ORDER BY lat_band, avg_sunshine DESC;

-- Compare cities at similar latitudes but different climates.
SELECT 
    d.city_name,
    d.year,
    ROUND(AVG(d.temperature_2M_mean), 2) AS avg_temp,
    c.latitude
FROM daily_data d
INNER JOIN cities c ON d.city_name = c.city_name
WHERE 
    c.latitude BETWEEN 25 AND 35
    AND d.year BETWEEN 1950 AND 2024
GROUP BY d.city_name, d.year, c.latitude
ORDER BY d.city_name, d.year;

--  Extreme Heat Events – Count Days > 40°C
SELECT city_name, year,
    COUNT(*) AS extreme_heat_days
FROM daily_data
WHERE temperature_2m_max > 40
GROUP BY city_name, year
ORDER BY extreme_heat_days DESC;

-- Continent Trends – Average Temp by Continent
SELECT 
    CASE
        WHEN c.latitude BETWEEN -60 AND 15 AND c.longitude BETWEEN -80 AND -30 THEN 'South America'
        WHEN c.latitude BETWEEN 10 AND 80 AND c.longitude BETWEEN -170 AND -50 THEN 'North America'
        WHEN c.latitude BETWEEN 30 AND 70 AND c.longitude BETWEEN -10 AND 60 THEN 'Europe'
        WHEN c.latitude BETWEEN -35 AND 35 AND c.longitude BETWEEN 30 AND 130 THEN 'Africa'
        WHEN c.latitude BETWEEN 5 AND 55 AND c.longitude BETWEEN 60 AND 150 THEN 'Asia'
        WHEN c.latitude BETWEEN -50 AND -10 AND c.longitude BETWEEN 110 AND 180 THEN 'Oceania'
        ELSE 'Other'
    END AS continent, d.year,
    ROUND(AVG(d.temperature_2m_mean), 2) AS avg_temp
FROM daily_data d
INNER JOIN cities c ON d.city_name = c.city_name
GROUP BY continent, d.year
ORDER BY continent, d.year;

-- cities with the highest rainfall days (e.g. days > 50mm)
SELECT city_name, year,
    COUNT(*) AS heavy_rain_days
FROM daily_data
WHERE precipitation_sum > 50
GROUP BY city_name, year
ORDER BY heavy_rain_days DESC;

--  Compare Hemispheres(Northern/Southern) -Temperature differences ,Opposite seasons
SELECT 
    CASE 
        WHEN c.latitude >= 0 THEN 'Northern'
        ELSE 'Southern'
    END AS hemisphere,
	EXTRACT(MONTH FROM d.sunrise) as month,
    ROUND(AVG(d.temperature_2m_mean), 2) AS avg_temp
FROM daily_data d
INNER JOIN cities c ON d.city_name = c.city_name
GROUP BY hemisphere, month
ORDER BY hemisphere, month;