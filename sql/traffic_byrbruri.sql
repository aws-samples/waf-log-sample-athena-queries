SELECT
  httprequest.clientip AS clientip,
  terminatingruleid,
  to_iso8601(from_unixtime( timestamp /(1000 *5 *60)*5*60)) AS five_minute , -- this for every 5 minutes. You can change from 5 to whatever value you want to change the interval period.
  ratebasedrulelist,
  action,
  httprequest.uri,    ---  My AGGREGATION KEY is based on uri. PUT YOUR AGGREGATION KEY HERE. If You have multiple AGGREGATION KEYS, you add them here and also to the group by clause below
  COUNT(*) AS numberOfRequests
FROM "waf_logs"
WHERE
  date >= date_format(current_date - interval '10' day, '%Y/%m/%d') --- YOU CAN CHANGE THE NUMBER OF DAYS  FROM 7 ==> 1 for viewing only sameday data.
AND terminatingruletype = 'RATE_BASED'
GROUP BY  1,2,3 ,4,5,6
ORDER BY five_minute