WITH t1 AS (
  SELECT
    httprequest.clientip AS clientip, 
    httprequest.uri AS uri,
    to_iso8601(from_unixtime( timestamp /(1000 *5 *60)*5*60)) AS five_minute , -- to change from 5 minute interval, replace all values of 5 in this line with the new value. 
    COUNT(httprequest.clientip) AS totalRequest
  FROM waf_logs
  WHERE
    date >= date_format(current_date - interval '1' day, '%Y/%m/%d') -- this is for 1 day worth of logs.  
    --AND timestamp >=  CAST( to_unixtime(from_iso8601_timestamp('2024-07-11T00:00:00.00'))  as bigint)*1000 -- start timestamp. You can uncomment this line and edit it to set the start time to a specific timestamp. 
    --Ensure that the timestamp is matching the date criteria
    --AND timestamp <= CAST( to_unixtime(from_iso8601_timestamp('2024-07-11T16:00:00'))  as bigint)*1000 -- end timestamp. You can uncomment this line and edit it to set the end time  to a specific timestamp.
    --Ensure that the timestamp is matching the date criteria
  GROUP  by 1 ,2,3
  )
SELECT 
  MIN(totalRequest) AS min, 
  MAX(totalRequest) AS max, 
  ROUND(AVG(totalRequest)) AS avg, 
  APPROX_PERCENTILE(totalRequest, .95) AS p95, 
  APPROX_PERCENTILE(totalRequest, .99) AS p99 , 
  SUM(totalRequest) AS totalRequests, 
  clientip , 
  uri
FROM t1
GROUP BY clientip, uri
ORDER BY max DESC