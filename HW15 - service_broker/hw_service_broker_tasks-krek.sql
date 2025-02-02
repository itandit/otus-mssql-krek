use master
ALTER DATABASE Pharmacy SET SINGLE_USER WITH ROLLBACK IMMEDIATE
ALTER DATABASE Pharmacy SET ENABLE_BROKER
ALTER DATABASE Pharmacy SET MULTI_USER


ALTER DATABASE Pharmacy SET TRUSTWORTHY ON;

ALTER AUTHORIZATION    
   ON DATABASE::Pharmacy TO [LAPTOP-NCM6EAT0\79262];

select name, is_broker_enabled
from sys.databases;

USE [Pharmacy]
GO
EXEC dbo.sp_changedbowner @loginame = N'LAPTOP-NCM6EAT0\79262'
GO

CREATE MESSAGE TYPE
[//VS/SB/RequestMessage]
VALIDATION=WELL_FORMED_XML;

CREATE MESSAGE TYPE
[//VS/SB/ReplyMessage]
VALIDATION=WELL_FORMED_XML; 


CREATE CONTRACT [//VS/SB/Contract]
      ([//VS/SB/RequestMessage]
         SENT BY INITIATOR,
       [//VS/SB/ReplyMessage]
         SENT BY TARGET
      );


ALTER TABLE dbo.Sales
ADD SalesConfirmedForProcessing DATETIME;

CREATE QUEUE TargetSalesQueue;

CREATE SERVICE [//VS/SB/TargetService]
       ON QUEUE TargetSalesQueue
       ([//VS/SB/Contract]);


CREATE QUEUE InitiatorSalesQueue;

CREATE SERVICE [//VS/SB/InitiatorService]
       ON QUEUE InitiatorSalesQueue
       ([//VS/SB/Contract]);

ALTER TABLE dbo.Sales
	ADD TotalCost decimal(18,2);


drop procedure if exists dbo.SendSales
go

CREATE PROCEDURE dbo.SendSales
	@id INT
AS

BEGIN
	SET NOCOUNT ON;


	DECLARE @InitDlgHandle UNIQUEIDENTIFIER; 
	DECLARE @RequestMessage NVARCHAR(4000); 
	
	BEGIN TRAN 

		SELECT @RequestMessage = (Select id 
							  from dbo.Sales as Sales
							  where id=@id
							  FOR XML AUTO, root('RequestMessage'));


	BEGIN DIALOG @InitDlgHandle
	FROM SERVICE
	[//VS/SB/InitiatorService]
	TO SERVICE
	'//VS/SB/TargetService'
	ON CONTRACT
	[//VS/SB/Contract]
	WITH ENCRYPTION=OFF; 

	SEND ON CONVERSATION @InitDlgHandle 
	MESSAGE TYPE
	[//VS/SB/RequestMessage]
	(@RequestMessage);
	COMMIT TRAN 
END
GO


drop procedure if exists dbo.GetInvoicesWithParams
go

CREATE PROCEDURE dbo.GetInvoicesWithParams
AS
BEGIN

	DECLARE @TargetDlgHandle UNIQUEIDENTIFIER, 
			@Message NVARCHAR(4000), 
			@MessageType Sysname, 
			@ReplyMessage NVARCHAR(4000),
			@ReplyMessageName Sysname, 
			@Id INT,
			@xml XML; 
	
	BEGIN TRAN; 
	RECEIVE TOP(1)
		@TargetDlgHandle = Conversation_Handle,
		@Message = Message_Body,
		@MessageType = Message_Type_Name
	FROM dbo.TargetSalesQueue; 

	SELECT @Message;

	SET @xml = CAST(@Message AS XML);
	

	SELECT @id = R.Iv.value('@OrderId','INT')
   FROM @xml.nodes('/RequestMessage/Orders') as R(Iv);

  
	 
	 IF EXISTS (SELECT * FROM dbo.Sales WHERE id = @id)
	BEGIN
		UPDATE dbo.Sales
		SET SalesConfirmedForProcessing = GETUTCDATE(), TotalCost = Quantity*price
		WHERE id = @id;
	END;



	IF @MessageType=N'//VS/SB/RequestMessage'
	BEGIN
		SET @ReplyMessage =N'<ReplyMessage> Message received</ReplyMessage>'; 
	
		SEND ON CONVERSATION @TargetDlgHandle
		MESSAGE TYPE
		[//VS/SB/ReplyMessage]
		(@ReplyMessage);
		END CONVERSATION @TargetDlgHandle;
	END 
	
	SELECT @ReplyMessage AS SentReplyMessage; 

	COMMIT TRAN;
END


go
drop procedure if exists dbo.ConfirmSales

go
CREATE PROCEDURE dbo.ConfirmSales
AS
BEGIN

	DECLARE @InitiatorReplyDlgHandle UNIQUEIDENTIFIER,
			@ReplyReceivedMessage NVARCHAR(1000) 
	
	BEGIN TRAN; 

		RECEIVE TOP(1)
			@InitiatorReplyDlgHandle=Conversation_Handle
			,@ReplyReceivedMessage=Message_Body
		FROM dbo.InitiatorSalesQueue; 
		
		END CONVERSATION @InitiatorReplyDlgHandle; 
		
		SELECT @ReplyReceivedMessage AS ReceivedRepliedMessage; 

	COMMIT TRAN; 
END



GO
ALTER QUEUE [dbo].[InitiatorSalesQueue] WITH STATUS = ON , RETENTION = OFF , POISON_MESSAGE_HANDLING (STATUS = OFF) 
	, ACTIVATION (   STATUS = ON ,
        PROCEDURE_NAME = dbo.ConfirmSales, MAX_QUEUE_READERS = 1, EXECUTE AS OWNER) ; 

GO
ALTER QUEUE [dbo].[TargetSalesQueue] WITH STATUS = ON , RETENTION = OFF , POISON_MESSAGE_HANDLING (STATUS = OFF)
	, ACTIVATION (  STATUS = ON ,
        PROCEDURE_NAME = dbo.GetInvoicesWithParams, MAX_QUEUE_READERS = 1, EXECUTE AS OWNER) ; 

GO

select * from dbo.Sales
where id = 5


EXEC dbo.SendSales
	@id = 5

SELECT CAST(message_body AS XML),*
FROM dbo.TargetSalesQueue;

SELECT CAST(message_body AS XML),*
FROM dbo.InitiatorSalesQueue;


SELECT conversation_handle, is_initiator, s.name as 'local service', 
far_service, sc.name 'contract', ce.state_desc
FROM sys.conversation_endpoints ce
LEFT JOIN sys.services s
ON ce.service_id = s.service_id
LEFT JOIN sys.service_contracts sc
ON ce.service_contract_id = sc.service_contract_id
ORDER BY conversation_handle;



EXEC dbo.GetInvoicesWithParams


EXEC dbo.ConfirmSales