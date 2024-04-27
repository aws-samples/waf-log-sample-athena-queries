-- This sql gathers all tokens issued and then identifies the client IP
-- Then it gathers main elements of the traffic for those IPs such as URI accessed even before the token was issued.

WITH t1 AS ( 
SELECT distinct httprequest.clientip clientip, label_item.name AS token_id
FROM waf_logs ,
UNNEST( CASE WHEN cardinality(labels) >= 1
               THEN labels
               ELSE array[ cast( row('NOLABEL') AS row(name varchar)) ]
              END
       ) AS t(label_item)
WHERE 
 date >=date_format(current_date - interval '7' day, '%Y/%m/%d')  
 AND  label_item.name like 'awswaf:managed:token:id:%'
)
SELECT DISTINCT    regexp_extract( json_format(cast(labels AS json)),'awswaf:managed:token:id:(.*?)\"', 0) AS  issued_token, clientip, responsecodesent,httprequest.uri, to_iso8601(from_unixtime(timestamp / 1000))date_time , timestamp 
FROM t1, waf_logs  
WHERE httprequest.clientip = t1.clientip  
AND  date >=date_format(current_date - interval '7' day, '%Y/%m/%d')  
ORDER BY clientip, timestamp DESC