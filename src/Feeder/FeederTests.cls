/// Converted from Feeder.UnitTests
Class Feeder.FeederTests
{

ClassMethod Setup(pFiles As %String = 1) As %Status
{
	Do ##class(Feeder.Util).DebugTEST("Feeder.FeederTests - Setup - pFiles = "_pFiles)
	Set pDateFormat = 3
	Set pDateTimeBase = $ZDateTime($NOW(),pDateFormat,1,3)
	Set ^myUnitTestControl("Setup") = pDateTimeBase
	Set tSC = $$$OK
	/*
	Set myNamespace = $Namespace
	Set $Namespace = "%SYS"
	Set ^SYS("Security","CSP","AllowPrefix","/csp/feeder/","%UnitTest.") = 1
	//Set ^SYS("Security","CSP","AllowPrefix","/csp/healthshare/feeder/","%UnitTest.") = 1
	Set $Namespace = myNamespace
	*/
	Set ^myUnitTestControl("Files") = pFiles
	Set ^myUnitTestControl("Production") = "Feeder.FeederProduction"
	Set tCodeClassName = $Get(^myFeeder("Config","CodeClassName"),"Feeder.UnitTestHelper")
	Set tCodeClassMethod = $Get(^myFeeder("Config","CodeClassMethod"),"ACopy")
	Set tFileType = $Get(^myUnitTestControl("Type"),"*")
	Set tSC = $ClassMethod(tCodeClassName,tCodeClassMethod,pFiles,tFileType)
	Do ##class(Feeder.Util).DebugTEST("Feeder.FeederTests - Setup is done")
	Quit tSC
}

ClassMethod LBTest(
	pFiles As %String = 1,
	pPort As %String = "") As %Status
{
	Do ##class(Feeder.Util).DebugTEST("Feeder.FeederTests - LBTest")
	Set tSC = ##class(Feeder.Ensemble).StopProduction("Feeder.FeederProduction")
	Set ^myFeeder("Config","CodeClassName") = "User.DLATest"
	Set ^myFeeder("Config","CodeClassMethod") = "CopyFiles"
	Set tSC = ..Setup(pFiles)
	Set ^myUnitTestControl("Server") = ##class(Feeder.Util).whichLoadBalancer()
	Set ^myUnitTestControl("URL") = ##class(Feeder.Util).whichURL()
	Set ^myUnitTestControl("Port") = pPort
	Set ^myUnitTestControl("Files") = pFiles
	Set ^myUnitTestControl("whichTest") = "LBTest"
	Set tSC = ##class(Feeder.Ensemble).StartProduction("Feeder.FeederProduction")
	Merge ^myFeeder("UnitTestControl") = ^myUnitTestControl
	Kill ^myUnitTestControl
	Do ##class(Feeder.Util).DebugTEST("Feeder.FeederTests - LBTest is done")
	//Do ##class(Feeder.TestReport).MbkReport()
	Quit $$$OK
}

}
