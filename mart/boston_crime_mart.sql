SELECT
  * INTO otus.boston_crime_mart
FROM
  (
    with transform_offense_code as (
      select
        to_char(offense_code_id, '00000') code,
        name,
        split_part(
          regexp_replace(name, '\"', ''),
          ' - ',
          1
        ) crime_type,
        row_number() over (
          partition by to_char(offense_code_id, '00000')
          order by
            to_char(offense_code_id, '00000')
        ) rn
      from
        otus.offense_code
    ),
    drop_duplicate_code as (
      select
        code,
        crime_type
      from
        transform_offense_code
      where
        rn = 1
    ),
    transform_crime as (
      select
        year,
        month,
        district,
        incident_id,
        to_char(offense_code_id, '00000') offense_code_id,
        lat,
        long,
        dc.*
      from
        otus.crime c
        join drop_duplicate_code dc ON to_char(offense_code_id, '00000') = dc.code
      where
        district is not null
    ),
    avg_lat_long_table as (
      select
        district,
        count(incident_id) crimes_total,
        avg(lat) lat,
        avg(long) lng
      from
        transform_crime
      group by
        district
    ),
    prepared_median_select as (
      select
        district,
        count(incident_id) crimes_total_by_month_district
      from
        transform_crime
      group by
        year,
        month,
        district
    ),
    median as (
      select
        district,
        APPROXIMATE_PERCENTILE(
          crimes_total_by_month_district USING PARAMETERS percentile = 0.5
        ) crimes_monthly
      from
        prepared_median_select
      group by
        district
    ),
    cnt_crime_type as (
      select
        district,
        crime_type,
        count(incident_id) cnt_crime_type
      from
        transform_crime
      group by
        district,
        crime_type
    ),
    cnt_freq as (
      select
        cnt_crime_type.*,
        row_number() over(
          partition by district
          order by
            district,
            cnt_crime_type desc
        ) rn
      from
        cnt_crime_type
    ),
    crime_freq as (
      select
        district,
        LISTAGG(crime_type) frequent_crime_types
      from
        (
          select
            district,
            crime_type,
            rn
          from
            cnt_freq
          order by
            crime_type
        ) as x
      where
        rn < 4
      group by
        district
    )
    select
      a.district,
      crimes_total,
      crimes_monthly,
      frequent_crime_types,
      lat,
      lng
    from
      avg_lat_long_table a
      join median m ON a.district = m.district
      join crime_freq f ON a.district = f.district
  ) as boston_mart;