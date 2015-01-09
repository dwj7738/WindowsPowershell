-- Copyright (c) Microsoft Corporation.  All rights reserved.

SET NOCOUNT ON

declare @localized_string_AddWriterRole_Failed nvarchar(256)
set @localized_string_AddWriterRole_Failed = N'Failed adding the ''tracking_writer'' role'

DECLARE @ret int, @Error int
IF NOT EXISTS( SELECT 1 FROM [dbo].[sysusers] WHERE name=N'tracking_writer' and issqlrole=1 )
 BEGIN

	EXEC @ret = sp_addrole N'tracking_writer'

	SELECT @Error = @@ERROR

	IF @ret <> 0 or @Error <> 0
		RAISERROR( @localized_string_AddWriterRole_Failed, 16, -1 )
 END
GO

declare @localized_string_AddReaderRole_Failed nvarchar(256)
set @localized_string_AddReaderRole_Failed = N'Failed adding the ''tracking_reader'' role'

DECLARE @ret int, @Error int
IF NOT EXISTS( SELECT 1 FROM [dbo].[sysusers] WHERE name=N'tracking_reader' and issqlrole=1 )
 BEGIN

	EXEC @ret = sp_addrole N'tracking_reader'

	SELECT @Error = @@ERROR

	IF @ret <> 0 or @Error <> 0
		RAISERROR( @localized_string_AddReaderRole_Failed, 16, -1 )
 END
GO

declare @localized_string_AddProfileReaderWriterRole_Failed nvarchar(256)
set @localized_string_AddProfileReaderWriterRole_Failed = N'Failed adding the ''tracking_profilereaderwrit