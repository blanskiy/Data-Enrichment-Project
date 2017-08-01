
genesis_{006B1D7E-F7B7-4FF2-B88A-0AF7F7465463}    	3011116479	{de931e82-6d8d-4d72-835d-043b58fc1c58}	300041 
 
 select top 100 * from Temp_No_Test_Appr WHERE CLIENTID = '3011116479' 
  AND LOANUID = '{de931e82-6d8d-4d72-835d-043b58fc1c58}' AND 	UNIQUEVENDORID = '300041'

select top 100 * from TBL_Appr_CURRENT_MONTH WHERE CLIENTID = '3011116479' 
  AND LOANUID = '{de931e82-6d8d-4d72-835d-043b58fc1c58}' AND 	UNIQUEVENDORID = '300041'

  select  * from [DataProcessing].[dbo].MapdownloadlogForScrubbing WHERE CLIENTID = '3011116479' 
  AND LOANUID = '{de931e82-6d8d-4d72-835d-043b58fc1c58}' AND 	UNIQUEVENDORID = '300041'
  AND YYYYMM = 201705 and type ='APPR MGMT'


  AND YYYYMM = 201706 and type IN ( 'APPR MGMT','APPR REFER','AVM') 
select top 100 * from [DataProcessing].[dbo].MapdownloadlogForScrubbing WHERE CLIENTID = '3000799848' 
  AND LOANUID = '{f5009877-9443-462c-bfeb-7fc3e4cb6c36}' AND 	UNIQUEVENDORID = '300056'
  AND YYYYMM = 201705 and type IN ( 'APPR MGMT','APPR REFER','AVM') 

   select TOP 1 * FROM [DataProcessing].[dbo].MapdownloadlogForScrubbing
	WHERE YYYYMM >= 201601
	and type = 'APPR MGMT' and uniquevendorid = '300023' 

	 insert into TBL_Scrub_SubmitType (Prod_Name, Product_number, Column_Name, position, position_Value, To_enter_value, Uniquevendorid)
  select 'APPR',1,'misc',10, 'PlaceOrder','Order','300106'
  
  select *  FROM DataProcessing.dbo.lu_PAPI_VendorMapping

   SELECT * FROM TBL_Scrub_SubmitType WHERE UNIQUEVENDORID = '300079' --- TRANSID = '{27b9cec9-2252-439b-ad90-f91e7b19545a}'

   SELECT * FROM [DataProcessing].[dbo].Temp_AllVendorData WHERE UNIQUEVENDORID = '300079' AND ClientID = 3011080025
   
   AND TRANSID = '{27b9cec9-2252-439b-ad90-f91e7b19545a}'

  1057254,Complete,|1004 - FHA Single Family Residence|,aleon@callequity.net

alter table [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
add [YYYYMM]  AS (CONVERT([bigint],left(CONVERT([varchar],[LogDate],(112)),(6))))

update A 
set A.[YYYYMM] = A.LogDate
from 
[ArchiveData].[dbo].[AllTrans_For_Reports_2016_17] A

select top 1 [YYYYMM] from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17] order by [YYYYMM] desc

DECLARE @ReportDate varchar(6)
	SELECT @ReportDate = MAX(REPLACE(activityMonth, '-','')) FROM MaventBillingUpload
	print @ReportDate

  
  select count(transid) as total
  from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
  where type = 'APPR MGMT' and [YYYYMM]  = 201701 and submittype = 'Order'
  
  
  select count(transid) as total
  from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
  where type = 'APPR MGMT' and [YYYYMM] > = 201703 and submittype = 'Order' --- 135914

  select count(transid) as total
  from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
  where type = 'APPR MGMT' and [YYYYMM] > = 201702  and [YYYYMM] < 201704 and submittype = 'Order'

  select count(transid) as total
  from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
  where type = 'APPR MGMT' and [YYYYMM] > = 201701  and [YYYYMM] < 201703 and submittype = 'Order'

  select count(transid) as total
  from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
  where type = 'APPR MGMT' and [YYYYMM] > = 201612  and [YYYYMM] < 201702 and submittype = 'Order'

  select [ClientID],[LoanUID],[UniqueVendorID],Lender_loan_num, count(transid) as total
  from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
  where type = 'APPR MGMT' and [YYYYMM] > = 201703 and submittype = 'Order'
  group by [ClientID],[LoanUID],[UniqueVendorID],Lender_loan_num
  having count(1) > 1  --- 965

  --- drop table TMP_APPR_RESEARCH

  select [ClientID],[LoanUID],[UniqueVendorID],Lender_loan_num, count(transid) as total,[YYYYMM]  into TMP_APPR_RESEARCH
  from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
  where type = 'APPR MGMT' and [YYYYMM] > = 201703 and submittype = 'Order'
  group by [ClientID],[LoanUID],[UniqueVendorID],Lender_loan_num
  having count(1) > 1

  select A.* from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17] a 
  inner join TMP_APPR_RESEARCH t on t.ClientID = a.ClientID and t.LoanUID = a.LoanUID
  where   -----a.ClientID = '11082174'
  a.UniqueVendorID = '300034'

  --'300041' and a.ClientID = '11082174'

  select * from TMP_APPR_RESEARCH
  
  where a.ClientID in ('11082174','11125480','11120198','11125196','11119877','11143076','11141421')

  select top 1 * from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17] where partner = 'First American Lenders Advantage'
  SELECT   CONVERT(DATETIME, CONVERT(CHAR(10), DATEADD(month, -1, getdate()),101) + ' 00:00')
  select CONVERT(DATETIME, CONVERT(CHAR(10), DATEADD(DD, 1 -DATEPART(DD,getdate()), getdate()),101) + ' 00:00')
  select CONVERT(DATETIME, CONVERT(CHAR(10), getdate(), 101) + ' 00:00')
----*******************************************************************************************************

  select [ClientID],[LoanUID],[UniqueVendorID]
  from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
  where type = 'Credit' and [YYYYMM] = 201704  
  except
  select [ClientID],[LoanUID],[UniqueVendorID]
  from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
  where type = 'Credit' and [YYYYMM] <= 201703 and [YYYYMM] >= 201610   ----- 754473

  ------ select distinct submittype  from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17] where type = 'Credit' and [YYYYMM] = 201704
  -- select distinct submittype  from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17] where type = 'Credit' and [YYYYMM] = 201703
  select distinct submittype  from [EC1VDBMIS01\MISDB01].[ArchiveData].[dbo].[AllTrans_03_17_For_Reports] where type = 'Credit'
 
  select [ClientID],[LoanUID],[UniqueVendorID],Lender_loan_num
  from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
  where type = 'Credit' and [YYYYMM] = 201704  
  except
    select [ClientID],[LoanUID],[UniqueVendorID],Lender_loan_num
  from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
  where type = 'Credit' and [YYYYMM] <= 201703 and [YYYYMM] >= 201702


  select loanuid,uniquevendorid,clientid from MapdownloadlogForScrubbing where YYYYMM = 201704 and  type = 'Credit' -----1038517
  except
  select loanuid,uniquevendorid,clientid from MapdownloadlogForScrubbing where YYYYMM < 201704 and YYYYMM > 201610 and  type = 'Credit'  ---764774

  select loanuid,uniquevendorid,clientid from MapdownloadlogForScrubbing where YYYYMM = 201703 and  type = 'Credit' 
  except
  select loanuid,uniquevendorid,clientid from MapdownloadlogForScrubbing where YYYYMM < 201703 and YYYYMM > 201608 and  type = 'Credit'   ---862565

  select loanuid,uniquevendorid,clientid from MapdownloadlogForScrubbing where YYYYMM = 201702 and  type = 'Credit' 
  except
  select loanuid,uniquevendorid,clientid from MapdownloadlogForScrubbing where YYYYMM < 201702 and YYYYMM > 201607 and  type = 'Credit'
  ------------------------------------------------------------------------------------------------------------------------------------------

  select loanuid,uniquevendorid,clientid from MapdownloadlogForScrubbing where YYYYMM = 201704 and  type = 'Flood' -----
  except
  select loanuid,uniquevendorid,clientid from MapdownloadlogForScrubbing where YYYYMM < 201704 and YYYYMM > 201610 and  type = 'Flood'  ---238472

  select loanuid,uniquevendorid,clientid from MapdownloadlogForScrubbing where YYYYMM = 201703 and  type = 'Flood' 
  except
  select loanuid,uniquevendorid,clientid from MapdownloadlogForScrubbing where YYYYMM < 201703 and YYYYMM > 201608 and  type = 'Flood'   ---264904

  select loanuid,uniquevendorid,clientid from MapdownloadlogForScrubbing where YYYYMM = 201702 and  type = 'Flood' 
  except
  select loanuid,uniquevendorid,clientid from MapdownloadlogForScrubbing where YYYYMM < 201702 and YYYYMM > 201607 and  type = 'Flood'

  -------------------------------------------------------------------------------------------------------------------------------------
  
  select loanuid,uniquevendorid,clientid from MapdownloadlogForScrubbing where YYYYMM = 201704 and  type = 'Fraud' -----
  except
  select loanuid,uniquevendorid,clientid from MapdownloadlogForScrubbing where YYYYMM < 201704 and YYYYMM > 201610 and  type = 'Fraud'  ---238472

  select loanuid,uniquevendorid,clientid from MapdownloadlogForScrubbing where YYYYMM = 201703 and  type = 'Fraud' 
  except
  select loanuid,uniquevendorid,clientid from MapdownloadlogForScrubbing where YYYYMM < 201703 and YYYYMM > 201608 and  type = 'Fraud'   ---264904

  select loanuid,uniquevendorid,clientid from MapdownloadlogForScrubbing where YYYYMM = 201702 and  type = 'Fraud' 
  except
  select loanuid,uniquevendorid,clientid from MapdownloadlogForScrubbing where YYYYMM < 201702 and YYYYMM > 201607 and  type = 'Fraud'
  -----------------------------------------------------------------------------------------------------------------------------------------------------
  WITH A AS (
  select loanuid,uniquevendorid,clientid 
  from MapdownloadlogForScrubbing where YYYYMM = 201704 and  type =  'APPR MGMT'  
  except
  select loanuid,uniquevendorid,clientid from MapdownloadlogForScrubbing where YYYYMM < 201701 and YYYYMM > 201601 and  type =  'APPR MGMT'  
  )

  select m.* into TBL_APPR_201704 from A inner join MapdownloadlogForScrubbing m on m.ClientID = a.ClientID and m.LoanUID = a.LoanUID 
  and m.UniqueVendorID = a.UniqueVendorID
  and m.YYYYMM = 201704
  and m.type = 'APPR MGMT'  

  DELETE 
	-- select *
	FROM TBL_APPR_201704
	WHERE ISNULL(ClientID,'')  IN (SELECT Company FROM lu_test_by_company)
		OR ISNULL(Borrower,'') IN (SELECT  Borname FROM lu_Test_By_Borname)OR ISNULL(Clientid,'')  IN (SELECT Clientid FROM lu_Test_By_ClientID)
		OR ISNULL(email,'')  LIKE '%@elliemae.com'
		OR ISNULL(email,'')  LIKE '%@contoursoft.com'
		OR ISNULL(email,'') LIKE  '%@genesis2000.com'
		OR ISNULL(AccessCode,'') IN (SELECT Access_Code FROM lu_Test_By_Access_Code)
		OR (ISNULL(clientid,'')  BETWEEN '10000000' AND '10999999' AND LEN(ISNULL(ClientID,'')) = 8)
		OR ISNULL(Borrower,'')  = ''


  DELETE
	-- select *
	FROM TBL_APPR_201704
	WHERE clientid IN (SELECT l.clientid FROM TBL_APPR_201704 t JOIN lu_mapfiles l ON t.uniquevendorid = l.uniquevendorid
		WHERE t.type IN  ( 'APPR MGMT','APPR REFER','AVM') AND l.clientid IS NOT NULL 
		AND t.clientid = l.clientid)

		select distinct loanuid,uniquevendorid,clientid from TBL_APPR_201704   --112610
		select distinct loanuid,uniquevendorid,clientid from [ArchiveData].dbo.AllTrans_For_Reports_2016_17
        where type = 'APPR MGMT'  and YYYYMM = 201704  --93314

		select distinct loanuid,uniquevendorid,clientid from [ArchiveData].dbo.AllTrans_For_Reports_2016_17
        where type = 'APPR MGMT'  and YYYYMM = 201704  --93314
		except
		select distinct loanuid,uniquevendorid,clientid from [ArchiveData].dbo.AllTrans_For_Reports_2016_17
        where type = 'APPR MGMT'  and YYYYMM < 201704 and YYYYMM > 201601 --- 90522

		select distinct loanuid,uniquevendorid,clientid from [ArchiveData].dbo.AllTrans_For_Reports_2016_17
        where type = 'APPR MGMT'  and YYYYMM = 201703  --99760
		except
		select distinct loanuid,uniquevendorid,clientid from [ArchiveData].dbo.AllTrans_For_Reports_2016_17
        where type = 'APPR MGMT'  and YYYYMM < 201703 and YYYYMM > 201601  --96822

		select distinct loanuid,uniquevendorid,clientid from [ArchiveData].dbo.AllTrans_For_Reports_2016_17
        where type = 'APPR MGMT'  and YYYYMM = 201702  --73067
		except
		select distinct loanuid,uniquevendorid,clientid from [ArchiveData].dbo.AllTrans_For_Reports_2016_17
        where type = 'APPR MGMT'  and YYYYMM < 201702 and YYYYMM > 201601 ---70502

		select distinct loanuid,uniquevendorid,clientid from [ArchiveData].dbo.AllTrans_For_Reports_2016_17
        where type = 'APPR MGMT'  and YYYYMM = 201701  --67228
		except
		select distinct loanuid,uniquevendorid,clientid from [ArchiveData].dbo.AllTrans_For_Reports_2016_17
        where type = 'APPR MGMT'  and YYYYMM < 201701 and YYYYMM > 201601 ---63673
