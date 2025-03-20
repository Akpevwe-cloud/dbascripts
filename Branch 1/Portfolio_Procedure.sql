CREATE PROCEDURE [utl].[PropertyPortfolioProcedure]
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    -- Insert statements for procedure here

With hp as

(SELECT DISTINCT SUBSTRING(ref, CHARINDEX('/', ref)+1, 3) as area_code, area
  FROM [dbo].[HistoryProperties]
  where Status_SCD like 'current%' )


--INSERT INTO [utl].[Property_Portfolios] (Area_Code,Area_Name)

SELECT hp.area_code, hp.area
FROM hp LEFT JOIN [utl].[Property_Portfolios] pp
ON hp.area_code = pp.Area_Code
where pp.Area_Code is nulL and hp.area != 'TEST'
  
  
END