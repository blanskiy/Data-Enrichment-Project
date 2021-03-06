USE [DataProcessing_Test]
GO
/****** Object:  StoredProcedure [dbo].[ScrubVendorTransData_Title_MOD]    Script Date: 7/28/2017 11:29:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[ScrubVendorTransData_Title_MOD] 
AS
	
	BEGIN
		/* ================================================================================================================
			 Author:		Bruce Lanskiy
			 Create date: 06/23/2017
			 Modified:    
			
			 Description:	Original stored procedure, business logic, had been written by Connie Zhao.
			                Code below is an attempt to simplify and adapt to new standard.
			                The purpose of this stored procedure is to load Title data, scrub 90 days window for unique vendorid/clientid/loanUID 
							
		                
		 
		   ================================================================================================================*/
		SET NOCOUNT ON;

		BEGIN TRY
	
		
		DECLARE @PRODNUMBER TINYINT = 2
		DECLARE @YYYYMM bigint = (select CAST(convert(char(6), getdate(), 112) AS BIGINT))  
		----Declare @YYYYMM bigint = (select max([YYYYMM]) from [DataProcessing].[dbo].MapdownloadlogForScrubbing) ---    -1
		DECLARE @ORDER VARCHAR(10) = 'Order'
		DECLARE @SCRUB_WINDOW TINYINT = (SELECT TOP 1 SCRUBBING_WINDOW FROM TBL_Product_types WHERE Product_number = @PRODNUMBER)
		DECLARE @TEST_BORROWER VARCHAR(10)  = (select top 1 Borrower FROM TBL_Scrub_Exclusion_Records WHERE Product_number = @PRODNUMBER AND Uniquevendorid IS NULL)
		DECLARE @bDate datetime
        DECLARE @eDate datetime

		if  Day(getdate()) = 1
			select @bDate = CONVERT(datetime, CONVERT(char(10), DATEADD(month, -1, getdate()),101) + ' 00:00')
		else
			select @bDate =  CONVERT(datetime, CONVERT(char(10), DATEADD(DD, 1 -DATEPART(DD,getdate()), getdate()),101) + ' 00:00')
		select @eDate = CONVERT(datetime, CONVERT(char(10), getdate(), 101) + ' 00:00')

        --- GET CURRENT MONTH TITLE
		IF OBJECT_ID('TBL_TITLE_CURRENT_MONTH', 'U') IS NOT NULL DROP TABLE TBL_TITLE_CURRENT_MONTH
	   
		SELECT m.id,ClientID,LenderLoanNum,Borrower,PropAddr,LoanUID,CategoryID,VendorID,m.UniqueVendorID,TransID,
				Partner,Type,AccessCode,EMail,URL,misc,Division,Platform,LogDate,ClientID as ClientID_Log,
				Version,LoanAmt,IntRate,LoanType,LoanPurp,AmortType,AppValue,DeedPos,SvrName,YYYYMM    -----ClientID, LoanUID, UniqueVendorID, m.ID, LogDate
		INTO   TBL_TITLE_CURRENT_MONTH
		FROM   [DataProcessing].[dbo].MapdownloadlogForScrubbing m (NOLOCK)
				INNER JOIN TBL_Product_types PROD ON PROD.Prod_Name = m.type and PROD.Product_number = @PRODNUMBER
				and m.YYYYMM = @YYYYMM 
	   
		ALTER TABLE TBL_TITLE_CURRENT_MONTH
		ADD  SubmitType VARCHAR(30),LoanProd VARCHAR(150),LoanProg VARCHAR(150), Client VARCHAR(120),AcctExec varchar (101),City VARCHAR(50),State VARCHAR(2)
	   
	    --- 2. Delete EXCLUSIONS:

		DECLARE @MIN_CLIENTID VARCHAR(15) = (SELECT MIN(CLIENTID) FROM TBL_Scrub_Exclusion_Records WHERE Product_number = @PRODNUMBER )
		DECLARE @MAX_CLIENTID VARCHAR(15) = (SELECT MAX(CLIENTID) FROM TBL_Scrub_Exclusion_Records WHERE Product_number = @PRODNUMBER )
	       
		DELETE APP
		FROM TBL_TITLE_CURRENT_MONTH APP
		     INNER JOIN TBL_lu_test_integrated_Exclusions EXCL
			 ON EXCL.ClientID = APP.ClientID
        
		DELETE APP
		FROM TBL_TITLE_CURRENT_MONTH APP
		     INNER JOIN TBL_lu_test_integrated_Exclusions EXCL
			 ON EXCL.Company = APP.ClientID

        DELETE APP
		FROM TBL_TITLE_CURRENT_MONTH APP
		     INNER JOIN TBL_lu_test_integrated_Exclusions EXCL
			 ON EXCL.Access_Code = APP.AccessCode

        DELETE APP
		FROM TBL_TITLE_CURRENT_MONTH APP
		     INNER JOIN TBL_lu_test_integrated_Exclusions EXCL
			 ON EXCL.Borname = APP.Borrower

        DELETE APP
		FROM TBL_TITLE_CURRENT_MONTH APP
		WHERE ISNULL(APP.clientid,'')  BETWEEN @MIN_CLIENTID AND @MAX_CLIENTID AND LEN(ISNULL(APP.ClientID,'')) = 8
		
		DELETE APP
		FROM TBL_TITLE_CURRENT_MONTH APP
		WHERE APP.Borrower IS NULL

		DELETE APP
		FROM TBL_TITLE_CURRENT_MONTH APP
		WHERE APP.Borrower =''
	        
		DELETE APP
		FROM TBL_TITLE_CURRENT_MONTH APP
		WHERE APP.Borrower LIKE @TEST_BORROWER
		
		----- DELETE RECORDS WITH TEST EMAILS
		DECLARE @maxrecord BIGINT  = (select top 1 ID FROM TBL_Scrub_Exclusion_Records ORDER BY ID DESC)
		WHILE @maxrecord > 0
				BEGIN
					DECLARE @EMAIL VARCHAR(25) = (SELECT Email FROM TBL_Scrub_Exclusion_Records WHERE ID = @maxrecord)
					DELETE TBL_TITLE_CURRENT_MONTH WHERE EMAIL LIKE @EMAIL
					SET @maxrecord = @maxrecord - 1
	
				END
	
		---- DELETE RECORDS CORRELATED TO EXCEPTION TABLES
		DELETE T
		FROM TBL_TITLE_CURRENT_MONTH T 
		INNER JOIN DBO.TBL_lu_test_integrated_Exclusions LU
		ON LU.CLIENTID = T.CLIENTID 
			
		DELETE T
		FROM TBL_TITLE_CURRENT_MONTH T
		INNER JOIN [DataProcessing].DBO.lu_mapfiles LU
		ON LU.uniquevendorid = T.uniquevendorid
		AND LU.ClientID = T.ClientID
		AND LU.ClientID IS NOT NULL

		DELETE APP
		FROM TBL_TITLE_CURRENT_MONTH APP INNER JOIN [DataProcessing].[dbo].OEM_VendorTransData VEND
		ON  APP.VendorID = VEND.VendorID
		WHERE _sent_ts >= @bDate AND  _sent_ts <  @eDate
		
		
		---- 3. FIND RECORDS STATUS BLOCK

		UPDATE T 
		SET T.SubmitType = SCRUB.TO_ENTER_VALUE
		FROM TBL_TITLE_CURRENT_MONTH T
		INNER JOIN [TBL_Parse_Misc_LOOK_UP] SCRUB
		ON SCRUB.UNIQUEVENDORID = T.UniqueVendorID
		AND SCRUB.POSITION_VALUE = SUBSTRING(T.misc,SCRUB.POSITION_START,POSITION_LENGHT)
		AND SCRUB.ID = @maxrecord
		AND SCRUB.[Column_Name_Group] = 3
		AND SCRUB.[Product_number] = 2
		
		
		
		  --- 4. ISOLATE BILLABLE RECORDS AND DELETE BILLED WITHIN 30 DAYS IN PREVIOUS MONTH ( WE HAVE BILLABLE PREVIOUS MONTH RECORDS IN TABLE Temp_AlltransData_Billed)

	   IF OBJECT_ID('TBL_TITLE_CURRENT_MONTH_BILLABLE', 'U') IS NOT NULL DROP TABLE TBL_TITLE_CURRENT_MONTH_BILLABLE
	   
	   SELECT id,ClientID,LenderLoanNum,Borrower,PropAddr,LoanUID,LoanUID_checksum as checksum(LoanUID),CategoryID,VendorID,UniqueVendorID,TransID,
			  Partner,Type,AccessCode,EMail,URL,misc,Division,Platform,LogDate,
			  Version,LoanAmt,IntRate,LoanType,LoanPurp,AmortType,AppValue,DeedPos,SvrName,YYYYMM,
			  LoanProd,LoanProg,SubmitType,Client,AcctExec,City,State     
	   INTO   TBL_TITLE_CURRENT_MONTH_BILLABLE
	   FROM   TBL_TITLE_CURRENT_MONTH
	   WHERE  SubmitType = @ORDER -----OR SubmitType IS NULL

	   IF OBJECT_ID('TBL_TITLE_PREVIOUS_MONTH_BILLABLE', 'U') IS NOT NULL DROP TABLE TBL_TITLE_PREVIOUS_MONTH_BILLABLE
	   
	   SELECT M.ClientID, LoanUID,M.LoanUID_checksum, M.UniqueVendorID,cast(LogDate as date) as LogDate,M.YYYYMM
	   INTO   TBL_TITLE_PREVIOUS_MONTH_BILLABLE
	   FROM   TBL_PREVIOUS_MONTHS_BILLABLE M (NOLOCK)
	          INNER JOIN TBL_Product_types PROD ON PROD.Prod_Name = M.type and PROD.Product_number = 2    ----@PRODNUMBER
		      AND M.YYYYMM < @YYYYMM AND  M.YYYYMM > @YYYYMM -4
			  
	   
	   DELETE APP
	   FROM   TBL_Appr_CURRENT_MONTH_BILLABLE APP 
	          INNER JOIN TBL_Appr_PREVIOUS_MONTH_BILLABLE PREV 
	   ON     PREV.ClientID = APP.ClientID
		      AND APP.UniqueVendorID = PREV.UniqueVendorID
		      AND APP.LoanUID = PREV.LoanUID
			  AND DATEDIFF(DAY,PREV.LogDate,APP.LogDate) <= @SCRUB_WINDOW
		
		        /* beginning+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
				
				 ---- 3. FIND RECORDS STATUS BLOCK

	   ALTER TABLE TBL_Appr_CURRENT_MONTH
	   ADD  SubmitType VARCHAR(30),LoanProd VARCHAR(50),LoanProg VARCHAR(50), Client VARCHAR(120),AcctExec varchar (101),City VARCHAR(50),State VARCHAR(2)

	           ---Start SubmitType scrubbing and update to find new orders CORRELATED TO VENDORS FROM lu_PAPI_VendorMapping
	   ;WITH Vendors_From_Lu_PAPI as (
	                                   Select T.ID,
									          LEFT(SUBSTRING(misc,PATINDEX('%,%',misc)+1, LEN(misc) - PATINDEX('%,%',misc)),PATINDEX('%,%',SUBSTRING(misc,PATINDEX('%,%',misc)+1, LEN(misc)))-1) as SubmitType 
									   From   TBL_Appr_CURRENT_MONTH T
									          INNER JOIN DataProcessing.dbo.lu_PAPI_VendorMapping LU ON LU.UniqueVendorID = T.UniqueVendorID
									 )
       UPDATE T
	   SET T.SubmitType = @ORDER
	   FROM TBL_Appr_CURRENT_MONTH T
	        INNER JOIN Vendors_From_Lu_PAPI VEND ON VEND.ID = T.id
			INNER JOIN DataProcessing.dbo.lu_PAPI_VendorMapping LU ON LU.RequestType = VEND.SubmitType
	   
	   
	   
	   
	   UPDATE T 
	   SET Loanprod = LEFT(LEFT(misc,CHARINDEX(',',misc) -1 ),40),
		   Submittype = LEFT(LTRIM(RTRIM(CASE WHEN LTRIM(RTRIM(LEFT(RIGHT(misc,LEN(RTRIM(misc)) - CHARINDEX(',',RTRIM(misc))),	CHARINDEX(',',RIGHT(misc,LEN(RTRIM(misc)) - CHARINDEX(',',RTRIM(misc))))-1))) 
		   IN (SELECT  RTRIM(LTRIM(RequestType)) 
		       FROM    DataProcessing.dbo.lu_Vendor_Scrub_Control 
		               INNER JOIN TBL_Product_types PROD ON PROD.Prod_Name = DataProcessing.dbo.lu_Vendor_Scrub_Control.Type AND PROD.Product_number = @PRODNUMBER
		       WHERE   IsPSDKPartner = 1 AND separator = ',') THEN @ORDER
			           ELSE LEFT(RIGHT(misc,LEN(RTRIM(misc)) - CHARINDEX(',',RTRIM(misc))), CHARINDEX(',',RIGHT(misc,LEN(RTRIM(misc)) - CHARINDEX(',',RTRIM(misc))))-1) END)),20) 
	   FROM     TBL_Appr_CURRENT_MONTH T
				INNER JOIN DataProcessing.dbo.lu_Vendor_Scrub_Control SCRUB
				ON SCRUB.UniqueVendorID = T.UniqueVendorID
				INNER JOIN TBL_Product_types PROD ON PROD.Prod_Name = SCRUB.Type AND PROD.Product_number = @PRODNUMBER
	   WHERE    SCRUB.IsPSDKPartner = 1 AND SCRUB.separator = ','

	   UPDATE T 
	   SET     Loanprod = LEFT(LEFT(misc,CHARINDEX(';',misc) -1 ),40),
			   Submittype = LEFT(LTRIM(RTRIM(CASE WHEN LTRIM(RTRIM(LEFT(RIGHT(misc,LEN(RTRIM(misc)) - CHARINDEX(';',RTRIM(misc))),	CHARINDEX(';',RIGHT(misc,LEN(RTRIM(misc)) - CHARINDEX(';',RTRIM(misc))))-1))) 
			   IN (SELECT RTRIM(LTRIM(RequestType)) 
		       FROM DataProcessing.dbo.lu_Vendor_Scrub_Control
		              INNER JOIN TBL_Product_types PROD ON PROD.Prod_Name = DataProcessing.dbo.lu_Vendor_Scrub_Control.Type AND PROD.Product_number = @PRODNUMBER
		       WHERE IsPSDKPartner = 1 AND separator = ';') THEN @ORDER
			         ELSE LEFT(RIGHT(misc,LEN(RTRIM(misc)) - CHARINDEX(';',RTRIM(misc))), CHARINDEX(';',RIGHT(misc,LEN(RTRIM(misc)) - CHARINDEX(';',RTRIM(misc))))-1) END)),20) 
	   FROM     TBL_Appr_CURRENT_MONTH T
				INNER JOIN DataProcessing.dbo.lu_Vendor_Scrub_Control SCRUB
				ON SCRUB.UniqueVendorID = T.UniqueVendorID
				INNER JOIN TBL_Product_types PROD ON PROD.Prod_Name = SCRUB.Type AND PROD.Product_number = @PRODNUMBER
	   WHERE IsPSDKPartner = 1 AND separator = ';'

	   UPDATE T 
	   SET T.SubmitType = SCRUB.TO_ENTER_VALUE
	   FROM TBL_Appr_CURRENT_MONTH T
			INNER JOIN [TBL_Parse_Misc_LOOK_UP] SCRUB
			ON SCRUB.UNIQUEVENDORID = T.UniqueVendorID
			AND SCRUB.POSITION_VALUE = SUBSTRING(T.misc,SCRUB.POSITION_START,SCRUB.POSITION_LENGHT)
			AND SCRUB.[Column_Name_Group] = 3
			AND SCRUB.[Product_number] = @PRODNUMBER

	   ----UPDATE  FOR SPECIAL VENDOR 300090:
	   UPDATE t 
	   SET submittype = CASE WHEN LEFT(RIGHT(misc,LEN(RTRIM(misc)) - CHARINDEX(';',RTRIM(misc))),	CHARINDEX(';',RIGHT(misc,LEN(RTRIM(misc)) - CHARINDEX(';',RTRIM(misc))))-1) = 'NEW' THEN @ORDER
		                ELSE LEFT(RIGHT(misc,LEN(RTRIM(misc)) - CHARINDEX(';',RTRIM(misc))),	CHARINDEX(';',RIGHT(misc,LEN(RTRIM(misc)) - CHARINDEX(';',RTRIM(misc))))-1) END
	   FROM             TBL_Appr_CURRENT_MONTH t
						INNER JOIN [dbo].[TBL_Scrub_Exclusion_Records] UN
						ON UN.Uniquevendorid = T.UniqueVendorID
						AND UN.Product_number = @PRODNUMBER

				+++++++++++++++++++++++++++++++++++++++++++++++ end+++++++++++++++++++++++++++++++++++++++++++++++++++++*/

		--- GET PREVIOUS 3 MONTHS TITLE RECORDS ALREADY BILLED
		IF OBJECT_ID('TBL_TITLE_PREVIOUS_3MONTHS', 'U') IS NOT NULL DROP TABLE TBL_TITLE_PREVIOUS_3MONTHS
	   
			   
			  
		CREATE TABLE TBL_TITLE_PREVIOUS_3MONTHS (ClientID varchar(40),Borrower varchar (50),LoanUID varchar(40), UniqueVendorID varchar(17),
																Vendorid varchar(12), Type varchar(10), LogDate datetime,TransID varchar(50))

        
		declare @bDate datetime