----------------------------------------------------------------------------------------------------------------


		select distinct loanuid,uniquevendorid,clientid from [ArchiveData].dbo.AllTrans_For_Reports_2016_17
        where type = 'APPR MGMT'  and YYYYMM = 201704 and submittype = 'order'  --71651
		except
		select distinct loanuid,uniquevendorid,clientid from [ArchiveData].dbo.AllTrans_For_Reports_2016_17
        where type = 'APPR MGMT'  and YYYYMM < 201704 and YYYYMM > 201601 and submittype = 'order' --- 69243

		select distinct loanuid,uniquevendorid,clientid from [ArchiveData].dbo.AllTrans_For_Reports_2016_17
        where type = 'APPR MGMT'  and YYYYMM = 201703 and submittype = 'order'  --75268
		except
		select distinct loanuid,uniquevendorid,clientid from [ArchiveData].dbo.AllTrans_For_Reports_2016_17
        where type = 'APPR MGMT'  and YYYYMM < 201703 and YYYYMM > 201601 and submittype = 'order'  --73188

		select distinct loanuid,uniquevendorid,clientid from [ArchiveData].dbo.AllTrans_For_Reports_2016_17
        where type = 'APPR MGMT'  and YYYYMM = 201702 and submittype = 'order'  --54644
		except
		select distinct loanuid,uniquevendorid,clientid from [ArchiveData].dbo.AllTrans_For_Reports_2016_17
        where type = 'APPR MGMT'  and YYYYMM < 201702 and YYYYMM > 201601 and submittype = 'order' ---53167

		select distinct loanuid,uniquevendorid,clientid from [ArchiveData].dbo.AllTrans_For_Reports_2016_17
        where type = 'APPR MGMT'  and YYYYMM = 201701 and submittype = 'order'  --35404
		except
		select distinct loanuid,uniquevendorid,clientid from [ArchiveData].dbo.AllTrans_For_Reports_2016_17
        where type = 'APPR MGMT'  and YYYYMM < 201701 and YYYYMM > 201601 and submittype = 'order' ---33589


		select * from [ArchiveData].dbo.AllTrans_For_Reports_2016_17
        where type = 'APPR MGMT'  and YYYYMM = 201704 and submittype = 'order'  ---71651




  ----------------------------------------------------------------------------------------------------------------------------------------------------
  
  drop table TBL_Title_201704
  
  with a as (select loanuid,uniquevendorid,clientid 
  from MapdownloadlogForScrubbing where YYYYMM = 201701 and  type = 'Title' 
  ---and UniqueVendorID <> '400091' 
  except
  select loanuid,uniquevendorid,clientid from MapdownloadlogForScrubbing where YYYYMM < 201701 and YYYYMM > 201601 and  type = 'Title'  ---48022
  )

  select m.* into TBL_Title_201701 from A inner join MapdownloadlogForScrubbing m on m.ClientID = a.ClientID and m.LoanUID = a.LoanUID 
  and m.UniqueVendorID = a.UniqueVendorID
  and m.YYYYMM = 201701
  and m.type = 'Title'

  delete 
-- select *
from TBL_Title_201701
where ISNULL(ClientID,'')  IN (SELECT Company FROM lu_test_by_company)
OR ISNULL(Borrower,'') IN (SELECT  Borname FROM lu_Test_By_Borname)OR ISNULL(Clientid,'')  IN (SELECT Clientid FROM lu_Test_By_ClientID)
OR ISNULL(email,'')  LIKE '%@elliemae.com'
OR ISNULL(email,'')  like '%@contoursoft.com'
OR ISNULL(email,'') like  '%@genesis2000.com'
OR ISNULL(AccessCode,'') IN (SELECT Access_Code FROM lu_Test_By_Access_Code)
OR (ISNULL(clientid,'')  BETWEEN '10000000' and '10999999' AND Len(ISNULL(ClientID,'')) = 8)
OR ISNULL(Borrower,'')  = ''
OR ISNULL(Borrower,'') like '% HOMEOWNER%'

delete TBL_Title_201701 where vendorid = '400033'
delete t from TBL_Title_201701 t inner join lu_test_by_borname l on l.borname = t.Borrower
delete t from TBL_Title_201701 t inner join lu_test_by_clientid l on l.clientid = t.clientid


select distinct loanuid,uniquevendorid,clientid from TBL_Title_201704 --47849

with a as (
select  loanuid,uniquevendorid,clientid from TBL_Title_201704
except
select loanuid,uniquevendorid,clientid from [ArchiveData].dbo.AllTrans_For_Reports_2016_17
where type = 'Title' and YYYYMM = 201704
)

select m.* from MapdownloadlogForScrubbing m inner join a on a.loanuid = m.loanuid and a.uniquevendorid = m.uniquevendorid
and a.clientid = m.ClientID and m.YYYYMM = 201704 and  m.type = 'Title'

--- 1 case: misc like '%Price Quote%'
--- 
---- 3 case: URL like '%PAPI%'   ----- no records in combination of PAPA and Uniquevendorid ='400099'

select * from TBL_Title_201704 where misc not like '%Price Quote%' ---67558
select distinct loanuid,uniquevendorid,clientid from TBL_Title_201704 where misc not like '%Price Quote%'  ---44514
select distinct loanuid,uniquevendorid,clientid from TBL_Title_201704 where misc not like '%Price Quote%'
select distinct loanuid,uniquevendorid,clientid from TBL_Title_201704 where  URL like '%PAPI%' ---13913 
select distinct loanuid,uniquevendorid,clientid from TBL_Title_201704 where  URL like '%PAPI%' and Uniquevendorid ='400099'  ---null
select distinct loanuid,uniquevendorid,clientid from TBL_Title_201704 where misc not like '%Price Quote%' AND URL not like '%PAPI%' ---30601
select distinct loanuid,uniquevendorid,clientid from TBL_Title_201704 where URL not like '%PAPI%' ---33936

select distinct loanuid,uniquevendorid,clientid from TBL_Title_201704 where misc not like '%Price Quote%' and URL not like '%PAPI%' 
and UniqueVendorID <> '400091'  --22130
select distinct loanuid,uniquevendorid,clientid from TBL_Title_201703 where misc not like '%Price Quote%' and URL not like '%PAPI%' ---35320
select distinct loanuid,uniquevendorid,clientid from TBL_Title_201702 where misc not like '%Price Quote%' and URL not like '%PAPI%' ---28653
select distinct loanuid,uniquevendorid,clientid from TBL_Title_201701 where misc not like '%Price Quote%' and URL not like '%PAPI%'   ---27094

