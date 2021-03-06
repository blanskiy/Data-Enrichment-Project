USE [DataProcessing_Test]
GO
/****** Object:  StoredProcedure [dbo].[ScrubVendorTransData_HMDA]    Script Date: 7/6/2017 1:12:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ScrubVendorTransData_HMDA_MOD] -- created on 9/27/14 30 days scrubbing
  AS
        BEGIN
		/* ================================================================================================================
			 Author:		Bruce Lanskiy
			 Create date: 06/27/2017
			 Modified:    
			
			 Description:	Original stored procedure, business logic, had been written by Connie Zhao.
			                Code below is an attempt to simplify and adapt to new standard.
			                The purpose of this stored procedure is to load HMDA data, 
							scrub 30 days window for unique vendorid/clientid/loanUID 
							
		                
		 
		   ================================================================================================================*/
		SET NOCOUNT ON;

		BEGIN TRY
		        
			    Declare @YYYYMM BIGINT = (select max([YYYYMM]) from [DataProcessing].[dbo].MapdownloadlogForScrubbing) ---   -1 
				DECLARE @SCRUB_WINDOW TINYINT = (SELECT TOP 1 SCRUBBING_WINDOW FROM TBL_Product_types WHERE Product_number = 9)
				
				DECLARE @bDate DATETIME
				DECLARE @eDate DATETIME
				IF  Day(getdate()) = 1
					SELECT @bDate = CONVERT(DATETIME, CONVERT(CHAR(10), DATEADD(month, -1, getdate()),101) + ' 00:00')
				ELSE
					SELECT @bDate =  CONVERT(DATETIME, CONVERT(CHAR(10), DATEADD(DD, 1 -DATEPART(DD,getdate()), getdate()),101) + ' 00:00')
				SELECT @eDate = CONVERT(DATETIME, CONVERT(CHAR(10), getdate(), 101) + ' 00:00')
		 
		       
				--- GET CURRENT MONTH RECORDS
				IF OBJECT_ID('TBL_HMDA_CURRENT_MONTH', 'U') IS NOT NULL DROP TABLE TBL_HMDA_CURRENT_MONTH
	   
				SELECT m.id,ClientID,LenderLoanNum,Borrower,PropAddr,LoanUID,CategoryID,VendorID,m.UniqueVendorID,TransID,
						Partner,Type,AccessCode,EMail,URL,misc,Division,Platform,LogDate,
						Version,LEFT(misc,1) AS Submittype,LoanAmt,IntRate,LoanType,SUBSTRING(misc,32,50) as LoanProg,
						AmortType,AppValue,DeedPos,SvrName,YYYYMM    -----ClientID, LoanUID, UniqueVendorID, m.ID, LogDate
				INTO   TBL_HMDA_CURRENT_MONTH
				FROM   [DataProcessing].[dbo].MapdownloadlogForScrubbing m (NOLOCK)
						INNER JOIN TBL_Product_types PROD ON PROD.Prod_Name = m.type and PROD.Product_number IN (4,5,6)
						and m.YYYYMM = @YYYYMM 
	   
				ALTER TABLE TBL_HMDA_CURRENT_MONTH
				ADD  LoanProd VARCHAR(50), Client VARCHAR(120),AcctExec varchar (101),City VARCHAR(50),State VARCHAR(2)
	   
				--- GET PREVIOUS MONTH  RECORDS
				IF OBJECT_ID('TBL_HMDA_PREVIOUS_MONTH', 'U') IS NOT NULL DROP TABLE TBL_HMDA_PREVIOUS_MONTH
	   
				SELECT ClientID, LoanUID, m.UniqueVendorID,m.ID,LogDate
				INTO   TBL_HMDA_PREVIOUS_MONTH
				FROM   [DataProcessing].[dbo].MapdownloadlogForScrubbing m (NOLOCK)
					   INNER JOIN TBL_Product_types PROD ON PROD.Prod_Name = m.type and PROD.Product_number =9
					   AND m.YYYYMM = @YYYYMM -1 

				---- FIND AND DELETE RECORDS ALREADY BILLED WITHIN 30 DAYS IN PREVIOUS MONTH
				DELETE APP
				FROM   TBL_HMDA_CURRENT_MONTH APP INNER JOIN TBL_HMDA_PREVIOUS_MONTH PREV 
				ON     PREV.ClientID = APP.ClientID
					   AND APP.UniqueVendorID = PREV.UniqueVendorID
					   AND APP.LoanUID = PREV.LoanUID
					   AND DATEDIFF(DAY,PREV.LogDate,APP.LogDate) <= @SCRUB_WINDOW

                UPDATE T 
				SET    T.SubmitType = SCRUB.TO_ENTER_VALUE
				FROM   TBL_HMDA_CURRENT_MONTH T
					   INNER JOIN [TBL_Parse_Misc_LOOK_UP] SCRUB
					   ON SCRUB.position_Value = T.SubmitType
					   AND SCRUB.[Column_Name_Group] = 3
					   AND SCRUB.[Product_number] = 9

                UPDATE T
				SET    T.LoanPurp = SCRUB.To_enter_value
				FROM   TBL_HMDA_CURRENT_MONTH T
					   INNER JOIN [dbo].[TBL_SCRUB_LOOOK_UP_STANDARDIZATION] SCRUB
					   ON SCRUB.Column_Value = T.LoanPurp
					   AND SCRUB.Product_number = 9
        


		        DECLARE @MIN_CLIENTID VARCHAR(15) = (SELECT MIN(CLIENTID) FROM TBL_Scrub_Exclusion_Records WHERE Product_number = 1 )
	            DECLARE @MAX_CLIENTID VARCHAR(15) = (SELECT MAX(CLIENTID) FROM TBL_Scrub_Exclusion_Records WHERE Product_number = 1 )
	       
		        DELETE 
				TBL_HMDA_CURRENT_MONTH
				WHERE  ISNULL(ClientID,'')  IN   (SELECT Company  FROM [DataProcessing].DBO.lu_test_by_company)
					OR ISNULL(Borrower,'')  IN   (SELECT  Borname FROM [DataProcessing].DBO.lu_Test_By_Borname)OR ISNULL(Clientid,'')  IN (SELECT Clientid FROM [DataProcessing].DBO.lu_Test_By_ClientID)
					OR ISNULL(AccessCode,'') IN  (SELECT Access_Code FROM [DataProcessing].DBO.lu_Test_By_Access_Code)
					OR (ISNULL(clientid,'')  BETWEEN @MIN_CLIENTID AND @MAX_CLIENTID AND LEN(ISNULL(ClientID,'')) = 8)
					OR ISNULL(Borrower,'')  = ''
	        
				----- DELETE RECORDS WITH TEST EMAILS
				DECLARE @maxrecord INT  = (select top 1 ID FROM TBL_Scrub_Exclusion_Records ORDER BY ID DESC)
				WHILE @maxrecord > 0
					 BEGIN
						   DECLARE @EMAIL VARCHAR(25) = (SELECT Email FROM TBL_Scrub_Exclusion_Records WHERE ID = @maxrecord)
						   DELETE TBL_HMDA_CURRENT_MONTH WHERE EMAIL LIKE @EMAIL
						   SET @maxrecord = @maxrecord - 1
	
					 END

	           ---UPDATES ON EMPTY COLUMNS
			   UPDATE T 
			   SET T.Client = LEFT(C.COMPANYName,50), T.City = LEFT(C.CITY,25), T.STATE = LEFT(C.STATE,2)
			   FROM TBL_HMDA_CURRENT_MONTH T JOIN [DataProcessing].DBO.Company c
			   ON t.Clientid = c.MasterAccountingid

			   UPDATE T SET AcctExec =UPPER(RTRIM(ISNULL(E.firstname,'')) + ' ' + ISNULL(E.lastname,''))
			   FROM TBL_HMDA_CURRENT_MONTH T 
			   JOIN [DataProcessing].DBO.Company C ON T.ClientID = C.MasterAccountingid
			   LEFT JOIN [DataProcessing].DBO.Employee E --WITH (NOLOCK)
			   ON C.accountmgrid = E.username
			   WHERE ISNULL(T.AcctExec,'') = '' AND ISNULL(C.accountmgrid,'') <> ''

			   -- SET up division 
			   UPDATE T SET Division = tc.Division
			   FROM TBL_HMDA_CURRENT_MONTH T
			   JOIN [DataProcessing].DBO.Temp_CO_GE_EN_CLient tc
			   ON T.ClientID = tc.CLientid
			   WHERE  ISNULL(t.division,'') = ''

        END TRY
				BEGIN CATCH

					EXECUTE [dbo].[logerror];
					RETURN -1;
		
				END CATCH
 END
		