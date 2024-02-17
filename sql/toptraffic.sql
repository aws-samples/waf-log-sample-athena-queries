SELECT count(*) AS countRequests,httprequest.clientip, terminatingruleid, httprequest.uri
FROM "waf_logs" 
WHERE 
 date >=date_format(current_date - interval '2' day, '%Y/%m/%d')  
GROUP BY httprequest.clientip,terminatingruleid, httprequest.uri
order by count(*) desc