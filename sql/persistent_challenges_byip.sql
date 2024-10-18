WITH challenges_and_tokens AS (
    select
        date,
        httprequest.clientip AS clientip,
        count(distinct label_item.name) as unique_tokens,
        SUM(
            CASE
                WHEN action = 'CHALLENGE' THEN 1
            END
        ) as challenged_requests
    FROM
        "waf_logs",
        UNNEST(
            CASE
                WHEN cardinality(labels) >= 1 THEN labels
                ELSE array [ cast(row('NOLABEL') as row(name varchar)) ]
            END
        ) AS t(label_item)
    WHERE
        date >= date_format(current_date - interval '7' day, '%Y/%m/%d')
        AND label_item.name LIKE 'awswaf:managed:token:id:%'
    group by
        1,
        2
)
select
    date,
    count(distinct clientip) as total_ips,
    count(
        distinct case
            when challenged_requests >= 5 then clientip
        end
    ) as clientip_with_5_challenges,
    count(
        distinct case
            when (
                challenged_requests >= 5
                and unique_tokens > 0
            ) then clientip
        end
    ) as clientip_with_5_challenges_solved
from
    challenges_and_tokens
group by
    1
order by
    1