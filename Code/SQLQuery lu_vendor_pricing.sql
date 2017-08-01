select  * from [EC1VDBMIS01\MISDB01].[DataProcessing].dbo.lu_Vendor_Pricing where type = 'Title' and year(updateddate) > 2015 and product is not NULL

select  * from [EC1VDBMIS01\MISDB01].[DataProcessing].dbo.lu_Vendor_Pricing where type = 'Title' and year(updateddate) > 2015 and product is NULL

select distinct vendorid, clientid,product  from [EC1VDBMIS01\MISDB01].[DataProcessing].dbo.lu_Vendor_Pricing where type = 'Title'


select * from [EC1VDBMIS01\MISDB01].[DataProcessing].dbo.lu_Vendor_Pricing where type = 'FLOOD'  ----and year(updateddate) > 2015

select distinct vendorid,clientid from temp_alltransdata_60 where type = 'FLOOD'

select vendorid,vendor from [EC1VDBMIS01\MISDB01].[DataProcessing].dbo.lu_Vendor_Pricing where type = 'FLOOD'

select * from [EC1VDBMIS01\MISDB01].[DataProcessing].dbo.lu_Vendor_Pricing where type = 'ELEC VERF'

select * from [EC1VDBMIS01\MISDB01].[DataProcessing].dbo.lu_Vendor_Pricing where type like 'ELE%'

select vendorid,vendor,product from [EC1VDBMIS01\MISDB01].[DataProcessing].dbo.lu_Vendor_Pricing where type = 'ELEC VERF'

select * from [EC1VDBMIS01\MISDB01].[DataProcessing].dbo.lu_Vendor_Pricing where type = 'Documents'

select vendorid,vendor,product from [EC1VDBMIS01\MISDB01].[DataProcessing].dbo.lu_Vendor_Pricing where type = 'Documents'

select * from [EC1VDBMIS01\MISDB01].[DataProcessing].dbo.lu_Vendor_Pricing where type like 'Dis%'

select vendorid,vendor,product from [EC1VDBMIS01\MISDB01].[DataProcessing].dbo.lu_Vendor_Pricing where type like 'Dis%'

select * from [EC1VDBMIS01\MISDB01].[DataProcessing].dbo.lu_Vendor_Pricing where type like 'credit%'

select distinct type from [EC1VDBMIS01\MISDB01].[DataProcessing].dbo.lu_Vendor_Pricing ---18

select distinct type from temp_alltransdata_60 --- 24

select * from temp_alltransdata_60 where type = 'GSE' and clientid='275941'

select * from [EC1VDBMIS01\MISDB01].[DataProcessing].dbo.lu_Vendor_Pricing where type like 'G%'
select vendorid,vendor,product from [EC1VDBMIS01\MISDB01].[DataProcessing].dbo.lu_Vendor_Pricing where type like 'G%'

select * from [EC1VDBMIS01\MISDB01].[DataProcessing].dbo.lu_Vendor_Pricing where type like 'MORT%'

select vendorid,vendor,product from [EC1VDBMIS01\MISDB01].[DataProcessing].dbo.lu_Vendor_Pricing where type like 'MORT%'

select distinct type from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17]
except
select distinct type from [EC1VDBMIS01\MISDB01].[DataProcessing].dbo.lu_Vendor_Pricing
/*
APPR REFER
AU
BACKEND
COMPLIANCE
CREDIT
EDM
HMDA
MULTI
PRICING
*/
select * from [EC1VDBMIS01\MISDB01].[DataProcessing].dbo.lu_Vendor_Pricing where type like 'title'

select count(distinct clientid) from [EC1VDBMIS01\MISDB01].[DataProcessing].dbo.lu_Vendor_Pricing where type like 'title'


select distinct A.partner,A.vendorid,Lu.clientid,Lu.Product from [ArchiveData].[dbo].[AllTrans_For_Reports_2016_17] a
   left outer join [EC1VDBMIS01\MISDB01].[DataProcessing].dbo.lu_Vendor_Pricing lu on lu.Vendorid = A.VendorID
   where A.type = 'Title'



--- for all products except title I have to look on fixed price. For Title I have to look at Purchase and Refi columns

/*

EXEC ScrubVendorTransData_Title -- updated on 5/31/2013
EXEC ScrubVendorTransData_FannieMae
EXEC ScrubVendorTransData_Mavent
EXEC ScrubVendorTransData_Appr	-- added 3/27/2012
EXEC ScrubVendorTransData_Fraud	-- added 3/27/2012
EXEC ScrubVendorTransData_Fraud_900038	-- added 5/7/2012 per Jaime mas - not scrubbing see email
EXEC ScrubVendorTransData_OncePerLoan	-- added 10/29/2012 for SharperLending 4506 
EXEC ScrubVendorTransData_MortIns	-- added 5/29/2013
EXEC ScrubVendorTransData_ElecVerf	
EXEC ScrubVendorTransData_Docs
EXEC ScrubVendorTransData_Flood -- added on 3/21/2014 see email sent to Fudong
EXEC ScrubVendorTransData_HMDA -- added on 9/23/2014 see email sent to Fudong
EXEC ScrubVendorTransData_EDM -- added on 9/26/2014 see email sent to Fudong
EXEC ScrubVendorTransData_TaxService
EXEC ScrubVendorTransData_GSE_LP 
*/

select * from TBL_VendorID_PartnerCount where Partners_perVendorid > 1