select * INTO tbl_tITLE_TEST_201704 from TBL_Title_201704

  DELETE tbl_tITLE_TEST_201704 WHERE misc like '%Price Quote%'
  DELETE tbl_tITLE_TEST_201704 WHERE URL like '%PAPI%'
  SELECT distinct loanuid,uniquevendorid,clientid from tbl_tITLE_TEST_201704

select * from [ArchiveData].[dbo].[AllTrans_04_17_For_Reports] where type = 'Title' ---37981
select distinct loanuid,uniquevendorid,clientid from [ArchiveData].[dbo].[AllTrans_04_17_For_Reports] where type = 'Title' ---37981


select distinct loanuid,uniquevendorid,clientid from [ArchiveData].[dbo].[AllTrans_04_17_For_Reports] where type = 'Title' ---37981
and UniqueVendorID <> '400091' ---- 29508

select distinct loanuid,uniquevendorid,clientid from TBL_Title_201704 where misc not like '%Price Quote%' and URL not like '%PAPI%'
order by loanuid

select distinct loanuid,uniquevendorid,clientid from TBL_Title_201704 where misc  like '%Price Quote%' and URL  like '%PAPI%'
order by loanuid

 select * from MapdownloadlogForScrubbing where YYYYMM = 201704 and  type = 'Title' 
 and loanuid = '{4ed1c632-319a-4cff-addf-611141545e03}'

  select * from MapdownloadlogForScrubbing where YYYYMM = 201704 and  type = 'Title' 
 and loanuid = '{01207e0b-e923-4144-8580-79cbb0559176}'

  select * from MapdownloadlogForScrubbing where YYYYMM = 201704 and  type = 'Title' 
 and loanuid = '{003a0c82-3cfb-4148-a5a0-b63ae48c6610}'

  select * from MapdownloadlogForScrubbing where   type = 'Title' 
 and loanuid = '{001a4a01-0705-4771-b21d-f545fee5e517}'

  select loanuid,uniquevendorid,clientid from MapdownloadlogForScrubbing where YYYYMM = 201703 and  type = 'Title' 
  except
  select loanuid,uniquevendorid,clientid from MapdownloadlogForScrubbing where YYYYMM < 201703 and YYYYMM > 201608 and  type = 'Title'   ---

  select loanuid,uniquevendorid,clientid from MapdownloadlogForScrubbing where YYYYMM = 201702 and  type = 'Title' 
  except
  select loanuid,uniquevendorid,clientid from MapdownloadlogForScrubbing where YYYYMM < 201702 and YYYYMM > 201607 and  type = 'Title'





  
  
  select loanuid,uniquevendorid,clientid from MapdownloadlogForScrubbing where YYYYMM = 201703 and  type = 'Credit'

  select [ClientID],[LoanUID],[UniqueVendorID]
  from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
  where type = 'Credit' and [YYYYMM] = 201702  
  except
  select [ClientID],[LoanUID],[UniqueVendorID]
  from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
  where type = 'Credit' and [YYYYMM] <= 201701 and [YYYYMM] >= 201608 ----- 699826

  select [ClientID],[LoanUID],[UniqueVendorID]
  from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
  where type = 'Credit' and [YYYYMM] = 201701  
  except
  select [ClientID],[LoanUID],[UniqueVendorID]
  from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
  where type = 'Credit' and [YYYYMM] <= 201612 and [YYYYMM] >= 201607  ----671329
  ----**********************************************************************************************

  select [ClientID],[LoanUID],[UniqueVendorID]
  from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
  where type = 'Flood' and [YYYYMM] = 201704  
  except
  select [ClientID],[LoanUID],[UniqueVendorID]
  from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
  where type = 'Flood' and [YYYYMM] <= 201703 and [YYYYMM] >= 201610   ----- 237267

  select [ClientID],[LoanUID],[UniqueVendorID]
  from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
  where type = 'Flood' and [YYYYMM] = 201704  
  except
  select [ClientID],[LoanUID],[UniqueVendorID]
  from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
  where type = 'Flood' and [YYYYMM] = 201703

  select [ClientID],[LoanUID],[UniqueVendorID]
  from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
  where type = 'Flood' and [YYYYMM] = 201702  
  except
  select [ClientID],[LoanUID],[UniqueVendorID]
  from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
  where type = 'Flood' and [YYYYMM] <= 201701 and [YYYYMM] >= 201608  ---196834
  
  select [ClientID],[LoanUID],[UniqueVendorID]
  from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
  where type = 'Flood' and [YYYYMM] = 201702  
  except
  select [ClientID],[LoanUID],[UniqueVendorID]
  from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
  where type = 'Flood' and [YYYYMM] = 201701   ---198498
  
  ----***********************************************************************************************


  
  select [ClientID],[LoanUID],[UniqueVendorID]
  from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
  where type = 'Credit' and [YYYYMM] = 201702  
  except
  select [ClientID],[LoanUID],[UniqueVendorID]
  from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
  where type = 'Credit' and [YYYYMM] <= 201701 and [YYYYMM] >= 201608 ----- 699826

  select [ClientID],[LoanUID],[UniqueVendorID]
  from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
  where type = 'Credit' and [YYYYMM] = 201701  
  except
  select [ClientID],[LoanUID],[UniqueVendorID]
  from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
  where type = 'Credit' and [YYYYMM] <= 201612 and [YYYYMM] >= 201607  ----671329

  -------------------------------*************credit***********************_________________________________________
        
		select  loanuid,uniquevendorid,clientid from [ArchiveData].dbo.AllTrans_For_Reports_2016_17
        where type = 'Credit'  and YYYYMM = 201704 ---810898 
		intersect
		select  loanuid,uniquevendorid,clientid from [ArchiveData].dbo.AllTrans_For_Reports_2016_17
        where type = 'Credit'  and YYYYMM = 201601   ---542

		select  loanuid,uniquevendorid,clientid from [ArchiveData].dbo.AllTrans_For_Reports_2016_17
        where type = 'Credit'  and YYYYMM = 201704 ---810898 
		intersect
		select  loanuid,uniquevendorid,clientid from [ArchiveData].dbo.AllTrans_For_Reports_2016_17
        where type = 'Credit'  and YYYYMM = 201701
		
		select  loanuid,uniquevendorid,clientid from [ArchiveData].dbo.AllTrans_For_Reports_2016_17
        where type = 'Disclosure'  and YYYYMM = 201704 ---810898 
		intersect
		select  loanuid,uniquevendorid,clientid from [ArchiveData].dbo.AllTrans_For_Reports_2016_17
        where type = 'Disclosure'  and YYYYMM < 201702 and YYYYMM > 201601 
		
		
		
		select distinct loanuid,uniquevendorid,clientid from [ArchiveData].dbo.AllTrans_For_Reports_2016_17
        where type = 'Credit'  and YYYYMM = 201704 ---810898 
		except
		select distinct loanuid,uniquevendorid,clientid from [ArchiveData].dbo.AllTrans_For_Reports_2016_17
        where type = 'Credit'  and YYYYMM < 201703 and YYYYMM > 201601 

		select distinct loanuid,uniquevendorid,clientid from [ArchiveData].dbo.AllTrans_For_Reports_2016_17
        where type = 'Credit'  and YYYYMM = 201703 ---916364
		except
		select distinct loanuid,uniquevendorid,clientid from [ArchiveData].dbo.AllTrans_For_Reports_2016_17
        where type = 'Credit'  and YYYYMM < 201703 and YYYYMM > 201601 ---842942

		select distinct loanuid,uniquevendorid,clientid from [ArchiveData].dbo.AllTrans_For_Reports_2016_17
        where type = 'Credit'  and YYYYMM = 201702 --753604
		except
		select distinct loanuid,uniquevendorid,clientid from [ArchiveData].dbo.AllTrans_For_Reports_2016_17
        where type = 'Credit'  and YYYYMM < 201702 and YYYYMM > 201601 ---690455

		select distinct loanuid,uniquevendorid,clientid from [ArchiveData].dbo.AllTrans_For_Reports_2016_17
        where type = 'Credit'  and YYYYMM = 201701 ---728540
		except
		select distinct loanuid,uniquevendorid,clientid from [ArchiveData].dbo.AllTrans_For_Reports_2016_17
        where type = 'Credit'  and YYYYMM < 201701 and YYYYMM > 201601 

		 ---************************************************** fraud******************************************************
		 select distinct loanuid,uniquevendorid,clientid from [ArchiveData].dbo.AllTrans_For_Reports_2016_17
        where type = 'fraud'  and YYYYMM = 201704 ---236020
		except
		select distinct loanuid,uniquevendorid,clientid from [ArchiveData].dbo.AllTrans_For_Reports_2016_17
        where type = 'fraud'  and YYYYMM < 201704 and YYYYMM > 201601 ---204569 

		select distinct loanuid,uniquevendorid,clientid from [ArchiveData].dbo.AllTrans_For_Reports_2016_17
        where type = 'fraud'  and YYYYMM = 201703 ---255802
		except
		select distinct loanuid,uniquevendorid,clientid from [ArchiveData].dbo.AllTrans_For_Reports_2016_17
        where type = 'fraud'  and YYYYMM < 201703 and YYYYMM > 201601 ---224811

		select distinct loanuid,uniquevendorid,clientid from [ArchiveData].dbo.AllTrans_For_Reports_2016_17
        where type = 'fraud'  and YYYYMM = 201702 --191764
		except
		select distinct loanuid,uniquevendorid,clientid from [ArchiveData].dbo.AllTrans_For_Reports_2016_17
        where type = 'fraud'  and YYYYMM < 201702 and YYYYMM > 201601 ---168066

		select distinct loanuid,uniquevendorid,clientid from [ArchiveData].dbo.AllTrans_For_Reports_2016_17
        where type = 'fraud'  and YYYYMM = 201701 ---185123
		except
		select distinct loanuid,uniquevendorid,clientid from [ArchiveData].dbo.AllTrans_For_Reports_2016_17
        where type = 'fraud'  and YYYYMM < 201701 and YYYYMM > 201601 ---155158

		--------***************************** TITLE *******************************************************
       select distinct loanuid,uniquevendorid,clientid from [ArchiveData].dbo.AllTrans_For_Reports_2016_17
        where type = 'Title'  and YYYYMM = 201704 ---37981
		except
		select distinct loanuid,uniquevendorid,clientid from [ArchiveData].dbo.AllTrans_For_Reports_2016_17
        where type = 'Title'  and YYYYMM < 201704 and YYYYMM > 201601 ---37880

		select distinct loanuid,uniquevendorid,clientid from [ArchiveData].dbo.AllTrans_For_Reports_2016_17
        where type = 'Title'  and YYYYMM = 201703 ---42789
		except
		select distinct loanuid,uniquevendorid,clientid from [ArchiveData].dbo.AllTrans_For_Reports_2016_17
        where type = 'Title'  and YYYYMM < 201703 and YYYYMM > 201601 ---42661

		select distinct loanuid,uniquevendorid,clientid from [ArchiveData].dbo.AllTrans_For_Reports_2016_17
        where type = 'Title'  and YYYYMM = 201702 --34288
		except
		select distinct loanuid,uniquevendorid,clientid from [ArchiveData].dbo.AllTrans_For_Reports_2016_17
        where type = 'Title'  and YYYYMM < 201702 and YYYYMM > 201601 ---34164

		select distinct loanuid,uniquevendorid,clientid from [ArchiveData].dbo.AllTrans_For_Reports_2016_17
        where type = 'Title'  and YYYYMM = 201701 ---34188
		except
		select distinct loanuid,uniquevendorid,clientid from [ArchiveData].dbo.AllTrans_For_Reports_2016_17
        where type = 'Title'  and YYYYMM < 201701 and YYYYMM > 201601 ---

		-----------------------------**************************** FLOOD ***************************************

		select distinct loanuid,uniquevendorid,clientid from [ArchiveData].dbo.AllTrans_For_Reports_2016_17
        where type = 'Flood'  and YYYYMM = 201704 ---239678
		except
		select distinct loanuid,uniquevendorid,clientid from [ArchiveData].dbo.AllTrans_For_Reports_2016_17
        where type = 'Flood'  and YYYYMM < 201704 and YYYYMM > 201601 ---237061

		select distinct loanuid,uniquevendorid,clientid from [ArchiveData].dbo.AllTrans_For_Reports_2016_17
        where type = 'Flood'  and YYYYMM = 201703 ---266346
		except
		select distinct loanuid,uniquevendorid,clientid from [ArchiveData].dbo.AllTrans_For_Reports_2016_17
        where type = 'Flood'  and YYYYMM < 201703 and YYYYMM > 201601 ---263386

		select distinct loanuid,uniquevendorid,clientid from [ArchiveData].dbo.AllTrans_For_Reports_2016_17
        where type = 'Flood'  and YYYYMM = 201702 --198871
		except
		select distinct loanuid,uniquevendorid,clientid from [ArchiveData].dbo.AllTrans_For_Reports_2016_17
        where type = 'Flood'  and YYYYMM < 201702 and YYYYMM > 201601 ---196615

		select distinct loanuid,uniquevendorid,clientid from [ArchiveData].dbo.AllTrans_For_Reports_2016_17
        where type = 'Flood'  and YYYYMM = 201701 ---186727
		except
		select distinct loanuid,uniquevendorid,clientid from [ArchiveData].dbo.AllTrans_For_Reports_2016_17
        where type = 'Flood'  and YYYYMM < 201701 and YYYYMM > 201601  --183730

		------- ********************************************* DISCLOSURE*********************************************
		select distinct loanuid,uniquevendorid,clientid from [ArchiveData].dbo.AllTrans_For_Reports_2016_17
        where type = 'Disclosure'  and YYYYMM = 201704 ---1430 
		except
		select distinct loanuid,uniquevendorid,clientid from [ArchiveData].dbo.AllTrans_For_Reports_2016_17
        where type = 'Disclosure'  and YYYYMM < 201703 and YYYYMM > 201601 ---1400

		select distinct loanuid,uniquevendorid,clientid from [ArchiveData].dbo.AllTrans_For_Reports_2016_17
        where type = 'Disclosure'  and YYYYMM = 201703 ---1591
		except
		select distinct loanuid,uniquevendorid,clientid from [ArchiveData].dbo.AllTrans_For_Reports_2016_17
        where type = 'Disclosure'  and YYYYMM < 201703 and YYYYMM > 201601 ---1503

		select distinct loanuid,uniquevendorid,clientid from [ArchiveData].dbo.AllTrans_For_Reports_2016_17
        where type = 'Disclosure'  and YYYYMM = 201702 --1152
		except
		select distinct loanuid,uniquevendorid,clientid from [ArchiveData].dbo.AllTrans_For_Reports_2016_17
        where type = 'Disclosure'  and YYYYMM < 201702 and YYYYMM > 201601 ---1084

		select distinct loanuid,uniquevendorid,clientid from [ArchiveData].dbo.AllTrans_For_Reports_2016_17
        where type = 'Disclosure'  and YYYYMM = 201701 ---1158
		except
		select distinct loanuid,uniquevendorid,clientid from [ArchiveData].dbo.AllTrans_For_Reports_2016_17
        where type = 'Disclosure'  and YYYYMM < 201701 and YYYYMM > 201601 ---1033
  
  
 --------*********************************************************************************** 

 ------- ********************************************* Documents*********************************************
		select distinct loanuid,uniquevendorid,clientid from [ArchiveData].dbo.AllTrans_For_Reports_2016_17
        where type = 'Documents'  and YYYYMM = 201704 ---24032
		except
		select distinct loanuid,uniquevendorid,clientid from [ArchiveData].dbo.AllTrans_For_Reports_2016_17
        where type = 'Documents'  and YYYYMM < 201703 and YYYYMM > 201601 ---23936

		select distinct loanuid,uniquevendorid,clientid from [ArchiveData].dbo.AllTrans_For_Reports_2016_17
        where type = 'Documents'  and YYYYMM = 201703 ---24857
		except
		select distinct loanuid,uniquevendorid,clientid from [ArchiveData].dbo.AllTrans_For_Reports_2016_17
        where type = 'Documents'  and YYYYMM < 201703 and YYYYMM > 201601 ---24647

		select distinct loanuid,uniquevendorid,clientid from [ArchiveData].dbo.AllTrans_For_Reports_2016_17
        where type = 'Documents'  and YYYYMM = 201702 --18528
		except
		select distinct loanuid,uniquevendorid,clientid from [ArchiveData].dbo.AllTrans_For_Reports_2016_17
        where type = 'Documents'  and YYYYMM < 201702 and YYYYMM > 201601 ---18266

		select distinct loanuid,uniquevendorid,clientid from [ArchiveData].dbo.AllTrans_For_Reports_2016_17
        where type = 'Documents'  and YYYYMM = 201701 ---18942
		except
		select distinct loanuid,uniquevendorid,clientid from [ArchiveData].dbo.AllTrans_For_Reports_2016_17
        where type = 'Documents'  and YYYYMM < 201701 and YYYYMM > 201601 ---18530


		----------------===========================================================================
		------- ********************************************* MI *********************************************
		select distinct loanuid,uniquevendorid,clientid from [ArchiveData].dbo.AllTrans_For_Reports_2016_17
        where type = 'MORTINS'  and YYYYMM = 201704 ---87443
		except
		select distinct loanuid,uniquevendorid,clientid from [ArchiveData].dbo.AllTrans_For_Reports_2016_17
        where type = 'MORTINS'  and YYYYMM < 201703 and YYYYMM > 201601 ---82686

		select distinct loanuid,uniquevendorid,clientid from [ArchiveData].dbo.AllTrans_For_Reports_2016_17
        where type = 'MORTINS'  and YYYYMM = 201703 ---91498
		except
		select distinct loanuid,uniquevendorid,clientid from [ArchiveData].dbo.AllTrans_For_Reports_2016_17
        where type = 'MORTINS'  and YYYYMM < 201703 and YYYYMM > 201601 ---77200

		select distinct loanuid,uniquevendorid,clientid from [ArchiveData].dbo.AllTrans_For_Reports_2016_17
        where type = 'MORTINS'  and YYYYMM = 201702 --70017
		except
		select distinct loanuid,uniquevendorid,clientid from [ArchiveData].dbo.AllTrans_For_Reports_2016_17
        where type = 'MORTINS'  and YYYYMM < 201702 and YYYYMM > 201601 ---58960

		select distinct loanuid,uniquevendorid,clientid from [ArchiveData].dbo.AllTrans_For_Reports_2016_17
        where type = 'MORTINS'  and YYYYMM = 201701 ---61816
		except
		select distinct loanuid,uniquevendorid,clientid from [ArchiveData].dbo.AllTrans_For_Reports_2016_17
        where type = 'MORTINS'  and YYYYMM < 201701 and YYYYMM > 201601 ---52808


		----------------===========================================================================



  select [ClientID],[LoanUID],[UniqueVendorID],Lender_loan_num
  from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
  where type = 'Credit' and [YYYYMM] = 201704 and  
  intersect
    select [ClientID],[LoanUID],[UniqueVendorID],Lender_loan_num
  from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
  where type = 'Credit' and [YYYYMM] <= 201703 and [YYYYMM] >= 201702   ----- April new credit check for 60 days 

  select [ClientID],[LoanUID],[UniqueVendorID],Lender_loan_num
  from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
  where type = 'Credit' and [YYYYMM] = 201704  
  except
    select [ClientID],[LoanUID],[UniqueVendorID],Lender_loan_num
  from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
  where type = 'Credit' and [YYYYMM] <= 201703 and [YYYYMM] >= 201701  ----- April new credit check for 90 days 658365  minus 2% 
