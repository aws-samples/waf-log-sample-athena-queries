SELECT
  httprequest.clientip AS clientip,
  terminatingruleid,
  to_iso8601(from_unixtime( timestamp /(1000 *5 *60)*5*60)) AS five_minute , -- this for every 5 minutes. You can change both instances of  5 to whatever value you want to change the interval period.
  ratebasedrulelist,
  action,
  header,    ---The  AGGREGATION KEY is based on header. You can replace it with your AGGREGATION KEY here. If You have multiple AGGREGATION KEYS, you add them here and also to the group by clause below
  count(*) AS numberOfRequests
FROM "waf_logs" CROSS JOIN UNNEST ( httprequest.headers) as t(header)
WHERE
  date = '2024/07/05' -- SPECIFY A SINGLE DATE instead of a DATE Range. To use a date range use this "date >= date_format(current_date - interval '7' day, '%Y/%m/%d') "
  AND terminatingruletype = 'RATE_BASED'
  AND timestamp >=  cast( to_unixtime(from_iso8601_timestamp('2024-07-05T00:00:00.00'))  as bigint)*1000 -- SPECIFY the starting  DATE & TIME for a single day. 
  AND timestamp <= cast( to_unixtime(from_iso8601_timestamp('2024-07-05T06:00:00'))  as bigint)*1000 -- SPECIFY the ending DATE & TIME for a single day. You can comment it out for a 
  AND lower(header.name) = 'user-agent' --CUSTOM KEY of header.name = 'user-agent.' You can put in your header name here.
GROUP BY  1,2,3 ,4,5,6
ORDER BY five_minute