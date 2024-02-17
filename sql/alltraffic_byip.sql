SELECT count(*) AS countRequests,terminatingruleid, httprequest.uri, httprequest.args, label_item.name
FROM "waf_logs_5" ,
UNNEST( CASE WHEN cardinality(labels) >= 1
               THEN labels
               ELSE array[ cast( row('NOLABEL') as row(name varchar)) ]
              END
       ) as t(label_item)
WHERE 
 date >=date_format(current_date - interval '8' day, '%Y/%m/%d')  
 and httprequest.clientip like '185.254%'
GROUP BY terminatingruleid, httprequest.uri, httprequest.args, label_item.name
order by count(*) desc