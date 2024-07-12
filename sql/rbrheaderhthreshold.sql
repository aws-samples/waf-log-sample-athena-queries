WITH t1 AS (
  SELECT
    header.value AS headervalue, -- this is the value of the header . If its not needed, comment out all references to headervalue below. 
    to_iso8601(from_unixtime( timestamp /(1000 *5 *60)*5*60)) AS five_minute , -- This is for every 5 minutes. To change from 5 minutes to another value, please change both values of 5 with the new value
    COUNT(header.value) AS totalRequest
  FROM waf_logs CROSS JOIN UNNEST (httprequest.headers) AS t(header)
  WHERE   
    date >= date_format(current_date - interval '7' day, '%Y/%m/%d') -- Default query is for last  days. Always keep a date filter to reduce the # of records to be looked at 
    AND timestamp >=  cast( to_unixtime(from_iso8601_timestamp('2024-07-04T12:00:00'))  as bigint)*1000 -- start timestamp. Change these values to ensure that it aligns with the date filter above
    AND timestamp <= cast( to_unixtime(from_iso8601_timestamp('2024-07-11T16:00:00'))  as bigint)*1000 -- end timestamp . Change these values to ensure that it aligns with the date filter above
    AND lower(header.name)  = 'user-agent'         -- This sample uses the header of user-agent. You can change it to a custom header
    GROUP BY 1 ,2
  )
SELECT 
  MIN(totalRequest) AS min, 
  MAX(totalRequest) AS max,
  ROUND( AVG(totalRequest)) AS avg, 
  APPROX_PERCENTILE(totalRequest, .95) AS p95, 
  APPROX_PERCENTILE(totalRequest, .99) as p99, 
  SUM(totalRequest) AS totalRequests, 
  headervalue -- if you dont need the unique header value, comment out all references to headervalue. 
FROM t1
GROUP BY headervalue
ORDER BY max DESC