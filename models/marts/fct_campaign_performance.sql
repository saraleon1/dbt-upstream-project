with campaigns as (
    select * from {{ ref('stg_campaigns') }}
),

spend_agg as (
    select
        campaign_id,
        sum(spend_amount) as total_spend,
        sum(impressions) as total_impressions,
        sum(clicks) as total_clicks,
        count(*) as spend_days
    from {{ ref('stg_ad_spend') }}
    group by 1
),

lead_agg as (
    select
        campaign_id,
        count(*) as total_leads,
        count(case when is_converted then 1 end) as converted_leads,
        count(case when lead_status = 'lost' then 1 end) as lost_leads,
        count(case when lead_status = 'open' then 1 end) as open_leads,
        avg(case when is_converted then days_to_convert end) as avg_days_to_convert
    from {{ ref('stg_leads') }}
    group by 1
)

select
    c.campaign_id,
    c.campaign_name,
    c.channel,
    c.sub_channel,
    c.campaign_type,
    c.start_date,
    c.end_date,
    c.monthly_budget,

    coalesce(s.total_spend, 0) as total_spend,
    coalesce(s.total_impressions, 0) as total_impressions,
    coalesce(s.total_clicks, 0) as total_clicks,
    coalesce(s.spend_days, 0) as spend_days,

    coalesce(la.total_leads, 0) as total_leads,
    coalesce(la.converted_leads, 0) as converted_leads,
    coalesce(la.lost_leads, 0) as lost_leads,
    coalesce(la.open_leads, 0) as open_leads,
    la.avg_days_to_convert,

    -- derived metrics
    case
        when s.total_clicks > 0
        then s.total_spend / s.total_clicks
        else null
    end as overall_cpc,

    case
        when la.total_leads > 0
        then s.total_spend / la.total_leads
        else null
    end as cost_per_lead,

    case
        when la.total_leads > 0
        then (la.converted_leads::float / la.total_leads) * 100
        else null
    end as conversion_rate,

    case
        when s.total_impressions > 0
        then (s.total_clicks::float / s.total_impressions) * 100
        else null
    end as overall_ctr

from campaigns c
left join spend_agg s on c.campaign_id = s.campaign_id
left join lead_agg la on c.campaign_id = la.campaign_id
