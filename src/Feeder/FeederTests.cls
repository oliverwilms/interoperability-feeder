/// Converted from Feeder.UnitTests
Class Feeder.FeederTests
{

ClassMethod Setup(pQuantity1 As %String = 1, pQuantity2 As %String = 1) As %Status
{
	Do ##class(Feeder.Util).DebugTEST("Feeder.FeederTests - Setup")
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
	Set ^myUnitTestControl("Quantity1") = pQuantity1
	Set ^myUnitTestControl("Quantity2") = pQuantity2
	Set ^myUnitTestControl("Files") = $Get(pFiles,pQuantity1)
	Set ^myUnitTestControl("Production") = "Feeder.FeederProduction"
	Set tCodeClassName = $Get(^myFeeder("Config","CodeClassName"),"Feeder.UnitTestHelper")
	Set tCodeClassMethod = $Get(^myFeeder("Config","CodeClassMethod"),"ACopy")
	Set tFileType = $Get(^myUnitTestControl("Type"),"*")
	//Set tSC = $ClassMethod(tCodeClassName,tCodeClassMethod,pFiles,tFileType)
	Set tSC = $ClassMethod(tCodeClassName,tCodeClassMethod,pQuantity1,pQuantity2)
	Do ##class(Feeder.Util).DebugTEST("Feeder.FeederTests - Setup is done")
	Quit tSC
}

ClassMethod LBTest(pQuantity1 As %String = 1, pQuantity2 As %String = 1) As %Status
{
	Do ##class(Feeder.Util).DebugTEST("Feeder.FeederTests - LBTest")
	Set tSC = ##class(Feeder.Ensemble).StopProduction("Feeder.FeederProduction")
	Set ^myFeeder("Config","CodeClassName") = "dc.iris.testdata"
	Set ^myFeeder("Config","CodeClassMethod") = "order"
	Set tSC = ..Setup(pQuantity1,pQuantity2)
	Set ^myUnitTestControl("Server") = $Get(^myFeeder("Config","LoadBalancer"))
	Set ^myUnitTestControl("URL") = $Get(^myFeeder("Config","CSPOpURL"))
	Set ^myUnitTestControl("whichTest") = "LBTest"
	Set tSC = ##class(Feeder.Ensemble).StartProduction("Feeder.FeederProduction")
	Merge ^myFeeder("UnitTestControl") = ^myUnitTestControl
	Kill ^myUnitTestControl
	Do ##class(Feeder.Util).DebugTEST("Feeder.FeederTests - LBTest is done")
	//Do ##class(Feeder.TestReport).MbkReport()
	Quit $$$OK
}

}
