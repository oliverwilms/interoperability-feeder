Class User.Config
{

ClassMethod ImportSDS() As %Status
{
	Set tSC = $$$OK
	If ##class(%File).Exists("/opt/sds/sds.xml") {
		Set tSC = ##class(Ens.Config.DefaultSettings).%Import("/opt/sds/sds.xml")
		If $$$ISERR(tSC) { Quit tSC }
	}
	If ##class(%File).Exists("/opt/sds/SDS_ENV.xml") {
		Set tSC = ##class(Ens.Config.DefaultSettings).%Import("/opt/sds/SDS_ENV.xml")
		If $$$ISERR(tSC) { Quit tSC }
	}
  If ##class(%File).Exists("/path/feeder/opt/sds/sds.xml") {
    Set tSC = ##class(Ens.Config.DefaultSettings).%Import("/path/feeder/opt/sds/sds.xml")
		If $$$ISERR(tSC) { Quit tSC }
	}
	$$$ThrowOnError(tSC)
	Do ##class(%SYS.System).WriteToConsoleLog("User.Config - ImportSDS",0,0)
	Quit tSC
}

}