--------------------------------------------------------------------------------------------------------------------------------------
  select [ClientID],[LoanUID],[UniqueVendorID],Lender_loan_num
  from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
  where type = 'Credit' and [YYYYMM] = 201703  
  except
    select [ClientID],[LoanUID],[UniqueVendorID],Lender_loan_num
  from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
  where type = 'Credit' and [YYYYMM] <= 201702 and [YYYYMM] >= 201701   ----- March new credit check for 60 days 895272

   select [ClientID],[LoanUID],[UniqueVendorID],Lender_loan_num
  from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
  where type = 'Credit' and [YYYYMM] = 201703  
  except
    select [ClientID],[LoanUID],[UniqueVendorID],Lender_loan_num
  from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
  where type = 'Credit' and [YYYYMM] <= 201702 and [YYYYMM] >= 201612  ----- March new credit check for 90 days 882701  minus %1.4
------------------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------------
  select [ClientID],[LoanUID],[UniqueVendorID],Lender_loan_num
  from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
  where type = 'Credit' and [YYYYMM] = 201703  
  except
    select [ClientID],[LoanUID],[UniqueVendorID],Lender_loan_num
  from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
  where type = 'Credit' and [YYYYMM] <= 201702 and [YYYYMM] >= 201701   ----- March new credit check for 60 days 895272

   select [ClientID],[LoanUID],[UniqueVendorID],Lender_loan_num
  from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
  where type = 'Credit' and [YYYYMM] = 201703  
  except
    select [ClientID],[LoanUID],[UniqueVendorID],Lender_loan_num
  from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
  where type = 'Credit' and [YYYYMM] <= 201702 and [YYYYMM] >= 201612  ----- March new credit check for 90 days 882701  minus %1.4
