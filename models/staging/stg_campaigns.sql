with source as (
    select * from {{ ref('campaigns') }}
)

select
    campaign_id,
    campaign_name,
    channel,
    sub_channel,
    campaign_type,
    start_date::date as start_date,
    end_date::date as end_date,
    monthly_budget
from source
