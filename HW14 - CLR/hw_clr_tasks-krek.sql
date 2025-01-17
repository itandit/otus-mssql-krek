sp_configure 'show advanced options', 1;  
GO  
RECONFIGURE;  
GO  
sp_configure 'clr enabled', 1;  
GO  
RECONFIGURE;  
GO

CREATE ASSEMBLY CLRFunctions FROM 'C:\SQLServerCLRSortString.dll'  
GO 
CREATE FUNCTION dbo.SortString    
(    
 @name AS NVARCHAR(255)    
)     
RETURNS NVARCHAR(255)    
AS EXTERNAL NAME CLRFunctions.CLRFunctions.SortString 
GO 


CREATE TABLE testSort (data VARCHAR(255)) 
GO
INSERT INTO testSort VALUES('apple,pear,orange,banana,grape,kiwi') 
INSERT INTO testSort VALUES('pineapple,grape,banana,apple') 
INSERT INTO testSort VALUES('apricot,pear,strawberry,banana') 
INSERT INTO testSort VALUES('cherry,watermelon,orange,melon,grape') 

SELECT data, dbo.sortString(data) as sorted FROM testSort 

DROP FUNCTION dbo.SortString  
GO 
DROP ASSEMBLY CLRFunctions 
GO 
DROP TABLE testSort 
GO 