------------------------------------------------------------------------------------------------------------------------------------------


  select [ClientID],[LoanUID],[UniqueVendorID],Lender_loan_num
  from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
  where type = 'Credit' and [YYYYMM] = 201702  
  except
    select [ClientID],[LoanUID],[UniqueVendorID],Lender_loan_num
  from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
  where type = 'Credit' and [YYYYMM] <= 201701 and [YYYYMM] >= 201612   ----- feb new credit check for 60 days 737663

   select [ClientID],[LoanUID],[UniqueVendorID],Lender_loan_num
  from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
  where type = 'Credit' and [YYYYMM] = 201702  
  except
    select [ClientID],[LoanUID],[UniqueVendorID],Lender_loan_num
  from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
  where type = 'Credit' and [YYYYMM] <= 201701 and [YYYYMM] >= 201611  ----- feb new credit check for 90 days 724690  minus 1.7%

  -----------------------------------------------------------------------------
   select [ClientID],[LoanUID],[UniqueVendorID],Lender_loan_num
  from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
  where type = 'Credit' and [YYYYMM] = 201701  
  except
    select [ClientID],[LoanUID],[UniqueVendorID],Lender_loan_num
  from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
  where type = 'Credit' and [YYYYMM] <= 201612 and [YYYYMM] >= 201611   ----- jan new credit check 712560 for 60 days 

   select [ClientID],[LoanUID],[UniqueVendorID],Lender_loan_num
  from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
  where type = 'Credit' and [YYYYMM] = 201701  
  except
    select [ClientID],[LoanUID],[UniqueVendorID],Lender_loan_num
  from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
  where type = 'Credit' and [YYYYMM] <= 201612 and [YYYYMM] >= 201610  ----- jan new credit check for 90 days   minus %
  
  
  drop table TBL_APPR_MGMT_201701
  
  select distinct  ClientID, Borrower, PropAddr, LoanUID, CategoryID, VendorID, UniqueVendorID, misc,
             Partner, Type,
			 AppValue, YYYYMM 
  from TBL_APPR_MGMT_201612_201701
  order by loanuid

  with a as (select distinct loanuid from [ArchiveData].dbo.AllTrans_For_Reports_2016_17 where YYYYMM = 201701 and type = 'APPR MGMT' and 
             submittype = 'Order' group by loanuid having count(1) > 1)
   select distinct  ClientID, Client, Company, Borrower, City, State, m.LoanUID, UniqueVendorID, Partner, 
    Bureau, SubmitType, LoanAmt,  LoanType,
               BillingCost,YYYYMM 
   into TBL_APPR_MGMT_201701
   from a inner join [ArchiveData].dbo.AllTrans_For_Reports_2016_17 m on m.LoanUID = a.LoanUID and m.YYYYMM = 201701 and m.submittype = 'Order' and m.type = 'APPR MGMT'

  ---------******************************************** table creation **********************************************************

  --------****************************  Fraud **********************************************************************************
   With a as ( select loanuid,uniquevendorid,clientid from MapdownloadlogForScrubbing where YYYYMM = 201704 and  type = 'Fraud'
               intersect
			   select loanuid,uniquevendorid,clientid from MapdownloadlogForScrubbing where YYYYMM = 201703 and  type = 'Fraud'
			 )
	Select m.* into  TBL_FRAUD_201701_201704 
	from MapdownloadlogForScrubbing m inner join a on a.loanuid = m.loanuid and m.clientid = a.clientid and m.uniquevendorid = a.uniquevendorid
	and m.type = 'Fraud' 
	where m.YYYYMM in (201704,201703)

	With a as ( select loanuid,uniquevendorid,clientid from MapdownloadlogForScrubbing where YYYYMM = 201701 and  type = 'Fraud'
               intersect
			   select loanuid,uniquevendorid,clientid from MapdownloadlogForScrubbing where YYYYMM = 201612 and  type = 'Fraud'
			 )
	insert into TBL_FRAUD_201701_201704 
	Select m.* 
	from MapdownloadlogForScrubbing m inner join a on a.loanuid = m.loanuid and m.clientid = a.clientid and m.uniquevendorid = a.uniquevendorid
	and m.type = 'Fraud' 
	where m.YYYYMM in (201701,201612)


  --------**********************************************flood--------------------------------------------------------------------------------------------------------------------------
   With a as ( select loanuid,uniquevendorid,clientid from MapdownloadlogForScrubbing where YYYYMM = 201704 and  type = 'flood'
               intersect
			   select loanuid,uniquevendorid,clientid from MapdownloadlogForScrubbing where YYYYMM = 201703 and  type = 'flood'
			 )
	Select m.* into  TBL_FLOOD_201701_201704 
	from MapdownloadlogForScrubbing m inner join a on a.loanuid = m.loanuid and m.clientid = a.clientid and m.uniquevendorid = a.uniquevendorid
	and m.type = 'flood' 
	where m.YYYYMM in (201704,201703)

	With a as ( select loanuid,uniquevendorid,clientid from MapdownloadlogForScrubbing where YYYYMM = 201701 and  type = 'flood'
               intersect
			   select loanuid,uniquevendorid,clientid from MapdownloadlogForScrubbing where YYYYMM = 201612 and  type = 'flood'
			 )
	insert into TBL_FLOOD_201701_201704 
	Select m.* 
	from MapdownloadlogForScrubbing m inner join a on a.loanuid = m.loanuid and m.clientid = a.clientid and m.uniquevendorid = a.uniquevendorid
	and m.type = 'flood' 
	where m.YYYYMM in (201701,201612)
   
   --------------------------------appr------------------------------------------------------------------------------------------------
   With a as ( select loanuid,uniquevendorid,clientid from MapdownloadlogForScrubbing where YYYYMM = 201704 and  type = 'APPR MGMT'
               intersect
			   select loanuid,uniquevendorid,clientid from MapdownloadlogForScrubbing where YYYYMM = 201703 and  type = 'APPR MGMT'
			 )
	Select m.* into  TBL_APPR_MGMT_201701_201704 
	from MapdownloadlogForScrubbing m inner join a on a.loanuid = m.loanuid and m.clientid = a.clientid and m.uniquevendorid = a.uniquevendorid
	and m.type = 'APPR MGMT' 
	where m.YYYYMM in (201704,201703)

	With a as ( select loanuid,uniquevendorid,clientid from MapdownloadlogForScrubbing where YYYYMM = 201701 and  type = 'APPR MGMT'
               intersect
			   select loanuid,uniquevendorid,clientid from MapdownloadlogForScrubbing where YYYYMM = 201612 and  type = 'APPR MGMT'
			 )
	insert into TBL_APPR_MGMT_201701_201704 
	Select m.* 
	from MapdownloadlogForScrubbing m inner join a on a.loanuid = m.loanuid and m.clientid = a.clientid and m.uniquevendorid = a.uniquevendorid
	and m.type = 'APPR MGMT' 
	where m.YYYYMM in (201701,201612)
---------******************************************** end table creation******************************************************************************
    select LAG(cast(LogDate as date),1,Null) OVER (partition by loanuid,uniquevendorid,clientid ORDER BY LogDate asc) AS PreviousDate,
	       cast(LogDate as date) as LogDate_date,
	       id, ClientID, LenderLoanNum, Borrower, PropAddr, LoanUID, CategoryID, VendorID, UniqueVendorID, TransID, 
	       Partner, Type, SubType, Engine, AccessCode, EMail, URL, misc, Division, LogDate, ProductCode, 
		   LoanAmt, IntRate, LoanType, LoanPurp, AmortType, AppValue, DeedPos, refresh_ts, 
		   TransStatus, OrgID, SvrName, seq, YYYYMM
   from TBL_APPR_MGMT_201701_201704
   where misc like '%order%' or misc like '%submit%' or misc like '%new%'

   with Excluded_orders as (
   select LAG(cast(LogDate as date),1,Null) OVER (partition by loanuid,uniquevendorid,clientid ORDER BY LogDate asc) AS PreviousDate,
	       cast(LogDate as date) as LogDate_date,
	       id, ClientID, LenderLoanNum, Borrower, PropAddr, LoanUID, CategoryID, VendorID, UniqueVendorID, TransID, 
	       Partner, Type, SubType, Engine, AccessCode, EMail, URL, misc, Division, LogDate, ProductCode, 
		   LoanAmt, IntRate, LoanType, LoanPurp, AmortType, AppValue, DeedPos, refresh_ts, 
		   TransStatus, OrgID, SvrName, seq, YYYYMM
   from TBL_APPR_MGMT_201701_201704
   where misc like '%order Submitted%' or misc like '%submit%' or misc like '%new%'
   ),
   Excluded_orders_within30days as 
   (
    select PreviousDate,
	       LogDate_date,
		   DATEDIFF(dd,PreviousDate,LogDate_date) as Date_interval,
	       id, ClientID, LenderLoanNum, Borrower, PropAddr, LoanUID, CategoryID, VendorID, UniqueVendorID, TransID, 
	       Partner, Type, SubType, Engine, AccessCode, EMail, URL, misc, Division, LogDate, ProductCode, 
		   LoanAmt, IntRate, LoanType, LoanPurp, AmortType, AppValue, DeedPos, refresh_ts, 
		   TransStatus, OrgID, SvrName, seq, YYYYMM
		   from Excluded_orders
		   where PreviousDate is not null and PreviousDate !=LogDate_date
    )

   select * from Excluded_orders_within30days where Date_interval <=30

   ------------*********************************** Flood query************************************************
   with Excluded_orders as (
   select LAG(cast(LogDate as date),1,Null) OVER (partition by loanuid,uniquevendorid,clientid ORDER BY LogDate asc) AS PreviousDate,
	       cast(LogDate as date) as LogDate_date,
	       id, ClientID, LenderLoanNum, Borrower, PropAddr, LoanUID, CategoryID, VendorID, UniqueVendorID, TransID, 
	       Partner, Type, SubType, Engine, AccessCode, EMail, URL, misc, Division, LogDate, ProductCode, 
		   LoanAmt, IntRate, LoanType, LoanPurp, AmortType, AppValue, DeedPos, refresh_ts, 
		   TransStatus, OrgID, SvrName, seq, YYYYMM
   from TBL_FLOOD_201701_201704
   where misc like '%order Submitted%' or misc like '%submit%' or misc like '%new%'
   ),
   Excluded_orders_within30days as 
   (
    select PreviousDate,
	       LogDate_date,
		   DATEDIFF(dd,PreviousDate,LogDate_date) as Date_interval,
	       id, ClientID, LenderLoanNum, Borrower, PropAddr, LoanUID, CategoryID, VendorID, UniqueVendorID, TransID, 
	       Partner, Type, SubType, Engine, AccessCode, EMail, URL, misc, Division, LogDate, ProductCode, 
		   LoanAmt, IntRate, LoanType, LoanPurp, AmortType, AppValue, DeedPos, refresh_ts, 
		   TransStatus, OrgID, SvrName, seq, YYYYMM
		   from Excluded_orders
		   where PreviousDate is not null and PreviousDate !=LogDate_date
    )

   select * from Excluded_orders_within30days where Date_interval <=30

   SELECT * FROM  TBL_FLOOD_201701_201704 WHERE loanuid =  '{0fb57677-c9f4-4193-aa18-174cdf881b6a}' ORDER BY LOGDATE ASC

    SELECT * FROM  TBL_FLOOD_201701_201704 WHERE loanuid =  '{01e002bf-1a0f-4053-adc2-2a41b8fb0514}' ORDER BY LOGDATE ASC

	SELECT * FROM  TBL_FLOOD_201701_201704 WHERE loanuid = '{063a5092-c8b7-41db-b1e8-ec9fabfe70fc}' ORDER BY LOGDATE ASC
   ------------------------------------------------------------------------------------------------------------------------
