-- This sql is used to identify which are the most accessed URI for the last 7 days.
SELECT httprequest.uri, count(httprequest.uri) as requests
FROM waf_logs
WHERE date >= date_format(current_date - interval '7' day, '%Y/%m/%d')
GROUP BY httprequest.uri
ORDER BY requests DESC
LIMIT 10 