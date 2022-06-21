select gear,
    count(*) as total,
    min(mpg) as min_mpg,
    max(mpg) as max_mpg,
    avg(mpg) as avg_mpg,
    min(hp) as min_hp,
    max(hp) as max_hp,
    avg(hp) as avg_hp
from { { ref('dago01') } }
group by gear