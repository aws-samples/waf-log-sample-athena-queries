-- this sql is used to identify all traffic received from a single client IP or range of IPs .
-- The results are group by the terminating rule id ,the URI and the arguments of the request and the associated labels that were attached to the requests.
-- The results are sorted by the number of requests in descending order.
-- The results are limited to the last 7 days.

SELECT count(*) AS countRequests,terminatingruleid, httprequest.uri, httprequest.args, label_item.name
FROM "waf_logs" ,
UNNEST( CASE WHEN cardinality(labels) >= 1
               THEN labels
               ELSE array[ cast( row('NOLABEL') as row(name varchar)) ]
              END
       ) AS t(label_item)
WHERE 
 date >=date_format(current_date - interval '7' day, '%Y/%m/%d')  
 AND httprequest.clientip LIKE 'XXX.YYY%'
GROUP BY terminatingruleid, httprequest.uri, httprequest.args, label_item.name
ORDER BY count(*) DESC