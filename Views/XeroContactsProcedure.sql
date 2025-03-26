/****** Object:  StoredProcedure [dbo].[XeroContacts_SCD_Procedure]    Script Date: 20/03/2025 16:54:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[XeroContacts_SCD_Procedure]
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    -- Insert statements for procedure here
    -- FIRST

/***** Append New rows to History Table *****/

INSERT INTO [dbo].[XeroContacts_History]
     ([ContactID]
      ,[ContactNumber]
      ,[AccountNumber]
      ,[ContactStatus]
      ,[Name]
      ,[FirstName]
      ,[LastName]
      ,[EmailAddress]
      ,[BankAccountDetails]
      ,[Address]
      ,[CompanyNumber]
      ,[TaxNumber]
      ,[AccountsReceivableTaxType]
      ,[AccountsPayableTaxType]
      ,[Phones]
      ,[IsSupplier]
      ,[IsCustomer]
      ,[DefaultCurrency]
      ,[UpdatedDateUTC]
      ,[page_num]
      ,[Record_Start_Date],
	  Status_SCD --NEWER UPDATE: Insert the Status_SCD field
        )


SELECT stage.[ContactID]
      ,stage.[ContactNumber]
      ,stage.[AccountNumber]
      ,stage.[ContactStatus]
      ,stage.[Name]
      ,stage.[FirstName]
      ,stage.[LastName]
      ,stage.[EmailAddress]
      ,stage.[BankAccountDetails]
      ,stage.[Address]
      ,stage.[CompanyNumber]
      ,stage.[TaxNumber]
      ,stage.[AccountsReceivableTaxType]
      ,stage.[AccountsPayableTaxType]
      ,stage.[Phones]
      ,stage.[IsSupplier]
      ,stage.[IsCustomer]
      ,stage.[DefaultCurrency]
      ,dateadd(SECOND, convert(bigint, SUBSTRING(stage.UpdatedDateUTC,7,10)), '19700101')
      ,stage.[page_num]
	,GETDATE()
	, 'New - Append' --NEWER UPDATE: Insert the Status_SCD field
  FROM [stg].[XeroContacts] as stage
  --left join (select * from [dbo].[XeroContacts_History] where Record_End_Date is null )  as Hist	 ---NEW UPDATE: only select history records that are still valid
  left join (select * from [dbo].[XeroContacts_History] where left(Status_SCD, 7) = 'Current' ) as Hist  ---NEWER UPDATE: only select history records that are still valid
  on Hist.[ContactID] = stage.[ContactID]
  where Hist.[ContactID]  is null;   -- There is no history, so this record must be new 
  


  -- SECOND

/*** If record has changed update End Date on existing records today's date ***/

Update [dbo].[XeroContacts_History]
set Record_End_Date = GETDATE()    --NEWER UPDATE: Close the record with today's date not yesterdays date
, Status_SCD = 'Old - Updated' --NEWER UPDATE: Update the Status_SCD field
from [stg].[XeroContacts] as stage
  --inner join (select * from [dbo].[XeroContacts_History] where Record_End_Date is null )  as Hist	 ---NEW UPDATE: only select history records that are still valid
 -- inner join (select * from [dbo].[XeroContacts_History] where left(Status_SCD, 7) = 'Current' ) as Hist  ---NEWER UPDATE: only select history records that are still valid
 inner join [dbo].[XeroContacts_History]  as hist --- UPDATE 6: brackets were confusing the update logic
 on stage.[ContactID] = hist.[ContactID]
  where left(hist.Status_SCD, 7) = 'Current' AND (												--NEWEST UPDATE: The selection Above was not being applied to the update
(isnull(	stage.	      [ContactID]	,'')	<>	isnull(	Hist.	      [ContactID]	,'')	) OR
(isnull(	stage.	      [ContactNumber]	,'')	<>	isnull(	Hist.	      [ContactNumber]	,'')	) OR
(isnull(	stage.	      [AccountNumber]	,'')	<>	isnull(	Hist.	      [AccountNumber]	,'')	) OR
(isnull(	stage.	      [ContactStatus]	,'')	<>	isnull(	Hist.	      [ContactStatus]	,'')	) OR
(isnull(	stage.	      [Name]	,'')	<>	isnull(	Hist.	      [Name]	,'')	) OR
(isnull(	stage.	      [FirstName]	,'')	<>	isnull(	Hist.	      [FirstName]	,'')	) OR
(isnull(	stage.	      [LastName]	,'')	<>	isnull(	Hist.	      [LastName]	,'')	) OR
(isnull(	stage.	      [EmailAddress]	,'')	<>	isnull(	Hist.	      [EmailAddress]	,'')	) OR
(isnull(	stage.	      [BankAccountDetails]	,'')	<>	isnull(	Hist.	      [BankAccountDetails]	,'')	) OR
(isnull(	stage.	      [Address]	,'')	<>	isnull(	Hist.	      [Address]	,'')	) OR
(isnull(	stage.	      [CompanyNumber]	,'')	<>	isnull(	Hist.	      [CompanyNumber]	,'')	) OR
(isnull(	stage.	      [TaxNumber]	,'')	<>	isnull(	Hist.	      [TaxNumber]	,'')	) OR
(isnull(	stage.	      [AccountsReceivableTaxType]	,'')	<>	isnull(	Hist.	      [AccountsReceivableTaxType]	,'')	) OR
(isnull(	stage.	      [Phones]	,'')	<>	isnull(	Hist.	      [Phones]	,'')	) OR
(isnull(	stage.	      [IsSupplier]	,'')	<>	isnull(	Hist.	      [IsSupplier]	,'')	) OR
(isnull(	stage.	      [IsCustomer]	,'')	<>	isnull(	Hist.	      [IsCustomer]	,'')	) OR
(isnull(	stage.	      [DefaultCurrency]	,'')	<>	isnull(	Hist.	      [DefaultCurrency]	,'')	) OR
(isnull(dateadd(SECOND, convert(bigint, SUBSTRING(stage.UpdatedDateUTC,7,10)), '19700101'),'')	<>	isnull(	Hist.	      [UpdatedDateUTC]	,'')	)
);

 
 -- THIRD

