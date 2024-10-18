with challenges_and_tokens as (
    select
        date,
        httprequest.clientip AS clientip,
        COUNT(distinct label_item.name) as unique_tokens,
        SUM(
            CASE
                WHEN action = 'CHALLENGE' THEN 1
            END
        ) as challenged_requests,
        SUM(
            CASE
                WHEN ARRAY_JOIN(transform(labels, l -> l.name), ', ') like 'awswaf:managed:token:rejected%' THEN 1
                ELSE 0
            END
        ) token_rejected,
        SUM(
            CASE
                WHEN ARRAY_JOIN(transform(labels, l -> l.name), ', ') like 'awswaf:managed:token:absent' THEN 1
                ELSE 0
            END
        ) token_absent,
        SUM(
            CASE
                WHEN ARRAY_JOIN(transform(labels, l -> l.name), ', ') like '%:bot-control:TGT_TokenAbsent%' THEN 1
                ELSE 0
            END
        ) bot_control_token_absent,
        SUM(
            CASE
                WHEN ARRAY_JOIN(transform(labels, l -> l.name), ', ') like '%:targeted:aggregate:volumetric:ip:token_absent%' THEN 1
                ELSE 0
            END
        ) bot_control_volumetric_token_absent
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
    distinct date,
    COUNT(distinct clientip) as total_ips,
    COUNT(
        distinct case
            when challenged_requests > 0 then clientip
        end
    ) as ips_challenged,
    COUNT(
        distinct case
            when unique_tokens > 0 then clientip
        end
    ) as ips_with_tokens,
    COUNT(
        distinct case
            when (token_rejected > 0)
            and (challenged_requests > 0) then clientip
        end
    ) as ips_challenged_with_token_rejected,
    COUNT(
        distinct case
            when (token_absent > 0)
            and (challenged_requests > 0) then clientip
        end
    ) as ips_challenged_with_token_absent,
    COUNT(
        distinct case
            when (bot_control_token_absent > 0)
            and (challenged_requests > 0) then clientip
        end
    ) as ips_challenged_with_bot_control_token_absent,
    COUNT(
        distinct case
            when (bot_control_volumetric_token_absent > 0)
            and (challenged_requests > 0) then clientip
        end
    ) as ips_challenged_with_bot_control_volumetric_token_absent,
    COUNT(
        distinct case
            when (unique_tokens = 0)
            and (
                token_rejected > 0
                OR token_absent > 0
                OR bot_control_token_absent > 0
                OR bot_control_volumetric_token_absent > 0
            ) then clientip
        end
    ) as ips_with_no_tokens_ever
from
    challenges_and_tokens
group by
    1