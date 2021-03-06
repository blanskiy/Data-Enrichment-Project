USE [DataProcessing_Test]
GO
/****** Object:  StoredProcedure [dbo].[ScrubVendorTransData_Fraud]    Script Date: 6/27/2017 10:50:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	CZhao
-- Last modify date: 3/28/2017
-- Description:	Scrubbing Fraud transactions
-- Fraud - Clientid, Loanuid and Uniquevendorid  are used to identify an Unique loan
-- The scrubbing windown is 30 days
-- =============================================
ALTER PROCEDURE [dbo].[ScrubVendorTransData_Fraud_MOD]
AS
BEGIN
		/* ================================================================================================================
			 Author:		Bruce Lanskiy
			 Create date: 06/27/2017
			 Modified:    
			
			 Description:	Original stored procedure, business logic, had been written by Connie Zhao.
			                Code below is an attempt to simplify and adapt to new standard.
			                The purpose of this stored procedure is to load FRAUD, COMPLIANCE AND ADDL SERVICES data, 
							scrub 30 days window for unique vendorid/clientid/loanUID 
							
		                
		 
		   ================================================================================================================*/
		SET NOCOUNT ON;

		BEGIN TRY
	
		
				Declare @YYYYMM BIGINT = (select max([YYYYMM]) from [DataProcessing].[dbo].MapdownloadlogForScrubbing) ---   -1 
				DECLARE @SCRUB_WINDOW TINYINT = (SELECT TOP 1 SCRUBBING_WINDOW FROM TBL_Product_types WHERE Product_number = 4)
				
				DECLARE @bDate DATETIME
				DECLARE @eDate DATETIME
				IF  Day(getdate()) = 1
					SELECT @bDate = CONVERT(DATETIME, CONVERT(CHAR(10), DATEADD(month, -1, getdate()),101) + ' 00:00')
				ELSE
					SELECT @bDate =  CONVERT(DATETIME, CONVERT(CHAR(10), DATEADD(DD, 1 -DATEPART(DD,getdate()), getdate()),101) + ' 00:00')
				SELECT @eDate = CONVERT(DATETIME, CONVERT(CHAR(10), getdate(), 101) + ' 00:00')
		
		       
				--- GET CURRENT MONTH RECORDS
				IF OBJECT_ID('TBL_FRAUD_ADDL_COMPLIANCE_CURRENT_MONTH', 'U') IS NOT NULL DROP TABLE TBL_FRAUD_ADDL_COMPLIANCE_CURRENT_MONTH
	   
				SELECT m.id,ClientID,LenderLoanNum,Borrower,PropAddr,LoanUID,CategoryID,VendorID,m.UniqueVendorID,TransID,
						Partner,Type,AccessCode,EMail,URL,misc,Division,Platform,LogDate,
						Version,LEFT(misc,10) AS Submittype,LoanAmt,IntRate,LoanType,LoanPurp,SUBSTRING(misc,96,15) as LoanProg,
						AmortType,AppValue,DeedPos,SvrName,YYYYMM    -----ClientID, LoanUID, UniqueVendorID, m.ID, LogDate
				INTO   TBL_FRAUD_ADDL_COMPLIANCE_CURRENT_MONTH
				FROM   [DataProcessing].[dbo].MapdownloadlogForScrubbing m (NOLOCK)
						INNER JOIN TBL_Product_types PROD ON PROD.Prod_Name = m.type and PROD.Product_number IN (4,5,6)
						and m.YYYYMM = @YYYYMM 
	   
				ALTER TABLE TBL_FRAUD_ADDL_COMPLIANCE_CURRENT_MONTH
				ADD  LoanProd VARCHAR(50), Client VARCHAR(120),AcctExec varchar (101),City VARCHAR(50),State VARCHAR(2)
	   
				--- GET PREVIOUS MONTH  RECORDS
				IF OBJECT_ID('TBL_FRAUD_ADDL_COMPLIANCE_PREVIOUS_MONTH', 'U') IS NOT NULL DROP TABLE TBL_FRAUD_ADDL_COMPLIANCE_PREVIOUS_MONTH
	   
				SELECT ClientID, LoanUID, m.UniqueVendorID,m.ID,LogDate
				INTO   TBL_FRAUD_ADDL_COMPLIANCE_PREVIOUS_MONTH
				FROM   [DataProcessing].[dbo].MapdownloadlogForScrubbing m (NOLOCK)
						INNER JOIN TBL_Product_types PROD ON PROD.Prod_Name = m.type and PROD.Product_number IN (4,5,6)
						and m.YYYYMM = @YYYYMM -1 

				---- FIND AND DELETE RECORDS ALREADY BILLED WITHIN 30 DAYS IN PREVIOUS MONTH
				DELETE APP
				FROM TBL_FRAUD_ADDL_COMPLIANCE_CURRENT_MONTH APP INNER JOIN TBL_FRAUD_ADDL_COMPLIANCE_PREVIOUS_MONTH PREV 
				ON PREV.ClientID = APP.ClientID
					AND APP.UniqueVendorID = PREV.UniqueVendorID
					AND APP.LoanUID = PREV.LoanUID
					AND DATEDIFF(DAY,PREV.LogDate,APP.LogDate) <= @SCRUB_WINDOW

				DELETE APP
				FROM TBL_FRAUD_ADDL_COMPLIANCE_CURRENT_MONTH APP 
				INNER JOIN [DataProcessing].DBO.lu_Test_By_ClientID LU ON
				LU.Clientid = APP.ClientID 
			 
				DELETE APP
				FROM TBL_FRAUD_ADDL_COMPLIANCE_CURRENT_MONTH APP 
				INNER JOIN [DataProcessing].DBO.lu_Test_By_Borname LU ON
				LU.borname = APP.Borrower  
				
				DELETE APP
				FROM TBL_FRAUD_ADDL_COMPLIANCE_CURRENT_MONTH APP 
				INNER JOIN [DataProcessing].DBO.lu_test_by_company LU ON
				LU.Company = APP.ClientID 
			 
				DECLARE @MIN_CLIENTID VARCHAR(15) = (SELECT MIN(CLIENTID) FROM TBL_Scrub_Exclusion_Records WHERE Product_number = 1 )
				DECLARE @MAX_CLIENTID VARCHAR(15) = (SELECT MAX(CLIENTID) FROM TBL_Scrub_Exclusion_Records WHERE Product_number = 1 )
	       
				----- DELETE RECORDS WITH TEST EMAILS
				DECLARE @maxrecord SMALLINT  = (select top 1 ID FROM TBL_Scrub_Exclusion_Records ORDER BY ID DESC)
					WHILE @maxrecord > 0
							BEGIN
								DECLARE @EMAIL VARCHAR(25) = (SELECT Email FROM TBL_Scrub_Exclusion_Records WHERE ID = @maxrecord)
								DELETE TBL_FRAUD_ADDL_COMPLIANCE_CURRENT_MONTH WHERE EMAIL LIKE @EMAIL
								SET @maxrecord = @maxrecord - 1
	
							END

              
				UPDATE T SET T.Loanprod = LEFT(LEFT(T.misc,CHARINDEX(',',T.misc) -1 ),40),
							T.Submittype = LEFT(LTRIM(RTRIM(CASE WHEN LTRIM(RTRIM(LEFT(RIGHT(T.misc,LEN(RTRIM(T.misc)) - CHARINDEX(',',RTRIM(T.misc))),	CHARINDEX(',',RIGHT(T.misc,LEN(RTRIM(T.misc)) - CHARINDEX(',',RTRIM(T.misc))))-1))) 
							IN (SELECT RequestType FROM lu_Vendor_Scrub_Control LU INNER JOIN 
										TBL_Product_types PROD ON PROD.Prod_Name = LU.type and PROD.Product_number IN (4,5,6) 
								WHERE  IsPSDKPartner = 1 AND separator = ',') THEN 'Order'
										ELSE LEFT(RIGHT(T.misc,LEN(RTRIM(T.misc)) - CHARINDEX(',',RTRIM(T.misc))), CHARINDEX(',',RIGHT(T.misc,LEN(RTRIM(T.misc)) - CHARINDEX(',',RTRIM(T.misc))))-1) END)),10),
										T.Loanprog = LTRIM(RTRIM(LEFT(LEFT(RIGHT(T.misc,LEN(RTRIM(T.misc)) - CHARINDEX(',',T.misc) - CHARINDEX(',',RIGHT(T.misc,LEN(RTRIM(T.misc)) - CHARINDEX(',',RTRIM(T.misc))))),22),
										CHARINDEX(',',RIGHT(T.misc,LEN(RTRIM(T.misc)) - CHARINDEX(',',T.misc) - CHARINDEX(',',RIGHT(T.misc,LEN(RTRIM(T.misc)) - CHARINDEX(',',RTRIM(T.misc))))))-1)))
				FROM TBL_FRAUD_ADDL_COMPLIANCE_CURRENT_MONTH T
				WHERE T.uniquevendorid IN (SELECT LU.uniquevendorid 
											FROM lu_Vendor_Scrub_Control LU INNER JOIN 
												TBL_Product_types PROD ON PROD.Prod_Name = LU.type and PROD.Product_number IN (4,5,6) 
											WHERE  IsPSDKPartner = 1 AND separator = ',')

				UPDATE T SET T.Loanprod = LEFT(LEFT(T.misc,CHARINDEX(';',T.misc) -1 ),40),
							T.Submittype = LEFT(LTRIM(RTRIM(CASE WHEN LTRIM(RTRIM(LEFT(RIGHT(T.misc,LEN(RTRIM(T.misc)) - CHARINDEX(';',RTRIM(T.misc))),	CHARINDEX(';',RIGHT(T.misc,LEN(RTRIM(T.misc)) - CHARINDEX(';',RTRIM(T.misc))))-1))) 
											IN (SELECT RequestType 
												FROM   lu_Vendor_Scrub_Control LU INNER JOIN 
														TBL_Product_types PROD ON PROD.Prod_Name = LU.type and PROD.Product_number IN (4,5,6) 
												WHERE  IsPSDKPartner = 1 AND separator = ';') 
														THEN 'Order'
														ELSE LEFT(RIGHT(T.misc,LEN(RTRIM(T.misc)) - CHARINDEX(';',RTRIM(T.misc))), CHARINDEX(';',RIGHT(T.misc,LEN(RTRIM(T.misc)) - CHARINDEX(';',RTRIM(T.misc))))-1) END)),10),
							T.Loanprog = LEFT( LEFT(LEFT(RIGHT(T.misc,LEN(RTRIM(T.misc)) - CHARINDEX(';',T.misc) - CHARINDEX(';',RIGHT(T.misc,LEN(RTRIM(T.misc)) - CHARINDEX(';',RTRIM(T.misc))))),20),
										CHARINDEX(';',RIGHT(T.misc,LEN(RTRIM(T.misc)) - CHARINDEX(';',T.misc) - CHARINDEX(';',RIGHT(T.misc,LEN(RTRIM(T.misc)) - CHARINDEX(';',RTRIM(T.misc))))))-1) ,50)
				FROM  TBL_FRAUD_ADDL_COMPLIANCE_CURRENT_MONTH T
				WHERE T.uniquevendorid IN (SELECT LU.uniquevendorid 
										FROM   lu_Vendor_Scrub_Control LU INNER JOIN 
												TBL_Product_types PROD ON PROD.Prod_Name = LU.type and PROD.Product_number IN (4,5,6)  
										WHERE  IsPSDKPartner = 1 AND separator = ';')

				UPDATE T 
				SET T.SubmitType = SCRUB.TO_ENTER_VALUE
				FROM TBL_FRAUD_ADDL_COMPLIANCE_CURRENT_MONTH T
					INNER JOIN [TBL_Parse_Misc_LOOK_UP] SCRUB
					ON SCRUB.UNIQUEVENDORID = T.UniqueVendorID
					AND SCRUB.POSITION_VALUE = SUBSTRING(T.misc,SCRUB.[position_start],SCRUB.position_lenght)
					AND SCRUB.[Column_Name_Group] = 3
					AND SCRUB.[Product_number] = 4
              
				UPDATE T 
				SET T.[LoanProd] = SUBSTRING(T.misc,SCRUB.[position_start],SCRUB.position_lenght)
				FROM TBL_FRAUD_ADDL_COMPLIANCE_CURRENT_MONTH T
					INNER JOIN [TBL_Parse_Misc_LOOK_UP] SCRUB
					ON SCRUB.UNIQUEVENDORID = T.UniqueVendorID
					AND SCRUB.[Column_Name_Group] = 1
					AND SCRUB.[Product_number] = 4

				UPDATE T 
				SET T.[LoanProg] = SUBSTRING(T.misc,SCRUB.[position_start],SCRUB.position_lenght)
				FROM TBL_FRAUD_ADDL_COMPLIANCE_CURRENT_MONTH T
					INNER JOIN [TBL_Parse_Misc_LOOK_UP] SCRUB
					ON SCRUB.UNIQUEVENDORID = T.UniqueVendorID
					AND SCRUB.[Column_Name_Group] = 2
					AND SCRUB.[Product_number] = 4

				---UPDATES ON EMPTY COLUMNS
				UPDATE T 
				SET T.Client = LEFT(C.COMPANYName,50), T.City = LEFT(C.CITY,25), T.STATE = LEFT(C.STATE,2)
				FROM TBL_FRAUD_ADDL_COMPLIANCE_CURRENT_MONTH T JOIN [DataProcessing].DBO.Company c
				ON t.Clientid = c.MasterAccountingid

				UPDATE T SET AcctExec =UPPER(RTRIM(ISNULL(E.firstname,'')) + ' ' + ISNULL(E.lastname,''))
				FROM TBL_FRAUD_ADDL_COMPLIANCE_CURRENT_MONTH T 
				JOIN [DataProcessing].DBO.Company C ON T.ClientID = C.MasterAccountingid
				LEFT JOIN [DataProcessing].DBO.Employee E --WITH (NOLOCK)
				ON C.accountmgrid = E.username
				WHERE ISNULL(T.AcctExec,'') = '' AND ISNULL(C.accountmgrid,'') <> ''

				-- SET up division 
				UPDATE t SET Division = tc.Division
				FROM TBL_FRAUD_ADDL_COMPLIANCE_CURRENT_MONTH t
				JOIN [DataProcessing].DBO.Temp_CO_GE_EN_CLient tc
				ON t.ClientID = tc.CLientid
				WHERE  ISNULL(t.division,'') = '' 



		END TRY
			BEGIN CATCH

				EXECUTE [dbo].[logerror];
				RETURN -1;
		
			END CATCH
  END


	