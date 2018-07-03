
----------------------------建表--------------------------
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[tr_update_WiseMis_Functions]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[tr_update_WiseMis_Functions]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[tr_delete_WiseMis_Functions]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[tr_delete_WiseMis_Functions]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[WiseMis_Functions]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[WiseMis_Functions]
GO

CREATE TABLE [dbo].[WiseMis_Functions] (
	[Name] [varchar] (50) COLLATE Chinese_PRC_CI_AS NOT NULL ,
	[Code] [text] COLLATE Chinese_PRC_CI_AS NULL ,
	[Remark] [varchar] (250) COLLATE Chinese_PRC_CI_AS NULL ,
	[CreateUser] [varchar] (50) COLLATE Chinese_PRC_CI_AS NOT NULL ,
	[CreateTime] [datetime] NOT NULL ,
	[__record__guid__] [uniqueidentifier] NOT NULL 
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[WiseMis_Functions] ADD 
	CONSTRAINT [DF__WiseMis_F__Creat__09FF42B4] DEFAULT ([dbo].[WiseMis_UserName]()) FOR [CreateUser],
	CONSTRAINT [DF__WiseMis_F__Creat__0AF366ED] DEFAULT (getdate()) FOR [CreateTime],
	CONSTRAINT [DF__WiseMis_F____rec__0CDBAF5F] DEFAULT (newid()) FOR [__record__guid__],
	CONSTRAINT [PK_WiseMis_Functions] PRIMARY KEY  CLUSTERED 
	(
		[Name]
	)  ON [PRIMARY] 
GO

GRANT  SELECT  ON [dbo].[WiseMis_Functions]  TO [public]
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

CREATE TRIGGER [tr_update_WiseMis_Functions] ON [dbo].[WiseMis_Functions] 
FOR  UPDATE
AS
if exists(select * 
	from deleted a 
		inner join inserted b on a.__record__guid__=b.__record__guid__
	where a.Name in ('__system__start__','__system__exit__','__appobject__start__','__appobject__exit__','__appform__start__','appform__exit__','__script__translate__')
		and a.Name<>b.Name
	)
begin
	raiserror('{b}不能修改内置方法名！{e}',18,1)
	rollback
end
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

CREATE TRIGGER [tr_delete_WiseMis_Functions] ON [dbo].[WiseMis_Functions] 
FOR  DELETE
AS
if exists(select * 
	from deleted
	where Name in ('__system__start__','__system__exit__','__appobject__start__','__appobject__exit__','__appform__start__','appform__exit__','__script__translate__')
	)
begin
	raiserror('{b}不能删除内置方法！{e}',18,1)
	rollback
end
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO