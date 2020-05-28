/*
Note: 
	Port for Principal & Mirror: "5022"
	
By:
	Ghufran Khan
	FB: https://www.facebook.com/GhufranKhan89
	Youtube: https://bit.ly/36DQ87d
	GitHub: https://github.com/inditechie?tab=repositories
*/
 
-- First Step
-- Run on Primary/Principal node :
 
CREATE ENDPOINT [Mirroring]
    AS TCP (LISTENER_PORT = 5022)
    FOR DATA_MIRRORING (
	    ROLE = ALL,
	    AUTHENTICATION = WINDOWS NEGOTIATE,
		ENCRYPTION = REQUIRED ALGORITHM AES
		);
 
ALTER ENDPOINT [Mirroring] STATE = STARTED;
GO
 
CREATE LOGIN [<Domain\SecondaryNode>$] FROM WINDOWS -- Example: [CONTOSO\N2$]
GO
 
GRANT CONNECT ON ENDPOINT::[Mirroring] TO [<Domain\SecondaryNode>$]
GO
 
-- Second Step
-- Run on Secondary/Mirror node :
 
 CREATE ENDPOINT [Mirroring]
    AS TCP (LISTENER_PORT = 5022)
    FOR DATA_MIRRORING (
	    ROLE = ALL,
	    AUTHENTICATION = WINDOWS NEGOTIATE,
		ENCRYPTION = REQUIRED ALGORITHM AES
		);
 
ALTER ENDPOINT [Mirroring] STATE = STARTED;
GO
 
CREATE LOGIN [<Domain\PrimaryNode>$] FROM WINDOWS -- Example: [CONTOSO\N1$]
GO
 
GRANT CONNECT ON ENDPOINT::[Mirroring] TO [<Domain\PrimaryNode>$]
GO
 
-- Third Step :
/*
Take Full & Log backup of the Mirroring database from Primary/Principal node
 
Restore the Full & Log backup with "NORECOVERY" option on the Secondary/Mirror node
*/
 
-- Fourth Step:
-- Run on Secondary/Mirror node :
USE [master]
GO
 
ALTER DATABASE [<Database Name>] SET PARTNER = 'TCP://<IP of Primary/Principal node>:5022'
GO
 
-- Fifth Step
-- Run on Primary/Principal node :
USE [master]
GO
 
ALTER DATABASE [<Database Name>] SET PARTNER = 'TCP://<IP of Secondary/Mirror node>:5022'
GO
 
ALTER DATABASE [<Database Name>] SET SAFETY FULL -- Synchronous Mode
GO