---------------------****************** FRAUD QUERY*************************************************************************************************
 with Excluded_orders as (
   select LAG(cast(LogDate as date),1,Null) OVER (partition by loanuid,uniquevendorid,clientid ORDER BY LogDate asc) AS PreviousDate,
	       cast(LogDate as date) as LogDate_date,
	       id, ClientID, LenderLoanNum, Borrower, PropAddr, LoanUID, CategoryID, VendorID, UniqueVendorID, TransID, 
	       Partner, Type, SubType, Engine, AccessCode, EMail, URL, misc, Division, LogDate, ProductCode, 
		   LoanAmt, IntRate, LoanType, LoanPurp, AmortType, AppValue, DeedPos, refresh_ts, 
		   TransStatus, OrgID, SvrName, seq, YYYYMM
   from TBL_FRAUD_201701_201704
   where misc like '%order Submitted%' or misc like '%submit%' or misc like '%new%'
   ),
   Excluded_orders_within30days as 
   (
    select PreviousDate,
	       LogDate_date,
		   DATEDIFF(dd,PreviousDate,LogDate_date) as Date_interval,
	       id, ClientID, LenderLoanNum, Borrower, PropAddr, LoanUID, CategoryID, VendorID, UniqueVendorID, TransID, 
	       Partner, Type, SubType, Engine, AccessCode, EMail, URL, misc, Division, LogDate, ProductCode, 
		   LoanAmt, IntRate, LoanType, LoanPurp, AmortType, AppValue, DeedPos, refresh_ts, 
		   TransStatus, OrgID, SvrName, seq, YYYYMM
		   from Excluded_orders
		   where PreviousDate is not null and PreviousDate !=LogDate_date
    )

   select * from Excluded_orders_within30days where Date_interval <=30

   SELECT * FROM  TBL_FRAUD_201701_201704 WHERE loanuid =  '{000fcd8c-b286-4e31-9e5c-bbec22bcfdb3}' ORDER BY LOGDATE ASC

   SELECT * FROM  TBL_FRAUD_201701_201704 WHERE loanuid =  '{00d29a55-5bf7-49a1-8ebe-2bd957050736}' ORDER BY LOGDATE ASC

   SELECT * FROM  TBL_FRAUD_201701_201704 WHERE loanuid =  '{0101db59-14aa-4f9f-ab04-67ade68860ba}' ORDER BY LOGDATE ASC


   select top 100 * from MapdownloadlogForScrubbing where type = 'fraud' and YYYYMM = 201704





   ---**************************************************************************************************************************************
   
   select m.* from TBL_APPR_MGMT_201701_201704 m 
   inner join Excluded_orders_within30days e on e.LoanUID = m.LoanUID and e.Date_interval <=30
   order by m.LoanUID, m.LogDate asc

   select * from TBL_APPR_MGMT_201701_201704 where loanuid = '{00442d1f-8fbe-49f0-8b60-5af52b73f4ca}'
   order by logdate asc
   
    select * from TBL_APPR_MGMT_201701_201704 where loanuid = '{02947208-d973-4c67-9d83-74d9375c6db7}'  ----- '{d6cb6f54-59f2-40b1-bb67-96605a2fed09}'
	order by logdate asc

	select * from TBL_APPR_MGMT_201701_201704 where loanuid =  '{d6cb6f54-59f2-40b1-bb67-96605a2fed09}'
	order by logdate asc


   select * from Excluded_orders_within30days where Date_interval <=30 ---27021 total 


	select * from TBL_APPR_MGMT_201701_201704 order by loanuid, logdate asc
   --- drop table TBL_APPR_MGMT_201701
  select * from TBL_APPR_MGMT_201701 order by loanuid

  select * from  [ArchiveData].dbo.AllTrans_For_Reports_2016_17
 where  type = 'APPR MGMT'and loanuid = '{0018be21-43b8-4093-8bf6-b95f99b6bcca}' and YYYYMM = 201703

  select * from TBL_APPR_MGMT_201612_201701
  where misc like '%PlaceOrder%' 
  order by loanuid, LogDate asc

  select * from TBL_APPR_MGMT_201612_201701 where LoanUID = '{0d86f93f-a9ae-4a20-9dc8-d89a8bbaaf88}' order by logdate asc

  select * from TBL_APPR_MGMT_201612_201701 where LoanUID = '{0085d4ef-a561-4d81-a1e1-1a1de49c38c5}' order by logdate asc



 with a as ( select loanuid,uniquevendorid,clientid  
 from  Temp_AllVendorData_Bruce_appraisal 
 where submittype = 'Order' and type = 'APPR MGMT'
 intersect
 select loanuid,uniquevendorid,clientid  
 from  Temp_AllVendorData_Bruce_appraisal_201612
 where submittype = 'Order' and type = 'APPR MGMT'),

 b as (select a.ClientID, Client, Company, Borrower, City, State, a.LoanUID, a.UniqueVendorID, Partner, 
    Bureau, SubmitType, LoanAmt,  LoanType,[LogDate]
               
 from Temp_AllVendorData_Bruce_appraisal m inner join a on a.ClientID = m.ClientID and a.UniqueVendorID = m.UniqueVendorID and a.LoanUID = m.LoanUID
 union 
 select a.ClientID, Client, Company, Borrower, City, State, a.LoanUID, a.UniqueVendorID, Partner, 
    Bureau, SubmitType, LoanAmt,  LoanType,
               [LogDate]
 from Temp_AllVendorData_Bruce_appraisal_201612 m inner join a on a.ClientID = m.ClientID and a.UniqueVendorID = m.UniqueVendorID and a.LoanUID = m.LoanUID
 )

 select * into TBL_APPRMGMT_201701_ORDER from b 

 select * from TBL_APPRMGMT_201701_ORDER

 drop table TBL_APPRMGMT_201701_ORDER
  ---------
  
  select [ClientID],[LoanUID],[UniqueVendorID],Lender_loan_num, count(transid) as total
  from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
  where type = 'APPR MGMT' and [YYYYMM] > = 201702  and [YYYYMM] < 201704 and submittype = 'Order'
  group by [ClientID],[LoanUID],[UniqueVendorID],Lender_loan_num
  having count(1) > 1 

  select [ClientID],[LoanUID],[UniqueVendorID],Lender_loan_num, count(transid) as total
  from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
  where type = 'APPR MGMT' and [YYYYMM] > = 201701  and [YYYYMM] < 201703 and submittype = 'Order'
  group by [ClientID],[LoanUID],[UniqueVendorID],Lender_loan_num
  having count(1) > 1

  select [ClientID],[LoanUID],[UniqueVendorID],Lender_loan_num, count(transid) as total
  from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
  where type = 'APPR MGMT' and [YYYYMM] > = 201612  and [YYYYMM] < 201702 and submittype = 'Order'
  group by [ClientID],[LoanUID],[UniqueVendorID],Lender_loan_num
  having count(1) > 1

  select * from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
  where type = 'APPR MGMT' and [ClientID] = 032257 and LoanUID = '{2b9adef4-74f9-4f80-a8fc-dc88a1a177d4}' and UniqueVendorID = 300041


 select [ClientID],[LoanUID],[UniqueVendorID], count(transid) as total
  from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
  where type = 'APPR MGMT' and [YYYYMM]  = 201703 and submittype = 'Order'
  group by [ClientID],[LoanUID],[UniqueVendorID]
  having count(1) > 1

  --- select top 1000 * from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
 where type = 'Title' and [YYYYMM]  = 201704

 select distinct submittype from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
 where type = 'Title' and [YYYYMM]  = 201704

 with A as (select  Clientid,UniqueVendorID,loanuid 
 from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
 where type = 'Title' and [YYYYMM]  = 201704
 except
 select  Clientid,UniqueVendorID,loanuid 
 from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
 where type = 'Title' and  [YYYYMM] >=201612 and  [YYYYMM] < 201704
 )
 select Clientid,UniqueVendorID,count(distinct loanuid ) as totalLoans from 
 A group by Clientid,UniqueVendorID

 with A as (select  Clientid,UniqueVendorID,loanuid 
 from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
 where type = 'Title' and [YYYYMM]  = 201703
 except
 select  Clientid,UniqueVendorID,loanuid 
 from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
 where type = 'Title' and  [YYYYMM] >=201611 and  [YYYYMM] < 201703
 )
 select Clientid,UniqueVendorID,count(distinct loanuid ) as totalLoans from 
 A group by Clientid,UniqueVendorID

 with A as (select  Clientid,UniqueVendorID,loanuid 
 from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
 where type = 'Title' and [YYYYMM]  = 201702
 except
 select  Clientid,UniqueVendorID,loanuid 
 from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
 where type = 'Title' and  [YYYYMM] >=201610 and  [YYYYMM] < 201702
 )
 select Clientid,UniqueVendorID,count(distinct loanuid ) as totalLoans from 
 A group by Clientid,UniqueVendorID

 with A as (select  Clientid,UniqueVendorID,loanuid 
 from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
 where type = 'Title' and [YYYYMM]  = 201701
 except
 select  Clientid,UniqueVendorID,loanuid 
 from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
 where type = 'Title' and  [YYYYMM] >=201609 and  [YYYYMM] < 201701
 )
 select Clientid,UniqueVendorID,count(distinct loanuid ) as totalLoans from 
 A group by Clientid,UniqueVendorID

 ---=========================================================================
 with A as (select  Clientid,UniqueVendorID,loanuid 
 from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
 where type = 'Title' and [YYYYMM]  = 201704
 except
 select  Clientid,UniqueVendorID,loanuid 
 from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
 where type = 'Title' and  [YYYYMM]= 201703
 )
 select Clientid,UniqueVendorID,count(distinct loanuid ) as totalLoans from 
 A group by Clientid,UniqueVendorID

 with A as (select  Clientid,UniqueVendorID,loanuid 
 from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
 where type = 'Title' and [YYYYMM]  = 201703
 except
 select  Clientid,UniqueVendorID,loanuid 
 from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
 where type = 'Title' and  [YYYYMM]= 201702
 )
 select Clientid,UniqueVendorID,count(distinct loanuid ) as totalLoans from 
 A group by Clientid,UniqueVendorID

 with A as (select  Clientid,UniqueVendorID,loanuid 
 from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
 where type = 'Title' and [YYYYMM]  = 201702
 except
 select  Clientid,UniqueVendorID,loanuid 
 from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
 where type = 'Title' and  [YYYYMM]= 201701
 )
 select Clientid,UniqueVendorID,count(distinct loanuid ) as totalLoans from 
 A group by Clientid,UniqueVendorID

 with A as (select  Clientid,UniqueVendorID,loanuid 
 from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
 where type = 'Title' and [YYYYMM]  = 201701
 except
 select  Clientid,UniqueVendorID,loanuid 
 from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
 where type = 'Title' and  [YYYYMM]= 201612
 )
 select Clientid,UniqueVendorID,count(distinct loanuid ) as totalLoans from 
 A group by Clientid,UniqueVendorID


 ---*****************************************************************************************************************

 ---****************************************************************************************************************






 With a as ( 
 select  Clientid,UniqueVendorID,loanuid 
 from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
 where type = 'APPR MGMT' and  convert(varchar(7), LogDate, 126) = '2017-04'
 except
 select  Clientid,UniqueVendorID,loanuid 
 from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
 where type = 'APPR MGMT' and  convert(varchar(7), LogDate, 126) = '2017-03'
 union
 select  Clientid,UniqueVendorID,loanuid 
 from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
 where type = 'APPR MGMT' and  convert(varchar(7), LogDate, 126) = '2017-02'
 union
 select  Clientid,UniqueVendorID,loanuid 
 from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
 where type = 'APPR MGMT' and  convert(varchar(7),LogDate, 126) = '2017-01'
 union
 select  Clientid,UniqueVendorID,loanuid 
 from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
 where type = 'APPR MGMT' and  convert(varchar(7), LogDate, 126) = '2016-12'
 )

 select Clientid,UniqueVendorID,count(distinct loanuid ) from 
 A group by Clientid,UniqueVendorID




 select top 1  convert(varchar(7), getdate(), 126)  from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]

 select top 1 LogDate from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
  
  select top 2 * from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
  where VendorID = '400127' and clientid = '11131730'
  
  select * from mapdownloadlog where url = 'PAPI:EM.ValuTrac.Appraisal' ----and misc like '%116213%'
  order by date desc
  ----and clientid = '11148630'
  
  select top 1000 * from [DataProcessing].dbo. MapdownloadlogForScrubbing where type = 'flood'
  and vendorid = '500034'   ---Sub Type

  select top 1000 * from [DataProcessing].dbo. MapdownloadlogForScrubbing where type = 'flood'
  and vendorid <> '500034'
  
  select distinct top 10 loanpurp from  [DataProcessing].dbo. MapdownloadlogForScrubbing where type = 'flood' and vendorid <> '500034'

  select top 100 * from  [DataProcessing].dbo. MapdownloadlogForScrubbing where type = 'flood' and vendorid = '500017'

  select distinct type, count(distinct vendorid) as Partner_per_Type
  from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
  group by type



  select distinct UniqueVendorID, count(distinct partner) as Partners_perVendorid ---into TBL_VendorID_PartnerCount
  from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
  group by UniqueVendorID

  select distinct a.UniqueVendorID, a.partner from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17] a 
  inner join TBL_VendorID_PartnerCount b on b.VendorID = a.VendorID and b.Partners_perVendorid > 1
  order by a.vendorid

  select distinct type, count(distinct UniqueVendorID) as Partner_per_Type
  from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
  group by type


  select distinct partner,vendorid 
  into TBL_Partner_VendorID
  from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
  where type = 'title'
  order by partner asc

  drop table TBL_Partner_VendorID_LoanUID_Title

  select distinct vendorid,clientid,LoanUID 
  into TBL_VendorID_Clientid_LoanUID_Title
  from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
  where type = 'title' and year(logdate) = 2017
  
  select vendorid,clientid,count(LoanUID) as totalPerPartnerClient
  into TBL_Vendor_client_Title_Count
  from TBL_VendorID_Clientid_LoanUID_Title 
  group by vendorid,clientid
  
  select distinct P.partner,C.* from TBL_Vendor_client_Title_Count C 
  inner join TBL_Partner_VendorID P on P.vendorid = C.VendorID
  order by totalPerPartnerClient desc
  
  --- now Appraisal
  select distinct vendorid,clientid,LoanUID 
  into TBL_VendorID_Clientid_LoanUID_APPR_MGMT
  from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
  where type = 'APPR MGMT' and year(logdate) = 2017

  select vendorid,clientid,count(LoanUID) as totalPerPartnerClient
  into TBL_Vendor_client_APPR_MGMT_Count
  from TBL_VendorID_Clientid_LoanUID_APPR_MGMT 
  group by vendorid,clientid

  select distinct P.partner,C.* from TBL_Vendor_client_APPR_MGMT_Count C 
  inner join TBL_Partner_VendorID_APPR P on P.vendorid = C.VendorID
  order by totalPerPartnerClient desc
  
  Select top 10 * into TBL_TOP_10_APPR_MGMT_2017
  from TBL_Vendor_client_APPR_MGMT_Count
  order by totalPerPartnerClient desc

  
  
  
  
  select top 1 * from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]

  select distinct partner,vendorid 
  into TBL_Partner_VendorID_APPR   ---65
  from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
  where type like 'APP%' or type = 'AVM'
  order by partner asc

  select * from TBL_Partner_VendorID_APPR

  select distinct partner,vendorid 
  into TBL_Partner_VendorID_Credit
  from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
  where type = 'credit'
  order by partner asc

  select * from TBL_Partner_VendorID_Credit

  select vendorid,partner,count(clientid) as total_clientid_trans
  into TBL_Vendor_Credit_CountTrans
  from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
  where type = 'credit'
  group by vendorid,partner

  select * from TBL_Vendor_Credit_CountTrans order by total_clientid_trans desc

  select * from lu_CVENDOR

  select * from lu_SYNCODES



  select * from TBL_Partner_VendorID_APPR where vendorid in (300059,300071,300084 ) 

  select partner from TBL_Partner_VendorID_APPR
  except
  select partner from [dbo].[TBL_APPR_Connie]


  select T.partner,T.vendorid,lu.clientid,lu.type 
  from  TBL_Partner_VendorID_APPR t 
  left outer join lu_Vendor_Pricing lu on lu.Vendorid = t.VendorID 
  and lu.Type like 'APP%' or type = 'AVM'
  order by T.partner asc 

  select * from lu_Vendor_Pricing where type = 'elec verf'






  select * from lu_MapFiles
  

  select * from TBL_Partner_VendorID_APPR order by partner asc

  select T.partner,T.vendorid,lu.clientid 
  from  TBL_Partner_VendorID t 
  left outer join lu_Vendor_Pricing lu on lu.Vendorid = t.VendorID 
  and lu.Type like 'Title%' 
  order by T.partner asc 


  select * from lu_Vendor_Pricing where type = 'flood'

  select * from lu_Vendor_Pricing where type = 'fraud'
  order by vendor asc

  select * from Temp_AllVendorData_Title


  select distinct loanprog from Temp_No_Test_Title


  select distinct submittype from Temp_No_Test_Title

  select distinct url, partner
  from Temp_No_Test_Title
  where type = 'Title'
  order by url, partner

  select * from Temp_Unique_Rec_Title

   select * from [DOCService].[dbo].[EMDocsTransactions]
  
   select * from TPOWebCenterTransactions

