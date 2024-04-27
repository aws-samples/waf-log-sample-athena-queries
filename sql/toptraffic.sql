-- This sql identifies the count of requests group across client IP, the terminating rule and URI accessed
-- This would analyze the top talker client IP are accessing certain URIs for a large number of times and if its being ALLOW / BLOCK / CHALLENGE / CAPTCHA. 

SELECT count(*) AS countRequests,httprequest.clientip, terminatingruleid, httprequest.uri
FROM "waf_logs" 
WHERE 
 date >=date_format(current_date - interval '7' day, '%Y/%m/%d')  
GROUP BY httprequest.clientip,terminatingruleid, httprequest.uri
ORDER BY count(*) DESC