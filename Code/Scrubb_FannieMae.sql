USE [DataProcessing_Test]
GO
/****** Object:  StoredProcedure [dbo].[ScrubVendorTransData_FannieMae]    Script Date: 7/10/2017 11:51:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  ALTER PROCEDURE [dbo].[ScrubVendorTransData_FannieMae_MOD] 
	AS
	
	BEGIN
		/* ================================================================================================================
			 Author:		Bruce Lanskiy
			 Create date: 07/11/2017
			 Modified:    
			
			 Description:	Original stored procedure, business logic, had been written by Connie Zhao.
			                Code below is an attempt to simplify and adapt to new standard.
			                The purpose of this stored procedure is to load FannieMae data, scrub 90 days window for unique vendorid/clientid/loanUID 
							
		                
		 
		   ================================================================================================================*/
			SET NOCOUNT ON;

			BEGIN TRY
	
			DECLARE @bDate DATETIME
			DECLARE @eDate DATETIME
			DECLARE @PRODNUMBER TINYINT = 10
			DECLARE @YYYYMM bigint = (select max([YYYYMM]) from [DataProcessing].[dbo].MapdownloadlogForScrubbing) -1
			DECLARE @SCRUB_WINDOW TINYINT = (SELECT TOP 1 SCRUBBING_WINDOW FROM TBL_Product_types WHERE Product_number = @PRODNUMBER)
	       
			IF  Day(getdate()) = 1
				SELECT @bDate = CONVERT(DATETIME, CONVERT(CHAR(10), DATEADD(month, -1, getdate()),101) + ' 00:00')
			ELSE
				SELECT @bDate =  CONVERT(DATETIME, CONVERT(CHAR(10), DATEADD(DD, 1 -DATEPART(DD,getdate()), getdate()),101) + ' 00:00')
			SELECT @eDate = CONVERT(DATETIME, CONVERT(CHAR(10), getdate(), 101) + ' 00:00')

			--- GET CURRENT MONTH GSE RECORDS  
			IF OBJECT_ID('TBL_GSE_CURRENT_MONTH', 'U') IS NOT NULL DROP TABLE TBL_GSE_CURRENT_MONTH
	   
			SELECT m.id,ClientID,LenderLoanNum,Borrower,PropAddr,LoanUID,CategoryID,VendorID,m.UniqueVendorID,TransID,
					Partner,Type,AccessCode,EMail,URL,misc,Division,Platform,LogDate,SUBSTRING(misc,50,10) as Split,SUBSTRING(misc,31,10) AS ProductCode,
					Version,LoanAmt,IntRate,LoanType,RTRIM(LEFT(misc,30)) as CaseFileID, LoanPurp,AmortType,AppValue,DeedPos,SvrName,YYYYMM    -----ClientID, LoanUID, UniqueVendorID, m.ID, LogDate
			INTO   TBL_GSE_CURRENT_MONTH
			FROM   [DataProcessing].[dbo].MapdownloadlogForScrubbing m (NOLOCK)
					INNER JOIN TBL_Product_types PROD ON PROD.Prod_Name = m.type and PROD.Product_number = @PRODNUMBER
					and m.YYYYMM = @YYYYMM 
	    
			DECLARE @EXCLUDEFREDDIEMAC VARCHAR(15) = (Select Uniquevendorid FROM  [TBL_Scrub_Exclusion_Records] where Product_number = @PRODNUMBER)  
	   
			DELETE TBL_GSE_CURRENT_MONTH WHERE UniqueVendorID = @EXCLUDEFREDDIEMAC
	   
			ALTER TABLE TBL_GSE_CURRENT_MONTH
			ADD  SubmitType VARCHAR(30),LoanProd VARCHAR(50),LoanProg VARCHAR(50), Client VARCHAR(120),AcctExec varchar (101),City VARCHAR(50),State VARCHAR(2)
	   
			--- GET PREVIOUS MONTH APPRAISAL RECORDS
			IF OBJECT_ID('TBL_GSE_PREVIOUS_MONTH', 'U') IS NOT NULL DROP TABLE TBL_GSE_PREVIOUS_MONTH
	   
			SELECT ClientID, LoanUID, m.UniqueVendorID,m.ID,LogDate
			INTO   TBL_GSE_PREVIOUS_MONTH
			FROM   [DataProcessing].[dbo].MapdownloadlogForScrubbing m (NOLOCK)
					INNER JOIN TBL_Product_types PROD ON PROD.Prod_Name = m.type and PROD.Product_number = @PRODNUMBER
					and m.YYYYMM = @YYYYMM -1 
	   
			DELETE TBL_GSE_PREVIOUS_MONTH WHERE UniqueVendorID = @EXCLUDEFREDDIEMAC

			---- FIND AND DELETE RECORDS ALREADY BILLED WITHIN 90 DAYS IN PREVIOUS MONTHs
	   
			DELETE APP
			FROM TBL_GSE_CURRENT_MONTH APP INNER JOIN TBL_GSE_PREVIOUS_MONTH PREV 
			ON PREV.ClientID = APP.ClientID
			AND APP.UniqueVendorID = PREV.UniqueVendorID
			AND APP.LoanUID = PREV.LoanUID
			AND DATEDIFF(DAY,PREV.LogDate,APP.LogDate) <= @SCRUB_WINDOW

			---- DELETE RECORDS CORRELATED TO EXCEPTION TABLES
			DELETE T
			FROM TBL_GSE_CURRENT_MONTH T 
			INNER JOIN [DataProcessing].DBO.lu_Test_By_ClientID LU
			ON LU.CLIENTID = T.CLIENTID 

			DELETE T
			FROM TBL_GSE_CURRENT_MONTH T 
			INNER JOIN [DataProcessing].DBO.lu_test_by_borname LU
			ON LU.borname = T.Borrower
		   
			---UPDATES ON EMPTY COLUMNS
			UPDATE T 
			SET  T.Client = LEFT(C.COMPANYName,120), T.City = LEFT(C.CITY,25), T.STATE = LEFT(C.STATE,2)
			FROM TBL_GSE_CURRENT_MONTH T JOIN [DataProcessing].DBO.Company c
			ON   T.Clientid = c.MasterAccountingid

			UPDATE T SET AcctExec =UPPER(RTRIM(ISNULL(E.firstname,'')) + ' ' + ISNULL(E.lastname,''))
			FROM TBL_GSE_CURRENT_MONTH T 
			JOIN [DataProcessing].DBO.Company C ON T.ClientID = C.MasterAccountingid
			LEFT JOIN [DataProcessing].DBO.Employee E --WITH (NOLOCK)
			ON C.accountmgrid = E.username
			WHERE ISNULL(T.AcctExec,'') = '' AND ISNULL(C.accountmgrid,'') <> ''

			DELETE T
			FROM TBL_GSE_CURRENT_MONTH T 
			INNER JOIN [DataProcessing].DBO.lu_test_by_company LU
			ON LU.Company = T.Client  

			UPDATE T 
			SET T.SubmitType = LEFT(RTRIM(LTRIM(REPLACE (LEFT(T.misc,SCRUB.position_lenght),'-',''))),SCRUB.position_lenght)
			FROM TBL_GSE_CURRENT_MONTH T
			INNER JOIN [TBL_Parse_Misc_LOOK_UP] SCRUB
			ON SCRUB.UNIQUEVENDORID = T.VendorID
			AND SCRUB.[Product_number] = @PRODNUMBER
			AND SCRUB.[Column_Name_Group] = 3
			
     END TRY
			BEGIN CATCH

				EXECUTE [dbo].[logerror];
				RETURN -1;
		
			END CATCH
  END


	