----MapdownloadlogForScrubbing 
select * 
from MapdownloadlogForScrubbing
   where [YYYYMM] >= 201701 and type = 'Credit'

drop table TBL_APPR_MGMT_ClientID
drop table TBL_Range_APPR_TOP
   
   select Clientid , uniquevendorid, count(distinct loanuid) as TotalCount
   into TBL_Range_APPR_TOP
   from MapdownloadlogForScrubbing
   where [YYYYMM] >= 201701  and  [YYYYMM] < 201705 
   and Type = 'APPR MGMT'
   group by Clientid , uniquevendorid

   select * from MapdownloadlogForScrubbing where uniquevendorid = '300041' and [YYYYMM] >= 201701
   
   select top 10 * from TBL_Range_APPR_TOP order by TotalCount desc
   drop table TBL_Range_APPR_TOP_20
   select top 10 * 
   into TBL_Range_APPR_TOP_10
   from TBL_Range_APPR_TOP order by TotalCount desc

   select distinct top 10  M.Partner,T.* from MapdownloadlogForScrubbing M inner join TBL_Range_APPR_TOP_10 T
   on T.UniqueVendorID = M.UniqueVendorID
   order by TotalCount desc

   select  distinct  Partner, UniqueVendorID   from MapdownloadlogForScrubbing 
   where UniqueVendorID in (select UniqueVendorID from TBL_Range_APPR_TOP_10)
   order by TotalCount desc
   
    drop table TBL_APPR_MGMT_ClientID
	
	select distinct top 10 M.Clientid , M.uniquevendorid, M.loanuid -----,min(logdate)
	into TBL_APPR_MGMT_ClientID
	from MapdownloadlogForScrubbing M (nolock)
	inner join TBL_Range_APPR_TOP_10 T
	on T.uniquevendorid = M.uniquevendorid and T.ClientID = M.ClientID
	where M.[YYYYMM] >= 201609  and  M.[YYYYMM] < 201705 and M.Type = 'APPR MGMT'
	
	----group by Clientid , uniquevendorid, loanuid 

	select * from TBL_TOP_10_APPR_MGMT_2017

	-----select * from MapdownloadlogForScrubbing where vendorid = '300056' and clientid = '11147594'


	/*
3011147594
3011143850
3000227812
3000234894
3011146729
3011129667
3011167611
3011143685
3011137883
3000910717

	*/
	select min(logdate) from MapdownloadlogForScrubbing (nolock)

	select max(logdate) from MapdownloadlogForScrubbing (nolock)

	select DATEPART(m, DATEADD(m, -1, getdate()))

	---- first calculate number of transactions for 10 clients on minthly base for Jan-Feb-March-Apr (30 days approach)

	declare @lastmonth int = (select DATEPART(m, DATEADD(m, -1, getdate())))
	declare @2monthsago int = (select DATEPART(m, DATEADD(m, -2, getdate())))
	declare @3monthsago int = (select DATEPART(m, DATEADD(m, -3, getdate())))

	print @lastmonth
	print @2monthsago
	print @3monthsago

	select M.Clientid , M.uniquevendorid, count(M.loanuid) as total_monthly_loans
	from TBL_Range_APPR_TOP_10 T10 inner join MapdownloadlogForScrubbing M on M.ClientID = T10.ClientID
	and T10.uniquevendorid = M.UniqueVendorID
	where month(M.logdate) = @lastmonth and Year(M.logdate) = 2017 
	and type = 'APPR MGMT'
	and M.loanuid not in (select loanuid from MapdownloadlogForScrubbing  where month(logdate) = @2monthsago and Year(logdate) = 2017 )
	group by  M.Clientid , M.uniquevendorid

	drop table TBL_MDL_3Month

	---TBL_Vendor_client_APPR_MGMT_Count
	
	select  M.Clientid, M.uniquevendorid, M.loanuid,M.logdate, [YYYYMM]
	into TBL_MDL_3Month
	from TBL_Range_APPR_TOP_10 T10 inner join MapdownloadlogForScrubbing M on M.ClientID = T10.ClientID
	and T10.uniquevendorid = M.UniqueVendorID
	where [YYYYMM] >= 201609 and  [YYYYMM] < 201705
	and type = 'APPR MGMT'

	;with a as (
	select Clientid , uniquevendorid, loanuid 
	from TBL_MDL_3Month
	where [YYYYMM] = 201701 
	except 
	select Clientid , uniquevendorid, loanuid 
	from TBL_MDL_3Month
	where [YYYYMM] = 201612
	 )
	
	select Clientid , uniquevendorid, count(loanuid) as total_monthly_loans 
	from a 
	group by Clientid , uniquevendorid
	
	insert into TBL_MDL_3Month (Clientid,uniquevendorid,loanuid,logdate, [YYYYMM])
	select M.Clientid, M.uniquevendorid, M.loanuid,M.logdate, [YYYYMM]
	from TBL_APPR_MGMT_ClientID T10 inner join MapdownloadlogForScrubbing M on M.ClientID = T10.ClientID
	and T10.uniquevendorid = M.UniqueVendorID
	where [YYYYMM] >= 201609 and [YYYYMM] < 201701 
	and type = 'APPR MGMT'
	
	;with a as (
	select distinct Clientid , uniquevendorid, loanuid 
	from TBL_MDL_3Month
	where [YYYYMM] >= 201701 and [YYYYMM] < 201705
	except 
	select Clientid , uniquevendorid, loanuid 
	from TBL_MDL_3Month
	where [YYYYMM] = 201612 
	 )
	
	
	select Clientid , uniquevendorid, count(loanuid) as total_4months_loans 
	from a 
	group by Clientid , uniquevendorid

	
	;with a as (
	select distinct Clientid , uniquevendorid, loanuid 
	from TBL_MDL_3Month
	where [YYYYMM] >= 201701 and [YYYYMM] < 201705
	except 
	select Clientid , uniquevendorid, loanuid 
	from TBL_MDL_3Month
	where [YYYYMM] >= 201609 and [YYYYMM] < 201701 
	 )
	
	select Clientid , uniquevendorid, count(distinct loanuid) as total_4months_loans 
	from a 
	group by Clientid , uniquevendorid
	
	select Clientid , uniquevendorid, loanuid, count(loanuid) as number_repeated 
	from TBL_MDL_3Month
	where [YYYYMM] >= 201701 and [YYYYMM] < 201705
	group by Clientid , uniquevendorid, loanuid
	having count(1) > 1

	with b as (
	select distinct Clientid , uniquevendorid, loanuid
	from TBL_MDL_3Month
	where [YYYYMM] = 201704 
	intersect
	select distinct Clientid , uniquevendorid, loanuid
	from TBL_MDL_3Month
	where [YYYYMM] = 201702 
	except
	select distinct Clientid , uniquevendorid, loanuid
	from TBL_MDL_3Month
	where [YYYYMM] = 201703  --51 loan in April exists in Feb  
	)
	
	;with b as (
	select distinct Clientid , uniquevendorid, loanuid
	from TBL_MDL_3Month
	where [YYYYMM] = 201703 
	intersect
	select distinct Clientid , uniquevendorid, loanuid
	from TBL_MDL_3Month
	where [YYYYMM] = 201701 ---267 loans in April exists in Feb
	except
	select distinct Clientid , uniquevendorid, loanuid
	from TBL_MDL_3Month
	where [YYYYMM] = 201702  --101 loan in March exists in Jan  
	)
	
	;with b as (
	select distinct Clientid , uniquevendorid, loanuid
	from TBL_MDL_3Month
	where [YYYYMM] = 201702 
	intersect
	select distinct Clientid , uniquevendorid, loanuid
	from TBL_MDL_3Month
	where [YYYYMM] = 201612 ---
	except
	select distinct Clientid , uniquevendorid, loanuid
	from TBL_MDL_3Month
	where [YYYYMM] = 201701  --86 loans in Feb exists in Dec  
	)
	
	;with b as (
	select distinct Clientid , uniquevendorid, loanuid
	from TBL_MDL_3Month
	where [YYYYMM] = 201701 
	intersect
	select distinct Clientid , uniquevendorid, loanuid
	from TBL_MDL_3Month
	where [YYYYMM] = 201611 
	except
	select distinct Clientid , uniquevendorid, loanuid
	from TBL_MDL_3Month
	where [YYYYMM] = 201612  --152 loans in Jan exists in Nov  
	)
	
	select 
	
	  
    select count(distinct loanuid) from b

	intersect
	select distinct Clientid , uniquevendorid, loanuid
	from TBL_MDL_3Month
	where [YYYYMM] = 201703 
	intersect
	select distinct Clientid , uniquevendorid, loanuid
	from TBL_MDL_3Month
	where [YYYYMM] = 201701  --415 loans in March exists in Jan
	intersect
	select distinct Clientid , uniquevendorid, loanuid
	from TBL_MDL_3Month
	where [YYYYMM] = 201702 
	intersect
	select distinct Clientid , uniquevendorid, loanuid
	from TBL_MDL_3Month
	where [YYYYMM] = 201612 ---374 loans in Feb exists in December 2016
	intersect
	select distinct Clientid , uniquevendorid, loanuid
	from TBL_MDL_3Month
	where [YYYYMM] = 201701 
	intersect
	select distinct Clientid , uniquevendorid, loanuid
	from TBL_MDL_3Month
	where [YYYYMM] = 201611  ---575 loans in Jan exists in November 2016
    )

	select  Clientid , uniquevendorid, loanuid,count(loanuid)
	from b 
	group by Clientid , uniquevendorid,LoanUID
	having count(1) > 1

	select distinct Clientid , uniquevendorid, loanuid
	from TBL_MDL_3Month
	where [YYYYMM] = 201704 
	intersect
	select distinct Clientid , uniquevendorid, loanuid
	from TBL_MDL_3Month
	where [YYYYMM] = 201702 
	union
	select distinct Clientid , uniquevendorid, loanuid
	from TBL_MDL_3Month
	where [YYYYMM] = 201701
	union
	select distinct Clientid , uniquevendorid, loanuid
	from TBL_MDL_3Month
	where [YYYYMM] = 201612  

	select distinct Clientid , uniquevendorid,loanuid, count(loanuid)
	from TBL_MDL_3Month
	where [YYYYMM] >= 201612 and [YYYYMM] < 201705
	group by Clientid , uniquevendorid, loanuid
	having count(1) > 1


	select M.Clientid , M.uniquevendorid, count(M.loanuid) as total_monthly_loans,month(logdate) as Log_month 
	from TBL_APPR_MGMT_ClientID T10 inner join MapdownloadlogForScrubbing M on M.ClientID = T10.ClientID
	and T.uniquevendorid = M.UniqueVendorID
	where logdate >= '1/1/2017' and logdate < '5/1/2017' and type = 'APPR MGMT'
	group by  M.Clientid , M.uniquevendorid

	--- second, calculate number of transactions for 10 clients on quater base for Jan-Feb-March-Apr (120 days approach)

	select * from MapdownloadlogForScrubbing where type like 'APPR%' and YYYYMM = 201704 ---345020

	select partner,UniqueVendorID,count(loanuid) as totalTrans
	 from [DataProcessing].dbo.MapdownloadlogForScrubbing 
	where type like 'APPR%' and YYYYMM = 201704
	group by partner,UniqueVendorID

	 SELECT top 1 convert(varchar(7), logdate, 126) 
	 from MapdownloadlogForScrubbing where type like 'APPR%'