/*** If record has changed APPEND new record to HIstory ***/

INSERT INTO [dbo].[XeroContacts_History]
     ([ContactID]
      ,[ContactNumber]
      ,[AccountNumber]
      ,[ContactStatus]
      ,[Name]
      ,[FirstName]
      ,[LastName]
      ,[EmailAddress]
      ,[BankAccountDetails]
      ,[Address]
      ,[CompanyNumber]
      ,[TaxNumber]
      ,[AccountsReceivableTaxType]
      ,[AccountsPayableTaxType]
      ,[Phones]
      ,[IsSupplier]
      ,[IsCustomer]
      ,[DefaultCurrency]
      ,[UpdatedDateUTC]
      ,[page_num]
      ,[Record_Start_Date],
	Status_SCD --NEWER UPDATE: Insert the Status_SCD field
           )


SELECT stage.[ContactID]
      ,stage.[ContactNumber]
      ,stage.[AccountNumber]
      ,stage.[ContactStatus]
      ,stage.[Name]
      ,stage.[FirstName]
      ,stage.[LastName]
      ,stage.[EmailAddress]
      ,stage.[BankAccountDetails]
      ,stage.[Address]
      ,stage.[CompanyNumber]
      ,stage.[TaxNumber]
      ,stage.[AccountsReceivableTaxType]
      ,stage.[AccountsPayableTaxType]
      ,stage.[Phones]
      ,stage.[IsSupplier]
      ,stage.[IsCustomer]
      ,stage.[DefaultCurrency]
      ,dateadd(SECOND, convert(bigint, SUBSTRING(stage.UpdatedDateUTC,7,10)), '19700101')
      ,stage.[page_num]
	  ,GETDATE()
	  , 'New - Updated' --NEWER UPDATE: Insert the Status_SCD field
from [stg].[XeroContacts] as stage
  --inner join (select * from [dbo].[XeroContacts_History] where Record_End_Date is null )  as Hist	 ---NEW UPDATE: only select history records that are still valid
  --inner join (select * from [dbo].[XeroContacts_History] where left(Status_SCD, 7) = 'Current' ) as Hist  ---NEWER UPDATE: only select history records that are still valid
  inner join [dbo].[XeroContacts_History]  as Hist -- Update Nov - 03
  on stage.[ContactID] = hist.[ContactID]
  where hist.Status_SCD = 'Old - Updated' AND DATEDIFF(minute,Record_End_Date,GETDATE()) < 5
-------------------------------------------

-- FINALLY 

/*** If record has changed update End Date on existing records to today ***/
/*
Update [dbo].[XeroContacts_History]
set Record_End_Date = GETDATE(),
	Status_SCD = 'Old - Deleted'
FROM [stg].[XeroContacts] as stage
  --Right join (select * from [dbo].[XeroContacts_History] where Record_End_Date is null )  as Hist	 ---NEW UPDATE: only select history records that are still valid
  Right join [dbo].[XeroContacts_History] as Hist  ---NEWER UPDATE: only select history records that are still valid
  on Hist.[ContactID] = stage.[ContactID]
  --where stage.ContactID is null;  -- The record no longer exists in Staging. So It must have been deleted.
  where stage.ContactID is null and left(Hist.Status_SCD, 7) = 'Current'; -- The record no longer exists in Staging. If it is current then delete it.
;*/
----------------------------------------------


-- ****NEWER UPDATE - Everything below here has been added as part of the update*******

Update [dbo].[XeroContacts_History]
Set Status_SCD = REPLACE(Status_SCD, 'New','Current')

from [dbo].[XeroContacts_History]
where Status_SCD like 'New%'
END