with spend as (
    select * from {{ ref('ad_spend') }}
),

campaigns as (
    select * from {{ ref('stg_campaigns') }}
)

select
    s.spend_id,
    s.campaign_id,
    c.campaign_name,
    c.channel,
    c.sub_channel,
    c.campaign_type,
    s.spend_date::date as spend_date,
    s.spend_amount,
    s.impressions,
    s.clicks,
    case
        when s.clicks > 0 then s.spend_amount / s.clicks
        else null
    end as cost_per_click,
    case
        when s.impressions > 0 then (s.clicks::float / s.impressions) * 100
        else null
    end as click_through_rate
from spend s
inner join campaigns c on s.campaign_id = c.campaign_id
