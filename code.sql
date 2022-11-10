DECLARE @counter INT = 1, 
@startDate datetime = cast(dateadd(month, -3, dateadd(day, 1 - day(getdate()), getdate())) as date)

	IF OBJECT_ID('tempdb..#emp') IS NOT NULL DROP TABLE #emp;

	CREATE TABLE #emp
	WITH
		(
		DISTRIBUTION = ROUND_ROBIN
		)
	AS
	WITH cte AS
	(
	SELECT 1 as xlevel, @startDate startDate, DATENAME(WEEKDAY, @startDate)  [Weekday] 
	)
	SELECT *
	FROM cte;

	WHILE EXISTS (
	SELECT *
	FROM #emp p
	WHERE p.xlevel = @counter

	)

	BEGIN

		BEGIN 
		INSERT INTO #emp ( xlevel, startDate, [Weekday] )
		SELECT @counter + 1 AS xlevel, startDate +1, DATENAME(WEEKDAY, startDate +1)  [Weekday] 
		FROM #emp p
		WHERE p.xlevel = @counter;
		END 

			SET @counter += 1;

			-- break in case infinite loop
If @counter > datediff(day, cast(dateadd(month, -3, dateadd(day, 1 - day(getdate()), getdate())) as date), EOMONTH(cast(dateadd(month, 3, dateadd(day, 1 - day(getdate()), getdate())) as date)))

			BEGIN 
				BREAK 
			END 

	END

	TRUNCATE TABLE dbo.month_days_weekdays

	INSERT INTO dbo.month_days_weekdays 
	SELECT CAST(startDate as DATE) DATE, WEEKDAY
	FROM #emp 
