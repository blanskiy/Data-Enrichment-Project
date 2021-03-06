USE [DataProcessing_Test]
GO
/****** Object:  StoredProcedure [dbo].[ScrubVendorTransData_Flood]    Script Date: 6/27/2017 8:12:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[ScrubVendorTransData_Flood_MOD] 
AS

	
	BEGIN
		/* ================================================================================================================
			 Author:		Bruce Lanskiy
			 Create date: 06/27/2017
			 Modified:    
			
			 Description:	Original stored procedure, business logic, had been written by Connie Zhao.
			                Code below is an attempt to simplify and adapt to new standard.
			                The purpose of this stored procedure is to load FLOOD data, scrub 30 days window for unique vendorid/clientid/loanUID 
							
		                
		 
		   ================================================================================================================*/
		SET NOCOUNT ON;

		BEGIN TRY
	
		
				Declare @YYYYMM BIGINT = (select max([YYYYMM]) from [DataProcessing].[dbo].MapdownloadlogForScrubbing) ---   -1 
				DECLARE @SCRUB_WINDOW TINYINT = (SELECT TOP 1 SCRUBBING_WINDOW FROM TBL_Product_types WHERE Product_number = 3)
				
				DECLARE @bDate DATETIME
				DECLARE @eDate DATETIME
				IF  Day(getdate()) = 1
					SELECT @bDate = CONVERT(DATETIME, CONVERT(CHAR(10), DATEADD(month, -1, getdate()),101) + ' 00:00')
				ELSE
					SELECT @bDate =  CONVERT(DATETIME, CONVERT(CHAR(10), DATEADD(DD, 1 -DATEPART(DD,getdate()), getdate()),101) + ' 00:00')
				SELECT @eDate = CONVERT(DATETIME, CONVERT(CHAR(10), getdate(), 101) + ' 00:00')
		
		       
			   --- GET CURRENT MONTH TITLE
			   IF OBJECT_ID('TBL_FLOOD_CURRENT_MONTH', 'U') IS NOT NULL DROP TABLE TBL_FLOOD_CURRENT_MONTH
	   
			   SELECT m.id,ClientID,LenderLoanNum,Borrower,PropAddr,LoanUID,CategoryID,VendorID,m.UniqueVendorID,TransID,
					  Partner,Type,AccessCode,EMail,URL,misc,Division,Platform,LogDate,
					  Version,LoanAmt,IntRate,LoanType,LoanPurp,AmortType,AppValue,DeedPos,SvrName,YYYYMM    -----ClientID, LoanUID, UniqueVendorID, m.ID, LogDate
			   INTO   TBL_FLOOD_CURRENT_MONTH
			   FROM   [DataProcessing].[dbo].MapdownloadlogForScrubbing m (NOLOCK)
					  INNER JOIN TBL_Product_types PROD ON PROD.Prod_Name = m.type and PROD.Product_number = 3
					  and m.YYYYMM = @YYYYMM 
	   
			   ALTER TABLE TBL_FLOOD_CURRENT_MONTH
			   ADD  SubmitType VARCHAR(30),LoanProd VARCHAR(50),LoanProg VARCHAR(50), Client VARCHAR(120),AcctExec varchar (101),City VARCHAR(50),State VARCHAR(2)
	   
	           --- GET PREVIOUS MONTH APPRAISAL RECORDS
	           IF OBJECT_ID('TBL_FLOOD_PREVIOUS_MONTH', 'U') IS NOT NULL DROP TABLE TBL_FLOOD_PREVIOUS_MONTH
	   
			   SELECT ClientID, LoanUID, m.UniqueVendorID,m.ID,LogDate
			   INTO   TBL_FLOOD_PREVIOUS_MONTH
			   FROM   [DataProcessing].[dbo].MapdownloadlogForScrubbing m (NOLOCK)
					  INNER JOIN TBL_Product_types PROD ON PROD.Prod_Name = m.type and PROD.Product_number = 1
					  and m.YYYYMM = @YYYYMM -1 

			 ---- FIND AND DELETE RECORDS ALREADY BILLED WITHIN 30 DAYS IN PREVIOUS MONTH
	   
			   DELETE APP
			   FROM TBL_FLOOD_CURRENT_MONTH APP INNER JOIN TBL_FLOOD_PREVIOUS_MONTH PREV 
			   ON PREV.ClientID = APP.ClientID
			     AND APP.UniqueVendorID = PREV.UniqueVendorID
			     AND APP.LoanUID = PREV.LoanUID
			     AND DATEDIFF(DAY,PREV.LogDate,APP.LogDate) <= @SCRUB_WINDOW

               DELETE APP
			   FROM TBL_FLOOD_CURRENT_MONTH APP INNER JOIN TBL_Parse_Misc_LOOK_UP LOOK
			   ON LOOK.Uniquevendorid = APP.UniqueVendorID AND LOOK.Product_number = 3
			    AND SUBSTRING(APP.MISC,LOOK.position_start,LOOK.position_lenght) != LOOK.position_Value

               DELETE APP
			   FROM TBL_FLOOD_CURRENT_MONTH APP 
			    INNER JOIN [DataProcessing].DBO.lu_Test_By_ClientID LU ON
			    LU.Clientid = APP.ClientID 
			 
			   DELETE APP
			   FROM TBL_FLOOD_CURRENT_MONTH APP 
			    INNER JOIN [DataProcessing].DBO.lu_Test_By_Borname LU ON
			    LU.borname = APP.Borrower  
				
			   DELETE APP
			   FROM TBL_FLOOD_CURRENT_MONTH APP 
			    INNER JOIN [DataProcessing].DBO.lu_test_by_company LU ON
			    LU.Company = APP.ClientID 
			 
			   DECLARE @MIN_CLIENTID VARCHAR(15) = (SELECT MIN(CLIENTID) FROM TBL_Scrub_Exclusion_Records WHERE Product_number = 1 )
			   DECLARE @MAX_CLIENTID VARCHAR(15) = (SELECT MAX(CLIENTID) FROM TBL_Scrub_Exclusion_Records WHERE Product_number = 1 )
	       
				----- DELETE RECORDS WITH TEST EMAILS
			   DECLARE @maxrecord SMALLINT  = (select top 1 ID FROM TBL_Scrub_Exclusion_Records ORDER BY ID DESC)
				  WHILE @maxrecord > 0
						 BEGIN
							   DECLARE @EMAIL VARCHAR(25) = (SELECT Email FROM TBL_Scrub_Test_Email WHERE ID = @maxrecord)
							   DELETE TBL_FLOOD_CURRENT_MONTH WHERE EMAIL LIKE @EMAIL
							   SET @maxrecord = @maxrecord - 1
	
						 END
			
				DECLARE @BORROWER VARCHAR(25) = (SELECT Borrower FROM TBL_Scrub_Exclusion_Records WHERE Product_number = 3)
				DELETE APP
				FROM TBL_FLOOD_CURRENT_MONTH APP 
				WHERE Borrower LIKE @BORROWER	     

				DECLARE @POSITIONSTART TINYINT = (SELECT [position_start] FROM [dbo].[TBL_Parse_Misc_LOOK_UP] 
												  WHERE Product_number = 3 AND [Column_Name_Group] = 3 AND [Uniquevendorid] = '')
				DECLARE @POSITIONLENGHT TINYINT = (SELECT [position_lenght] FROM [dbo].[TBL_Parse_Misc_LOOK_UP] 
												  WHERE Product_number = 3 AND [Column_Name_Group] = 3 AND [Uniquevendorid] = '')
				UPDATE T
				SET T.SubmitType = SUBSTRING(T.MISC,@POSITIONSTART,@POSITIONLENGHT)
				FROM TBL_FLOOD_CURRENT_MONTH T
	        
				UPDATE T
				SET T.SubmitType = SUBSTRING(T.MISC,LOOK.position_start,LOOK.position_lenght)
				FROM TBL_FLOOD_CURRENT_MONTH T
				INNER JOIN [dbo].[TBL_Parse_Misc_LOOK_UP] LOOK ON LOOK.Uniquevendorid = T.UniqueVendorID
				AND LOOK.Product_number = 3 AND LOOK.Column_Name_Group = 3

				UPDATE T
				SET T.Loanprod = SUBSTRING(T.MISC,LOOK.position_start,LOOK.position_lenght)
				FROM TBL_FLOOD_CURRENT_MONTH T
				INNER JOIN [dbo].[TBL_Parse_Misc_LOOK_UP] LOOK ON LOOK.Uniquevendorid = T.UniqueVendorID
				AND LOOK.Product_number = 3 AND LOOK.Column_Name_Group = 1

				UPDATE T 
				SET T.Client = LEFT(C.COMPANYName,50), T.City = LEFT(C.CITY,25), T.STATE = LEFT(C.STATE,2)
				FROM TBL_FLOOD_CURRENT_MONTH T JOIN [DataProcessing].DBO.Company c
				ON t.Clientid = c.MasterAccountingid

				UPDATE T SET AcctExec =UPPER(RTRIM(ISNULL(E.firstname,'')) + ' ' + ISNULL(E.lastname,''))
				FROM TBL_FLOOD_CURRENT_MONTH T 
				JOIN [DataProcessing].DBO.Company C ON T.ClientID = C.MasterAccountingid
				LEFT JOIN [DataProcessing].DBO.Employee E --WITH (NOLOCK)
				ON C.accountmgrid = E.username
				WHERE ISNULL(T.AcctExec,'') = '' AND ISNULL(C.accountmgrid,'') <> ''

			   -- SET up division 
				UPDATE t SET Division = tc.Division
				FROM TBL_FLOOD_CURRENT_MONTH t
				JOIN [DataProcessing].DBO.Temp_CO_GE_EN_CLient tc
				ON t.ClientID = tc.CLientid
				WHERE  ISNULL(t.division,'') = ''

		END TRY
		BEGIN CATCH

			EXECUTE [dbo].[logerror];
			RETURN -1;
		
		END CATCH
    END
