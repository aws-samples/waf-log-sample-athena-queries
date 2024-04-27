-- This sql is used to identify the top 10 IPs which have made most requests in the past 7 days.
-- It allows you to identify which IPs are making the most requests in your WAF logs.
-- This can help you troubleshoot issues with your WAF logs and identify which IPs are causing issues.
SELECT httprequest.clientip, count(httprequest.clientip) AS requests
FROM waf_logs
WHERE date >= date_format(current_date - interval '7' day, '%Y/%m/%d')
GROUP BY httprequest.clientip
ORDER BY requests DESC
LIMIT 10 