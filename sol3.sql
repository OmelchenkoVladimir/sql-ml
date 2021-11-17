CREATE OR REPLACE PROCEDURE calc_days(start_t date, end_t date)
LANGUAGE 'plpgsql'
AS $$
DECLARE 
contractor text;
rec record;
l char;
d date := start_t;
BEGIN
FOR contractor IN (SELECT DISTINCT name FROM t_contractor_sheruler) LOOP
	FOR rec IN (
		SELECT name, schedule, date_begin, date_end
		FROM t_contractor_sheruler
		JOIN schedules
		ON t_contractor_sheruler.schedule_id = schedules.schedule_id
		WHERE name=contractor AND (
			(start_t <= date_begin) AND (date_begin <= end_t)
			OR
			(start_t <= date_end) AND (date_end <= end_t)
		)
		ORDER BY date_begin ASC
	) LOOP
		FOR d IN (SELECT * FROM generate_series(GREATEST(start_t, rec.date_begin), LEAST(end_t, rec.date_end), '1 day')) LOOP
		   l := (regexp_split_to_array(rec.schedule, ''))[date_part('day', d-rec.date_begin)::int % char_length(rec.schedule)+1];
		   if (l='в') 
			  then continue;
		   elsif (l='д')
			  then RAISE NOTICE '% - % - %', rec.name, d + interval '8 hours', d + interval '20 hours';
			  INSERT INTO t_contractor_work_day (name, date_begin, date_end) 
			  VALUES (rec.name, d + interval '8 hours', d + interval '20 hours');
		   elsif (l='н')
			  then RAISE NOTICE '% - % - %', rec.name, d + interval '20 hours', d + interval '32 hours';
			  INSERT INTO t_contractor_work_day (name, date_begin, date_end)
			  VALUES (rec.name, d + interval '20 hours', d + interval '32 hours');
		   else
			  RAISE NOTICE '% - % - %', rec.name, d + interval '8 hours', d + interval '32 hours';
			  INSERT INTO t_contractor_work_day (name, date_begin, date_end)
			  VALUES (rec.name, d + interval '8 hours', d + interval '32 hours');
		   END IF;
		END LOOP;
	END LOOP;
END LOOP;
END;
$$

CALL calc_days('01.01.2019', '08.01.2019')

SELECT * FROM t_contractor_work_day

DELETE FROM t_contractor_work_day

ALTER SEQUENCE t_contractor_work_day_id_seq RESTART