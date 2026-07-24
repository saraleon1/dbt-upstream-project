with leads as (
    select * from {{ ref('leads') }}
),

campaigns as (
    select * from {{ ref('stg_campaigns') }}
)

select
    l.lead_id,
    l.campaign_id,
    c.campaign_name,
    c.channel,
    c.sub_channel,
    c.campaign_type,
    l.lead_date::date as lead_date,
    l.lead_source,
    l.company_size,
    l.lead_status,
    l.converted_date::date as converted_date,
    case
        when l.lead_status = 'converted' then true
        else false
    end as is_converted,
    case
        when l.converted_date is not null
        then datediff('day', l.lead_date::date, l.converted_date::date)
        else null
    end as days_to_convert
from leads l
inner join campaigns c on l.campaign_id = c.campaign_id