declare @eDate datetime

if  Day(getdate()) = 1
	select @bDate = CONVERT(datetime, CONVERT(char(10), DATEADD(month, -1, getdate()),101) + ' 00:00')
else
	select @bDate =  CONVERT(datetime, CONVERT(char(10), DATEADD(DD, 1 -DATEPART(DD,getdate()), getdate()),101) + ' 00:00')
select @eDate = CONVERT(datetime, CONVERT(char(10), getdate(), 101) + ' 00:00')

		declare @sql varchar(1000)
		select @sql = 'insert into TBL_PREVIOUS_MONTHS_BILLABLE  '
		select @sql = @sql + 'select clientid,borrower,loanuid,uniquevendorid,vendorid,Type,logdate,transid from '
		select @sql = @sql + 'archivedata..AllTrans_' + case when datepart(m,dateadd(m,-3,@bDate)) < 10 then '0' + convert(char(1),datepart(m,dateadd(m,-3,@bDate))) else convert(char(2),datepart(m,dateadd(m,-3,@bDate))) end + '_' + right(datepart(yy,dateadd(m,-3,@bDate)),2) + '_For_Reports (nolock)'
		select @sql = @sql + 'where type in ( ''Title'') and isnull(billingcost,0) > 0 '
		-- select @sql
		exec  (@sql)

		select @sql = 'insert into TBL_PREVIOUS_MONTHS_BILLABLE  '
		select @sql = @sql + 'select clientid,borrower,loanuid,uniquevendorid,vendorid,Type,logdate,transid from '
		select @sql = @sql + 'archivedata..AllTrans_' + case when datepart(m,dateadd(m,-2,@bDate)) < 10 then '0' + convert(char(1),datepart(m,dateadd(m,-2,@bDate))) else convert(char(2),datepart(m,dateadd(m,-2,@bDate))) end + '_' + right(datepart(yy,dateadd(m,-2,@bDate)),2) + '_For_Reports (nolock)'
		select @sql = @sql + 'where type in ( ''Title'') and isnull(billingcost,0) > 0 '
		-- select @sql
		exec  (@sql)

		select @sql = 'insert into TBL_PREVIOUS_MONTHS_BILLABLE  '
		select @sql = @sql + 'select clientid,borrower,loanuid,uniquevendorid,vendorid,Type,logdate,transid from '
		select @sql = @sql + 'archivedata..AllTrans_' + case when datepart(m,dateadd(m,-1,@bDate)) < 10 then '0' + convert(char(1),datepart(m,dateadd(m,-1,@bDate))) else convert(char(2),datepart(m,dateadd(m,-1,@bDate))) end + '_' + right(datepart(yy,dateadd(m,-1,@bDate)),2) + '_For_Reports (nolock)'
		select @sql = @sql + 'where type in ( ''Title'') and isnull(billingcost,0) > 0 '
		-- select @sql
		exec  (@sql)

		-- for vendor 400090 since it has $0 as billingcost
		select @sql = 'insert into TBL_PREVIOUS_MONTHS_BILLABLE  '
		select @sql = @sql + 'select clientid,borrower,loanuid,uniquevendorid,vendorid,Type,logdate,transid from '
		select @sql = @sql + 'archivedata..AllTrans_' + case when datepart(m,dateadd(m,-3,@bDate)) < 10 then '0' + convert(char(1),datepart(m,dateadd(m,-3,@bDate))) else convert(char(2),datepart(m,dateadd(m,-3,@bDate))) end + '_' + right(datepart(yy,dateadd(m,-3,@bDate)),2) + '_For_Reports (nolock)'
		select @sql = @sql + 'where type in ( ''Title'') and uniquevendorid in (''400090'',''400091'') '
		-- select @sql
		exec  (@sql)

		select @sql = 'insert into TBL_PREVIOUS_MONTHS_BILLABLE  '
		select @sql = @sql + 'select clientid,borrower,loanuid,uniquevendorid,vendorid,Type,logdate,transid from '
		select @sql = @sql + 'archivedata..AllTrans_' + case when datepart(m,dateadd(m,-2,@bDate)) < 10 then '0' + convert(char(1),datepart(m,dateadd(m,-2,@bDate))) else convert(char(2),datepart(m,dateadd(m,-2,@bDate))) end + '_' + right(datepart(yy,dateadd(m,-2,@bDate)),2) + '_For_Reports (nolock)'
		select @sql = @sql + 'where type in ( ''Title'') and uniquevendorid in (''400090'',''400091'') '
		-- select @sql
		exec  (@sql)

		select @sql = 'insert into TBL_PREVIOUS_MONTHS_BILLABLE  '
		select @sql = @sql + 'select clientid,borrower,loanuid,uniquevendorid,vendorid,Type,logdate,transid from '
		select @sql = @sql + 'archivedata..AllTrans_' + case when datepart(m,dateadd(m,-1,@bDate)) < 10 then '0' + convert(char(1),datepart(m,dateadd(m,-1,@bDate))) else convert(char(2),datepart(m,dateadd(m,-1,@bDate))) end + '_' + right(datepart(yy,dateadd(m,-1,@bDate)),2) + '_For_Reports (nolock)'
		select @sql = @sql + 'where type in ( ''Title'') and uniquevendorid in (''400090'',''400091'') '
		-- select @sql
		exec  (@sql)

		create  index IX_TBL_TITLE_PREVIOUS_3MONTHS on TBL_TITLE_PREVIOUS_3MONTHS(ClientID, Borrower, LoanUID, UniqueVendorID, Type) 
              
	     --      ---- FIND AND DELETE RECORDS ALREADY BILLED WITHIN 90 DAYS IN PREVIOUS MONTH
			   --DELETE APP
			   --FROM TBL_TITLE_CURRENT_MONTH APP INNER JOIN TBL_TITLE_PREVIOUS_3MONTHS PREV 
			   --ON PREV.ClientID = APP.ClientID
			   --AND APP.UniqueVendorID = PREV.UniqueVendorID
			   --AND APP.LoanUID = PREV.LoanUID
			   --AND DATEDIFF(DAY,PREV.LogDate,APP.LogDate) <= @SCRUB_WINDOW

               
			   
			   UPDATE T set loanprod = left(misc,charindex(',',misc)-1),
		       loanprog = left(substring(substring(misc,charindex(',',misc) + 1,len(misc) - charindex(',',misc)),charindex(',',substring(misc,charindex(',',misc) + 1,len(misc) - charindex(',',misc)))+1,50),
	           charindex(',',substring(substring(misc,charindex(',',misc) + 1,len(misc) - charindex(',',misc)),charindex(',',substring(misc,charindex(',',misc) + 1,len(misc) - charindex(',',misc)))+1,50))-1)
               FROM TBL_TITLE_CURRENT_MONTH T
			   INNER JOIN [dbo].[TBL_Parse_Misc_LOOK_UP] LOOK
			   ON LOOK.UniqueVendorID = T.UniqueVendorID AND LOOK.[Column_Name_Group] = 4


			   Declare @maxrecord int = (select top 1 ID FROM [TBL_Parse_Misc_LOOK_UP] ORDER BY ID DESC)
	           WHILE @maxrecord > 0
						BEGIN
							 DECLARE @POSITION_START     SMALLINT = (SELECT [position_start]    FROM [TBL_Parse_Misc_LOOK_UP] WHERE ID = @maxrecord)
				             DECLARE @POSITION_LENGHT    SMALLINT = (SELECT [position_lenght]   FROM [TBL_Parse_Misc_LOOK_UP] WHERE ID = @maxrecord)
							 DECLARE @Column_Name_Group  SMALLINT = (SELECT [Column_Name_Group] FROM [TBL_Parse_Misc_LOOK_UP] WHERE ID = @maxrecord) 
							 DECLARE @Product_number     SMALLINT = (SELECT [Product_number]    FROM [TBL_Parse_Misc_LOOK_UP] WHERE ID = @maxrecord) 
							 
							 
							 IF @Product_number = 2 --- TITLE
							    
								BEGIN
							 
									 IF @Column_Name_Group = 3
										BEGIN
											 UPDATE T 
											 SET T.SubmitType = SCRUB.TO_ENTER_VALUE
											 FROM TBL_TITLE_CURRENT_MONTH T
											 INNER JOIN [TBL_Parse_Misc_LOOK_UP] SCRUB
											 ON SCRUB.UNIQUEVENDORID = T.UniqueVendorID
											 AND SCRUB.POSITION_VALUE = SUBSTRING(T.misc,@POSITION_START,@POSITION_LENGHT)
											 AND SCRUB.ID = @maxrecord
											 AND SCRUB.[Column_Name_Group] = 3
											 AND SCRUB.[Product_number] = 2
										END

                             
									 IF @Column_Name_Group = 1
										BEGIN
											 UPDATE T 
											 SET T.LoanProd = SUBSTRING(T.misc,@POSITION_START,@POSITION_LENGHT)
											 FROM TBL_TITLE_CURRENT_MONTH T
											 INNER JOIN [TBL_Parse_Misc_LOOK_UP] SCRUB
											 ON SCRUB.UNIQUEVENDORID = T.UniqueVendorID
											 AND SCRUB.ID = @maxrecord
											 AND SCRUB.[Column_Name_Group] = 1
											 AND SCRUB.[Product_number] = 2
										END

							
									 IF @Column_Name_Group = 2
										BEGIN
											 UPDATE T 
											 SET T.LoanProg = SUBSTRING(T.misc,@POSITION_START,@POSITION_LENGHT)
											 FROM TBL_TITLE_CURRENT_MONTH T
											 INNER JOIN [TBL_Parse_Misc_LOOK_UP] SCRUB
											 ON SCRUB.UNIQUEVENDORID = T.UniqueVendorID
											 AND SCRUB.ID = @maxrecord
											 AND SCRUB.[Column_Name_Group] = 2
											 AND SCRUB.[Product_number] = 2
										END
                                 END

							SET @maxrecord = @maxrecord -1

			          END 

			DECLARE @MIN_CLIENTID VARCHAR(15) = (SELECT MIN(CLIENTID)  FROM TBL_Scrub_Exclusion_Records WHERE Product_number = 1 )
	        DECLARE @MAX_CLIENTID VARCHAR(15) = (SELECT MAX(CLIENTID)  FROM TBL_Scrub_Exclusion_Records WHERE Product_number = 1 )
			DECLARE @BORROWER VARCHAR (25) =    (SELECT TOP 1 BORROWER FROM TBL_Scrub_Exclusion_Records  )
		    
			DELETE 
	        TBL_TITLE_CURRENT_MONTH
	        WHERE  ISNULL(ClientID,'')  IN   (SELECT Company  FROM [DataProcessing].DBO.lu_test_by_company)
				OR ISNULL(Borrower,'')  IN   (SELECT  Borname FROM [DataProcessing].DBO.lu_Test_By_Borname)OR ISNULL(Clientid,'')  IN (SELECT Clientid FROM [DataProcessing].DBO.lu_Test_By_ClientID)
				OR ISNULL(AccessCode,'') IN  (SELECT Access_Code FROM [DataProcessing].DBO.lu_Test_By_Access_Code)
				OR (ISNULL(clientid,'')  BETWEEN @MIN_CLIENTID AND @MAX_CLIENTID AND LEN(ISNULL(ClientID,'')) = 8)
				OR ISNULL(Borrower,'')  = ''
				OR Borrower LIKE @BORROWER
	        
			----- DELETE RECORDS WITH TEST EMAILS
			SET @maxrecord  = (select top 1 ID FROM TBL_Scrub_Exclusion_Records ORDER BY ID DESC)
			WHILE @maxrecord > 0
					BEGIN
						DECLARE @EMAIL VARCHAR(25) = (SELECT Email FROM TBL_Scrub_Exclusion_Records WHERE ID = @maxrecord)
						DELETE TBL_TITLE_CURRENT_MONTH WHERE EMAIL LIKE @EMAIL
						SET @maxrecord = @maxrecord - 1
	
					END

           
			ALTER TABLE  TBL_TITLE_CURRENT_MONTH
			ADD ReqType varchar(15),OrderNo varchar(10), ProviderID varchar(20),ProductID varchar(100),OfferID varchar(10)
		   
		   
			UPDATE T set T.ReqType = SUBSTRING(LOOK.Scrub_Column_Name,LOOK.position_start,LOOK.position_lenght)
			FROM TBL_TITLE_CURRENT_MONTH T
					INNER JOIN [dbo].[TBL_Parse_Misc_LOOK_UP] LOOK
					ON LOOK.UniqueVendorID = T.UniqueVendorID AND LOOK.[Product_number] = 2
			WHERE LOOK.[Column_Name_Group] = 5

			UPDATE T set T.OrderNo = SUBSTRING(LOOK.Scrub_Column_Name,LOOK.position_start,LOOK.position_lenght)
			FROM TBL_TITLE_CURRENT_MONTH T
					INNER JOIN [dbo].[TBL_Parse_Misc_LOOK_UP] LOOK
					ON LOOK.UniqueVendorID = T.UniqueVendorID AND LOOK.[Product_number] = 2
			WHERE LOOK.[Column_Name_Group] = 6

			UPDATE T set T.ProviderID = SUBSTRING(LOOK.Scrub_Column_Name,LOOK.position_start,LOOK.position_lenght)
			FROM TBL_TITLE_CURRENT_MONTH T
					INNER JOIN [dbo].[TBL_Parse_Misc_LOOK_UP] LOOK
					ON LOOK.UniqueVendorID = T.UniqueVendorID AND LOOK.[Product_number] = 2
			WHERE LOOK.[Column_Name_Group] = 7

			UPDATE T set T.ProductID = SUBSTRING(LOOK.Scrub_Column_Name,LOOK.position_start,LOOK.position_lenght)
			FROM TBL_TITLE_CURRENT_MONTH T
					INNER JOIN [dbo].[TBL_Parse_Misc_LOOK_UP] LOOK
					ON LOOK.UniqueVendorID = T.UniqueVendorID AND LOOK.[Product_number] = 2
			WHERE LOOK.[Column_Name_Group] = 8

			UPDATE T set T.OfferID = SUBSTRING(LOOK.Scrub_Column_Name,LOOK.position_start,LOOK.position_lenght)
			FROM TBL_TITLE_CURRENT_MONTH T
					INNER JOIN [dbo].[TBL_Parse_Misc_LOOK_UP] LOOK
					ON LOOK.UniqueVendorID = T.UniqueVendorID AND LOOK.[Product_number] = 2
			WHERE LOOK.[Column_Name_Group] = 9

			UPDATE T set AcctExec =UPPER(RTRIM(ISNULL(E.firstname,'')) + ' ' + ISNULL(E.lastname,''))
			FROM TBL_TITLE_CURRENT_MONTH T 
					INNER JOIN DataProcessing.dbo.Company C
					ON T.ClientID = C.Masteraccountingid
					LEFT OUTER JOIN DataProcessing.dbo.Employee E 
					ON e.username = c.accountMgrid
			WHERE ISNULL(T.AcctExec,'') = '' and ISNULL(C.accountMgrid,'') <> ''

			DECLARE  @minrecord SMALLINT  = (select top 1 ID FROM  [dbo].[TBL_SCRUB_LOOOK_UP_STANDARDIZATION] where [Product_number] = 2 ORDER BY ID ASC)
			SET      @maxrecord  = (select top 1 ID FROM  [dbo].[TBL_SCRUB_LOOOK_UP_STANDARDIZATION] where [Product_number] = 2 ORDER BY ID DESC)
			WHILE @maxrecord >= @minrecord
					BEGIN
						DECLARE @DIVISION VARCHAR(25) = (SELECT Column_Value FROM TBL_SCRUB_LOOOK_UP_STANDARDIZATION WHERE ID = @maxrecord AND [Product_number] = 2)
						DECLARE @TO_ENTER_VALUE VARCHAR(25) = (SELECT To_enter_value FROM TBL_SCRUB_LOOOK_UP_STANDARDIZATION WHERE ID = @maxrecord AND [Product_number] = 2)
					   
						UPDATE T
						SET T.Division = @TO_ENTER_VALUE
						FROM TBL_TITLE_CURRENT_MONTH T
						WHERE T.AccessCode LIKE @DIVISION
					    
						SET @maxrecord = @maxrecord - 1
	
					END
      
			UPDATE T set T.loanprog = T.orderno
			FROM   TBL_TITLE_CURRENT_MONTH t
			WHERE  orderno IS NOT NULL and loanprog IS NULL

			UPDATE T 
			SET T.Division = SCRUB.TO_ENTER_VALUE
			FROM TBL_TITLE_CURRENT_MONTH T
			INNER JOIN [TBL_Parse_Misc_LOOK_UP] SCRUB
			ON SCRUB.POSITION_VALUE = SUBSTRING(T.ClientID_Log,SCRUB.[position_start],SCRUB.position_lenght)
			AND SCRUB.[Column_Name_Group] = 12
			AND SCRUB.[Product_number] = 2
			WHERE T.Division = ''
	  
	  
	  
	   END TRY
	BEGIN CATCH

		EXECUTE [dbo].[logerror];
		RETURN -1;
		
	END CATCH
  END


