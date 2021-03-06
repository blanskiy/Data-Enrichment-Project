USE [DataProcessing_Test]
GO
/****** Object:  StoredProcedure [dbo].[ScrubVendorTransData_Docs]    Script Date: 6/28/2017 9:52:32 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ScrubVendorTransData_Docs_MOD] -- created on 7/15/13
AS
BEGIN
		/* ================================================================================================================
			 Author:		Bruce Lanskiy
			 Create date: 06/28/2017
			 Modified:    
			
			 Description:	Original stored procedure, business logic, had been written by Connie Zhao.
			                Code below is an attempt to simplify and adapt to new standard.
			                The purpose of this stored procedure is to load Documents AND Disclosure data, 
							scrub 30 days window for unique vendorid/clientid/loanUID 
							
		                
		 
		   ================================================================================================================*/
		SET NOCOUNT ON;

		BEGIN TRY
	
		
				Declare @YYYYMM BIGINT = (select max([YYYYMM]) from [DataProcessing].[dbo].MapdownloadlogForScrubbing) ---   -1 
				DECLARE @SCRUB_WINDOW TINYINT = (SELECT TOP 1 SCRUBBING_WINDOW FROM TBL_Product_types WHERE Product_number = 7)
				
				DECLARE @bDate DATETIME
				DECLARE @eDate DATETIME
				IF  Day(getdate()) = 1
					SELECT @bDate = CONVERT(DATETIME, CONVERT(CHAR(10), DATEADD(month, -1, getdate()),101) + ' 00:00')
				ELSE
					SELECT @bDate =  CONVERT(DATETIME, CONVERT(CHAR(10), DATEADD(DD, 1 -DATEPART(DD,getdate()), getdate()),101) + ' 00:00')
				SELECT @eDate = CONVERT(DATETIME, CONVERT(CHAR(10), getdate(), 101) + ' 00:00')
		
		       
				--- GET CURRENT MONTH RECORDS
				IF OBJECT_ID('TBL_DOCS_DISCLOSURE_CURRENT_MONTH', 'U') IS NOT NULL DROP TABLE TBL_DOCS_DISCLOSURE_CURRENT_MONTH
	   
				SELECT m.id,ClientID,LenderLoanNum,Borrower,PropAddr,LoanUID,CategoryID,VendorID,m.UniqueVendorID,TransID,
						Partner,Type,AccessCode,EMail,URL,misc,Division,Platform,LogDate,ClientID as ClientID_log,
						Version,left(misc,10)as Submittype,LoanAmt,IntRate,LoanType,LoanPurp,SUBSTRING(misc,96,15) as LoanProg,
						AmortType,AppValue,DeedPos,SvrName,YYYYMM    -----ClientID, LoanUID, UniqueVendorID, m.ID, LogDate
				INTO   TBL_DOCS_DISCLOSURE_CURRENT_MONTH
				FROM   [DataProcessing].[dbo].MapdownloadlogForScrubbing m (NOLOCK)
						INNER JOIN TBL_Product_types PROD ON PROD.Prod_Name = m.type and PROD.Product_number IN (7,8)
						and m.YYYYMM = @YYYYMM 
	   
				ALTER TABLE TBL_DOCS_DISCLOSURE_CURRENT_MONTH
				ADD  LoanProd VARCHAR(50), Client VARCHAR(120),AcctExec varchar (101),City VARCHAR(50),State VARCHAR(2)
	   
				--- GET PREVIOUS MONTH  RECORDS
				IF OBJECT_ID('TBL_DOCS_DISCLOSURE_PREVIOUS_MONTH', 'U') IS NOT NULL DROP TABLE TBL_DOCS_DISCLOSURE_PREVIOUS_MONTH
	   
				SELECT ClientID, LoanUID, m.UniqueVendorID,m.ID,LogDate
				INTO   TBL_DOCS_DISCLOSURE_PREVIOUS_MONTH
				FROM   [DataProcessing].[dbo].MapdownloadlogForScrubbing m (NOLOCK)
						INNER JOIN TBL_Product_types PROD ON PROD.Prod_Name = m.type and PROD.Product_number IN (7,8)
						and m.YYYYMM = @YYYYMM -1 

	            ---- FIND AND DELETE RECORDS ALREADY BILLED WITHIN 30 DAYS IN PREVIOUS MONTH
				DELETE APP
				FROM TBL_DOCS_DISCLOSURE_CURRENT_MONTH APP INNER JOIN TBL_DOCS_DISCLOSURE_PREVIOUS_MONTH PREV 
				ON PREV.ClientID = APP.ClientID
					AND APP.UniqueVendorID = PREV.UniqueVendorID
					AND APP.LoanUID = PREV.LoanUID
					AND DATEDIFF(DAY,PREV.LogDate,APP.LogDate) <= @SCRUB_WINDOW

				DELETE APP
				FROM TBL_DOCS_DISCLOSURE_CURRENT_MONTH APP 
				INNER JOIN [DataProcessing].DBO.lu_Test_By_ClientID LU ON
				LU.Clientid = APP.ClientID 
			 
				DELETE APP
				FROM TBL_DOCS_DISCLOSURE_CURRENT_MONTH APP 
				INNER JOIN [DataProcessing].DBO.lu_Test_By_Borname LU ON
				LU.borname = APP.Borrower  
				
				DELETE APP
				FROM TBL_DOCS_DISCLOSURE_CURRENT_MONTH APP 
				INNER JOIN [DataProcessing].DBO.lu_test_by_company LU ON
				LU.Company = APP.ClientID 
			 
				DECLARE @MIN_CLIENTID VARCHAR(15) = (SELECT MIN(CLIENTID) FROM TBL_Scrub_Exclusion_Records WHERE Product_number = 1 )
				DECLARE @MAX_CLIENTID VARCHAR(15) = (SELECT MAX(CLIENTID) FROM TBL_Scrub_Exclusion_Records WHERE Product_number = 1 )
	       
				----- DELETE RECORDS WITH TEST EMAILS
				DECLARE @maxrecord SMALLINT  = (select top 1 ID FROM TBL_Scrub_Exclusion_Records ORDER BY ID DESC)
					WHILE @maxrecord > 0
							BEGIN
								DECLARE @EMAIL VARCHAR(25) = (SELECT Email FROM TBL_Scrub_Exclusion_Records WHERE ID = @maxrecord)
								DELETE TBL_DOCS_DISCLOSURE_CURRENT_MONTH WHERE EMAIL LIKE @EMAIL
								SET @maxrecord = @maxrecord - 1
	
							END
	
				DECLARE @TEST_TO_DELETE VARCHAR(20) = (SELECT Borrower FROM TBL_Scrub_Exclusion_Records WHERE Product_number = 7)
				DELETE APP
				FROM TBL_DOCS_DISCLOSURE_CURRENT_MONTH APP
				WHERE APP.MISC LIKE  @TEST_TO_DELETE

	            UPDATE T
				SET T.SubmitType = SUBSTRING(T.MISC,LOOK.position_start,LOOK.position_lenght)
				FROM TBL_DOCS_DISCLOSURE_CURRENT_MONTH T
				INNER JOIN [dbo].[TBL_Parse_Misc_LOOK_UP] LOOK ON LOOK.Uniquevendorid = T.UniqueVendorID
				AND LOOK.Product_number = 7 AND LOOK.Column_Name_Group = 3
				AND LOOK.To_Enter_Value is NULL

				UPDATE T
				SET T.SubmitType = SUBSTRING(T.MISC,LOOK.position_start,LOOK.position_lenght)
				FROM TBL_DOCS_DISCLOSURE_CURRENT_MONTH T
				INNER JOIN [dbo].[TBL_Parse_Misc_LOOK_UP] LOOK ON LOOK.Uniquevendorid = T.UniqueVendorID
				AND LOOK.position_Value = SUBSTRING(T.MISC,LOOK.position_start,LOOK.position_lenght)
				AND LOOK.Product_number = 7 AND LOOK.Column_Name_Group = 3
				AND LOOK.To_Enter_Value is NOT NULL

				UPDATE T
				SET T.Loanprod = SUBSTRING(T.MISC,LOOK.position_start,LOOK.position_lenght)
				FROM TBL_DOCS_DISCLOSURE_CURRENT_MONTH T
				INNER JOIN [dbo].[TBL_Parse_Misc_LOOK_UP] LOOK ON LOOK.Uniquevendorid = T.UniqueVendorID
				AND LOOK.Product_number = 7 AND LOOK.Column_Name_Group = 1
				
				UPDATE T
				SET T.Loanprog = SUBSTRING(T.MISC,LOOK.position_start,LOOK.position_lenght)
				FROM TBL_DOCS_DISCLOSURE_CURRENT_MONTH T
				INNER JOIN [dbo].[TBL_Parse_Misc_LOOK_UP] LOOK ON LOOK.Uniquevendorid = T.UniqueVendorID
				AND LOOK.Product_number = 7 AND LOOK.Column_Name_Group = 2

				DECLARE @Scrub_Column_Name VARCHAR(15) = (SELECT Scrub_Column_Name   FROM TBL_Parse_Misc_LOOK_UP WHERE Column_Name_Group = 10 AND Product_number = 7)
				DECLARE @position_Value    VARCHAR(50) = (SELECT position_Value      FROM TBL_Parse_Misc_LOOK_UP WHERE Column_Name_Group = 10 AND Product_number = 7)
			   
				;WITH GROUP_VENDORS_PAPI AS (
												SELECT DISTINCT T.UniqueVendorID 
												FROM TBL_DOCS_DISCLOSURE_CURRENT_MONTH T 
												WHERE LEFT(@Scrub_Column_Name,4) = @position_Value
											)
			   
				UPDATE T SET  submittype = left(left(SUBSTRING(misc,CHARINDEX(',',misc) + 1,LEN(misc) - CHARINDEX(',',misc)),CHARINDEX(',',SUBSTRING(misc,CHARINDEX(',',misc) + 1,LEN(misc) - CHARINDEX(',',misc))) -1),10),
								loanprod =   left(misc,CHARINDEX(',',misc)-1),
								loanprog =   left(SUBSTRING(SUBSTRING(misc,CHARINDEX(',',misc) + 1,LEN(misc) - CHARINDEX(',',misc)),CHARINDEX(',',SUBSTRING(misc,CHARINDEX(',',misc) + 1,LEN(misc) - CHARINDEX(',',misc))) +1, 100),
												CHARINDEX(',',SUBSTRING(SUBSTRING(misc,CHARINDEX(',',misc) + 1,LEN(misc) - CHARINDEX(',',misc)),CHARINDEX(',',SUBSTRING(misc,CHARINDEX(',',misc) + 1,LEN(misc) - CHARINDEX(',',misc))) +1, 100))-1),
								email    =        REVERSE(left(REVERSE(misc),CHARINDEX(',',REVERSE(misc))-1))
				FROM   TBL_DOCS_DISCLOSURE_CURRENT_MONTH	T 
						INNER JOIN GROUP_VENDORS_PAPI PAPI ON PAPI.UniqueVendorID = T.UniqueVendorID


				---UPDATES ON EMPTY COLUMNS
				UPDATE T 
				SET T.Client = LEFT(C.COMPANYName,50), T.City = LEFT(C.CITY,25), T.STATE = LEFT(C.STATE,2)
				FROM TBL_DOCS_DISCLOSURE_CURRENT_MONTH T JOIN [DataProcessing].DBO.Company c
				ON t.Clientid = c.MasterAccountingid

				UPDATE T SET AcctExec =UPPER(RTRIM(ISNULL(E.firstname,'')) + ' ' + ISNULL(E.lastname,''))
				FROM TBL_DOCS_DISCLOSURE_CURRENT_MONTH T 
				JOIN [DataProcessing].DBO.Company C ON T.ClientID = C.MasterAccountingid
				LEFT JOIN [DataProcessing].DBO.Employee E --WITH (NOLOCK)
				ON C.accountmgrid = E.username
				WHERE ISNULL(T.AcctExec,'') = '' AND ISNULL(C.accountmgrid,'') <> ''
				 
				UPDATE t SET Division = tc.Division
				FROM TBL_DOCS_DISCLOSURE_CURRENT_MONTH T
				JOIN [DataProcessing].DBO.Temp_CO_GE_EN_CLient tc
				ON t.ClientID = tc.CLientid
				WHERE  ISNULL(t.division,'') = '' 

				DECLARE @To_Enter_Value VARCHAR(15) = (SELECT To_Enter_Value FROM TBL_Parse_Misc_LOOK_UP WHERE Column_Name_Group = 11 AND Product_number = 7)
				SET     @position_Value  = (SELECT position_Value FROM TBL_Parse_Misc_LOOK_UP WHERE Column_Name_Group = 11 AND Product_number = 7)
			   
				UPDATE T SET T.Type = @To_Enter_Value
				FROM TBL_DOCS_DISCLOSURE_CURRENT_MONTH T
				WHERE T.misc like  @position_Value

				UPDATE T 
				SET T.Division = SCRUB.TO_ENTER_VALUE
				FROM TBL_DOCS_DISCLOSURE_CURRENT_MONTH T
				INNER JOIN [TBL_Parse_Misc_LOOK_UP] SCRUB
				ON SCRUB.POSITION_VALUE = SUBSTRING(T.ClientID_Log,SCRUB.[position_start],SCRUB.position_lenght)
				AND SCRUB.[Column_Name_Group] = 12
				AND SCRUB.[Product_number] = 7
			    WHERE T.Division = ''
			 
			    UPDATE T SET Division = tc.Division
				FROM TBL_DOCS_DISCLOSURE_CURRENT_MONTH T
				INNER JOIN [DataProcessing].DBO.Temp_CO_GE_EN_CLient tc
				ON T.ClientID = tc.CLientid
				WHERE  ISNULL(T.division,'') = ''

         END TRY
		BEGIN CATCH

			EXECUTE [dbo].[logerror];
			RETURN -1;
		
		END CATCH
    END

