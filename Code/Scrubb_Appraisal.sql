USE [DataProcessing_Test]
GO
/****** Object:  StoredProcedure [dbo].[ScrubVendorTransData_Appr_MOD]    Script Date: 7/25/2017 9:36:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[ScrubVendorTransData_Appr_MOD] 
	AS
	
	BEGIN
		/* ================================================================================================================
			 Author:		Bruce Lanskiy
			 Create date: 06/19/2017
			 Modified:    
			
			 Description:	Original stored procedure, business logic, had been written by Connie Zhao.
			                Code below is an attempt to simplify and adapt to new standard.
			                The purpose of this stored procedure is to load appraisal data, scrub 30 days window for unique vendorid/clientid/loanUID 
							
		                
		 
		   ================================================================================================================*/
		SET NOCOUNT ON;

		BEGIN TRY
	
		DECLARE @bDate DATETIME
		DECLARE @eDate DATETIME 
		DECLARE @PRODNUMBER TINYINT = 1
		Declare @YYYYMM bigint = (select max([YYYYMM]) from [DataProcessing].[dbo].MapdownloadlogForScrubbing) ---    -1
		DECLARE @ORDER VARCHAR(10) = 'Order'
		DECLARE @SCRUB_WINDOW TINYINT = (SELECT TOP 1 SCRUBBING_WINDOW FROM TBL_Product_types WHERE Product_number = @PRODNUMBER)
	
		--- 1. GET CURRENT MONTH APPRAISAL RECORDS
		IF OBJECT_ID('TBL_Appr_CURRENT_MONTH', 'U') IS NOT NULL DROP TABLE TBL_Appr_CURRENT_MONTH
	   
		SELECT m.id, CASE WHEN LEFT(m.ClientID,4) IN ('3011','3010') THEN RIGHT(m.ClientID,8) ELSE RIGHT(m.ClientID,6) END as ClientID,LenderLoanNum,Borrower,PropAddr,LoanUID,CategoryID,m.VendorID,m.UniqueVendorID,TransID,
				Partner,Type,AccessCode,EMail,URL,misc,Division,Platform,cast(m.LogDate as date) as LogDate,
				Version,LoanAmt,IntRate,LoanType,LoanPurp,m.ClientID AS AmortType,AppValue,DeedPos,SvrName,YYYYMM    -----ClientID, LoanUID, UniqueVendorID, m.ID, LogDate
		INTO   TBL_Appr_CURRENT_MONTH
		FROM   [DataProcessing].[dbo].MapdownloadlogForScrubbing m (NOLOCK)
				INNER JOIN TBL_Product_types PROD ON PROD.Prod_Name = m.type and PROD.Product_number = @PRODNUMBER
				and m.YYYYMM = @YYYYMM 
	   
	   --- 2. Delete EXCLUSIONS:

		DECLARE @MIN_CLIENTID VARCHAR(15) = (SELECT MIN(CLIENTID) FROM TBL_Scrub_Exclusion_Records WHERE Product_number = @PRODNUMBER )
		DECLARE @MAX_CLIENTID VARCHAR(15) = (SELECT MAX(CLIENTID) FROM TBL_Scrub_Exclusion_Records WHERE Product_number = @PRODNUMBER )
	       
		DELETE APP
		FROM TBL_Appr_CURRENT_MONTH APP
		     INNER JOIN TBL_lu_test_integrated_Exclusions EXCL
			 ON EXCL.ClientID = APP.ClientID
        
		DELETE APP
		FROM TBL_Appr_CURRENT_MONTH APP
		     INNER JOIN TBL_lu_test_integrated_Exclusions EXCL
			 ON EXCL.Company = APP.ClientID

        DELETE APP
		FROM TBL_Appr_CURRENT_MONTH APP
		     INNER JOIN TBL_lu_test_integrated_Exclusions EXCL
			 ON EXCL.Access_Code = APP.AccessCode

        DELETE APP
		FROM TBL_Appr_CURRENT_MONTH APP
		     INNER JOIN TBL_lu_test_integrated_Exclusions EXCL
			 ON EXCL.Borname = APP.Borrower

        DELETE APP
		FROM TBL_Appr_CURRENT_MONTH APP
		WHERE ISNULL(APP.clientid,'')  BETWEEN @MIN_CLIENTID AND @MAX_CLIENTID AND LEN(ISNULL(APP.ClientID,'')) = 8
		
		DELETE APP
		FROM TBL_Appr_CURRENT_MONTH APP
		WHERE APP.Borrower IS NULL
	        
		----- DELETE RECORDS WITH TEST EMAILS
		DECLARE @maxrecord BIGINT  = (select top 1 ID FROM TBL_Scrub_Exclusion_Records ORDER BY ID DESC)
		WHILE @maxrecord > 0
				BEGIN
					DECLARE @EMAIL VARCHAR(25) = (SELECT Email FROM TBL_Scrub_Exclusion_Records WHERE ID = @maxrecord)
					DELETE TBL_Appr_CURRENT_MONTH WHERE EMAIL LIKE @EMAIL
					SET @maxrecord = @maxrecord - 1
	
				END
	
		---- DELETE RECORDS CORRELATED TO EXCEPTION TABLES
		DELETE T
		FROM TBL_Appr_CURRENT_MONTH T 
		INNER JOIN DBO.TBL_lu_test_integrated_Exclusions LU
		ON LU.CLIENTID = T.CLIENTID 
			
		DELETE T
		FROM TBL_Appr_CURRENT_MONTH T
		INNER JOIN [DataProcessing].DBO.lu_mapfiles LU
		ON LU.uniquevendorid = T.uniquevendorid
		AND LU.ClientID = T.ClientID
		AND LU.ClientID IS NOT NULL

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
	   SET T.SubmitType = SCRUB.TO_ENTER_VALUE
	   FROM TBL_Appr_CURRENT_MONTH T
			INNER JOIN [TBL_Parse_Misc_LOOK_UP] SCRUB
			ON SCRUB.UNIQUEVENDORID = T.UniqueVendorID
			AND SCRUB.POSITION_VALUE = SUBSTRING(T.misc,SCRUB.POSITION_START,SCRUB.POSITION_LENGHT)
			AND SCRUB.[Column_Name_Group] = 3
			AND SCRUB.[Product_number] = @PRODNUMBER
	   
	   ----UPDATE  FOR SPECIAL VENDOR 300090:
	   UPDATE t 
	   SET submittype = CASE WHEN LEFT(RIGHT(misc,LEN(RTRIM(misc)) - CHARINDEX(';',RTRIM(misc))),	CHARINDEX(';',RIGHT(misc,LEN(RTRIM(misc)) - CHARINDEX(';',RTRIM(misc))))-1) = 'NEW' THEN 'Order'
		                ELSE LEFT(RIGHT(misc,LEN(RTRIM(misc)) - CHARINDEX(';',RTRIM(misc))),	CHARINDEX(';',RIGHT(misc,LEN(RTRIM(misc)) - CHARINDEX(';',RTRIM(misc))))-1) END
	   FROM TBL_Appr_CURRENT_MONTH t
		    INNER JOIN [dbo].[TBL_Scrub_Exclusion_Records] UN
		    ON UN.Uniquevendorid = T.UniqueVendorID
	        AND UN.Product_number = @PRODNUMBER
	   
	 
	   
	   --- 4. ISOLATE BILLABLE RECORDS AND DELETE BILLED WITHIN 30 DAYS IN PREVIOUS MONTH ( WE HAVE BILLABLE PREVIOUS MONTH RECORDS IN TABLE Temp_AlltransData_Billed)

	   IF OBJECT_ID('TBL_Appr_CURRENT_MONTH_BILLABLE', 'U') IS NOT NULL DROP TABLE TBL_Appr_CURRENT_MONTH_BILLABLE
	   
	   SELECT id,ClientID,LenderLoanNum,Borrower,PropAddr,LoanUID,CategoryID,VendorID,UniqueVendorID,TransID,
			  Partner,Type,AccessCode,EMail,URL,misc,Division,Platform,LogDate,
			  Version,LoanAmt,IntRate,LoanType,LoanPurp,AmortType,AppValue,DeedPos,SvrName,YYYYMM,
			  LoanProd,LoanProg,SubmitType,Client,AcctExec,City,State     
	   INTO   TBL_Appr_CURRENT_MONTH_BILLABLE
	   FROM   TBL_Appr_CURRENT_MONTH
	   WHERE  SubmitType = @ORDER OR SubmitType IS NULL

	   IF OBJECT_ID('TBL_Appr_PREVIOUS_MONTH_BILLABLE', 'U') IS NOT NULL DROP TABLE TBL_Appr_PREVIOUS_MONTH_BILLABLE
	   
	   SELECT M.ClientID, LoanUID, M.UniqueVendorID,cast(LogDate as date) as LogDate
	   INTO   TBL_Appr_PREVIOUS_MONTH_BILLABLE
	   FROM   [DataProcessing].DBO.[Temp_AlltransData_Billed] M (NOLOCK)
	          INNER JOIN TBL_Product_types PROD ON PROD.Prod_Name = M.type and PROD.Product_number = 1    ----@PRODNUMBER
		      and CONVERT([bigint],left(CONVERT([varchar],LogDate,(112)),(6)))= @YYYYMM -1
	   
	   DELETE APP
	   FROM   TBL_Appr_CURRENT_MONTH_BILLABLE APP 
	          INNER JOIN TBL_Appr_PREVIOUS_MONTH_BILLABLE PREV 
	   ON     PREV.ClientID = APP.ClientID
		      AND APP.UniqueVendorID = PREV.UniqueVendorID
		      AND APP.LoanUID = PREV.LoanUID
			  AND DATEDIFF(DAY,PREV.LogDate,APP.LogDate) <= @SCRUB_WINDOW


      ---- 5. TRANSFORMATION BLOCK ON OTHER COLUMNS:

		UPDATE T 
			SET T.LoanProd = SUBSTRING(T.misc,SCRUB.POSITION_START,SCRUB.POSITION_LENGHT)
			FROM TBL_Appr_CURRENT_MONTH_BILLABLE T
				INNER JOIN [TBL_Parse_Misc_LOOK_UP] SCRUB
				ON SCRUB.UNIQUEVENDORID = T.UniqueVendorID
				AND SCRUB.[Column_Name_Group] = 1
				AND SCRUB.[Product_number] = @PRODNUMBER    
		
		UPDATE T 
			SET T.LoanProg = SUBSTRING(T.misc,SCRUB.POSITION_START,SCRUB.POSITION_LENGHT)
			FROM TBL_Appr_CURRENT_MONTH_BILLABLE T
				INNER JOIN [TBL_Parse_Misc_LOOK_UP] SCRUB
				ON SCRUB.UNIQUEVENDORID = T.UniqueVendorID
				AND SCRUB.[Column_Name_Group] = 2
				AND SCRUB.[Product_number] = @PRODNUMBER	    
	   
	   ;WITH Vendors_From_Lu_PAPI as (
	                                   Select T.ID,
									          LEFT(misc,PATINDEX('%,%',misc) -1) as loanprod 
									   From   TBL_Appr_CURRENT_MONTH_BILLABLE T
									          INNER JOIN DataProcessing.dbo.lu_PAPI_VendorMapping LU ON LU.UniqueVendorID = T.UniqueVendorID
									 )
		UPDATE T
		    SET T.LoanProd = VEND.loanprod
		    FROM TBL_Appr_CURRENT_MONTH_BILLABLE T
			     INNER JOIN Vendors_From_Lu_PAPI VEND ON VEND.ID = T.id 
	   
		----UPDATE  FOR SPECIAL VENDOR 300090:
		UPDATE t 
		    SET loanprod = LEFT(LEFT(misc,CHARINDEX(';',misc) -1 ),40),
			    loanprog = LEFT( LEFT(LEFT(RIGHT(misc,LEN(RTRIM(misc)) - CHARINDEX(';',misc) - CHARINDEX(';',RIGHT(misc,LEN(RTRIM(misc)) - CHARINDEX(';',RTRIM(misc))))),20),
				CHARINDEX(';',RIGHT(misc,LEN(RTRIM(misc)) - CHARINDEX(';',misc) - CHARINDEX(';',RIGHT(misc,LEN(RTRIM(misc)) - CHARINDEX(';',RTRIM(misc))))))-1) ,50)
		    FROM TBL_Appr_CURRENT_MONTH_BILLABLE t
		         INNER JOIN [dbo].[TBL_Scrub_Exclusion_Records] UN
		         ON   UN.Uniquevendorid = T.UniqueVendorID
			     AND UN.Product_number = @PRODNUMBER
	   
	   
	   UPDATE T
		   SET T.LoanPurp = SCRUB.To_enter_value
		   FROM TBL_Appr_CURRENT_MONTH_BILLABLE T
				INNER JOIN [dbo].[TBL_SCRUB_LOOOK_UP_STANDARDIZATION] SCRUB
				ON SCRUB.Column_Value = T.LoanPurp
				AND SCRUB.Product_number = @PRODNUMBER
	   
	   ---UPDATES ON EMPTY COLUMNS
		UPDATE T 
			SET T.Client = LEFT(C.COMPANYName,50), T.City = LEFT(C.CITY,25), T.STATE = LEFT(C.STATE,2)
			FROM TBL_Appr_CURRENT_MONTH_BILLABLE T JOIN [DataProcessing].DBO.Company c
			ON t.Clientid = c.MasterAccountingid

		UPDATE T SET AcctExec =UPPER(RTRIM(ISNULL(E.firstname,'')) + ' ' + ISNULL(E.lastname,''))
			FROM TBL_Appr_CURRENT_MONTH_BILLABLE T 
				JOIN [DataProcessing].DBO.Company C ON T.ClientID = C.MasterAccountingid
				LEFT JOIN [DataProcessing].DBO.Employee E --WITH (NOLOCK)
				ON C.accountmgrid = E.username
			WHERE ISNULL(T.AcctExec,'') = '' AND ISNULL(C.accountmgrid,'') <> ''

           -- SET up division 
		UPDATE t 
			SET Division = tc.Division
			FROM TBL_Appr_CURRENT_MONTH_BILLABLE t
				JOIN [DataProcessing].DBO.Temp_CO_GE_EN_CLient tc
				ON t.ClientID = tc.CLientid
			WHERE  t.division IS NULL

		 

		   ;WITH Remove_duplicates as 
		                            ( SELECT clientid, uniquevendorid,loanuid,borrower, row_number() OVER (PARTITION BY clientid, uniquevendorid,loanuid,borrower ORDER BY ID ASC) as NUMBER
                                      FROM TBL_Appr_CURRENT_MONTH_BILLABLE
				                    )
		  DELETE 
		  FROM Remove_duplicates
		  WHERE  number > 1
		  

    END TRY
			BEGIN CATCH

				EXECUTE [dbo].[logerror];
				RETURN -1;
		
			END CATCH
END
