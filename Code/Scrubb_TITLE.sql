USE [DataProcessing_Test]
GO
/****** Object:  StoredProcedure [dbo].[ScrubVendorTransData_Title]    Script Date: 6/23/2017 10:29:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ScrubVendorTransData_Title_MOD] 
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
	
		
				Declare @YYYYMM BIGINT = (select max([YYYYMM]) from [DataProcessing].[dbo].MapdownloadlogForScrubbing) ---   -1 
				DECLARE @ORDER VARCHAR(10) = 'Order'
				DECLARE @SCRUB_WINDOW TINYINT = (SELECT TOP 1 SCRUBBING_WINDOW FROM TBL_Product_types WHERE Product_number = 2)
				DECLARE @YYYYMM_3_MONTHS_BACK BIGINT = @YYYYMM - 3
		
				DECLARE @bDate DATETIME
				DECLARE @eDate DATETIME
				IF  Day(getdate()) = 1
					SELECT @bDate = CONVERT(DATETIME, CONVERT(CHAR(10), DATEADD(month, -1, getdate()),101) + ' 00:00')
				ELSE
					SELECT @bDate =  CONVERT(DATETIME, CONVERT(CHAR(10), DATEADD(DD, 1 -DATEPART(DD,getdate()), getdate()),101) + ' 00:00')
				SELECT @eDate = CONVERT(DATETIME, CONVERT(CHAR(10), getdate(), 101) + ' 00:00')
		
		       
			   --- GET CURRENT MONTH TITLE
			   IF OBJECT_ID('TBL_TITLE_CURRENT_MONTH', 'U') IS NOT NULL DROP TABLE TBL_TITLE_CURRENT_MONTH
	   
			   SELECT m.id,ClientID,LenderLoanNum,Borrower,PropAddr,LoanUID,CategoryID,VendorID,m.UniqueVendorID,TransID,
					  Partner,Type,AccessCode,EMail,URL,misc,Division,Platform,LogDate,
					  Version,LoanAmt,IntRate,LoanType,LoanPurp,AmortType,AppValue,DeedPos,SvrName,YYYYMM    -----ClientID, LoanUID, UniqueVendorID, m.ID, LogDate
			   INTO   TBL_TITLE_CURRENT_MONTH
			   FROM   [DataProcessing].[dbo].MapdownloadlogForScrubbing m (NOLOCK)
					  INNER JOIN TBL_Product_types PROD ON PROD.Prod_Name = m.type and PROD.Product_number = 2
					  and m.YYYYMM = @YYYYMM 
	   
			   ALTER TABLE TBL_TITLE_CURRENT_MONTH
			   ADD  SubmitType VARCHAR(30),LoanProd VARCHAR(50),LoanProg VARCHAR(50), Client VARCHAR(120),AcctExec varchar (101),City VARCHAR(50),State VARCHAR(2)
	   
			   --- GET PREVIOUS 3 MONTHS TITLE RECORDS
			   IF OBJECT_ID('TBL_TITLE_PREVIOUS_3MONTHS', 'U') IS NOT NULL DROP TABLE TBL_TITLE_PREVIOUS_3MONTHS
	   
			   SELECT ClientID, LoanUID, m.UniqueVendorID,m.ID,LogDate
			   INTO   TBL_TITLE_PREVIOUS_3MONTHS
			   FROM   [DataProcessing].[dbo].MapdownloadlogForScrubbing m (NOLOCK)
					  INNER JOIN TBL_Product_types PROD ON PROD.Prod_Name = m.type and PROD.Product_number = 2
					  AND m.YYYYMM < @YYYYMM AND m.YYYYMM >= @YYYYMM_3_MONTHS_BACK 

               
	           ---- FIND AND DELETE RECORDS ALREADY BILLED WITHIN 90 DAYS IN PREVIOUS MONTH
			   DELETE APP
			   FROM TBL_TITLE_CURRENT_MONTH APP INNER JOIN TBL_TITLE_PREVIOUS_3MONTHS PREV 
			   ON PREV.ClientID = APP.ClientID
			   AND APP.UniqueVendorID = PREV.UniqueVendorID
			   AND APP.LoanUID = PREV.LoanUID
			   AND DATEDIFF(DAY,PREV.LogDate,APP.LogDate) <= @SCRUB_WINDOW

               DELETE APP
			   FROM TBL_TITLE_CURRENT_MONTH APP INNER JOIN [DataProcessing].[dbo].OEM_VendorTransData VEND
			   ON  APP.VendorID = VEND.VendorID
			   WHERE _sent_ts >= @bDate AND  _sent_ts <  @eDate
			   
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
				       DECLARE @EMAIL VARCHAR(25) = (SELECT Email FROM TBL_Scrub_Test_Email WHERE ID = @maxrecord)
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
	  
	  
	  
	   END TRY
	BEGIN CATCH

		EXECUTE [dbo].[logerror];
		RETURN -1;
		
	END CATCH
  END


