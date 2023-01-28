Class Feeder.Util
{

ClassMethod DebugMerge(strMessage As %String = "", ByRef pArray) As %Status
{
	Merge ^TESTunit($I(^TESTunit)) = pArray
	Set tValue = ""
	If $Get(pArray) '= "" Set tValue = " = "_pArray
	Set ^TESTunit(^TESTunit) = $ZDateTime($NOW(),8,1,3)_" : "_$JOB_" : "_strMessage_tValue
	Quit $$$OK
}

ClassMethod DebugTEST(strMessage As %String = "") As %Status
{
	Set ^TESTunit($I(^TESTunit)) = $ZDateTime($NOW(),8,1,3)_" : "_$JOB_" : "_strMessage
	Quit $$$OK
}

ClassMethod StatusToText(pStatus As %Status) As %String
{
	Set tReturn = $System.Status.GetOneErrorText(pStatus)
	Quit tReturn
}

ClassMethod DebugStatus(pStatus As %Status) As %Status
{
	Set tStatus = ..StatusToText(pStatus)
	Quit ..DebugTEST(tStatus)
}

ClassMethod ExecuteQueryOneValue(pQuery As %String, ByRef pResult As %String, pDEBUG As %Integer = 0) As %Status
{
	Do:pDEBUG ..DebugTEST("Feeder.Util - ExecuteQueryOneValue")
	Do:pDEBUG ..DebugTEST("pQuery = "_pQuery)
	Set pResult = ""
	Set rs = ##class(%ResultSet).%New()
	Set tSC = rs.Prepare(pQuery)
	Do:pDEBUG ..DebugStatus(tSC)
	If $$$ISOK(tSC) {
		Set tSC = rs.Execute()
		Do:pDEBUG ..DebugStatus(tSC)
		If $$$ISOK(tSC), rs.Next() Set pResult = rs.GetData(1)
	}
	Do rs.Close()
	Set rs = ""
	Do:pDEBUG ..DebugTEST("pResult = "_pResult)
	Quit tSC
}

ClassMethod FindMyTask(pTaskName As %String = "") As %String
{
	New $Namespace
	Set $Namespace = "%SYS"

	If (pTaskName = "") { Quit "" }

	//Do ..DebugTEST("Feeder.Util - FindMyTask")
	Set tTaskId = ""
	Set query = "Select ID from %SYS.Task where Name = '?'"
	Set query = $REPLACE(query,"?",pTaskName)
	Set tSC = ..ExecuteQueryOneValue(query,.tTaskId)
	//Do ..DebugTEST("tTaskId = "_tTaskId)
	Quit tTaskId
}

ClassMethod GetTaskFile() As %String
{
	Set tDefaultDirectory = "/path/feeder/"
	Set tDefaultFilename = "FeederTask.json"
	Set tDirectory = $Get(^myFeeder("Config","TaskFile","Directory"),tDefaultDirectory)
	Set tFilename = $Get(^myFeeder("Config","TaskFile","Filename"),tDefaultFilename)
	Set tReturn = tDirectory_tFilename
	Quit tReturn
}

ClassMethod ReadJsonFile(pFile As %String, pDebug = 0) As %String
{
	Write:pDebug "ReadJsonFile",!
	Do:pDebug ..DebugTEST("ReadJsonFile")
	If ($Get(pFile) = "") Quit ""
	Write:pDebug pFile,!
	Set tReturn = ""
	Set timeout = 2
	Try {
		Open pFile:("R"):timeout  // read
		If $test {
			Write:pDebug "Open",!
			Do:pDebug ..DebugTEST("Open")
			Use pFile
			Do:pDebug ..DebugTEST("Use")
			Set pos = $ZPOS
			Do:pDebug ..DebugTEST(pos)
			Set pos = $ZSEEK(0,0)
			Do:pDebug ..DebugTEST(pos)
			For {
				Set pos = $ZPOS
				Do:pDebug ..DebugTEST(pos)
				Read tText
				Do:pDebug ..DebugTEST($Get(tText))
				Set:pDebug ^DEBUG($I(DEBUG))=$GET(tText)
				Set tReturn = tReturn_$Get(tText)
			}
			Close pFile
		}
	}
	Catch exception {
		Do:pDebug ..DebugTEST("Catch")
		If exception.%IsA("%Exception.SystemException") {
			Do BACK^%ETN // Log error in error log
		} Else {
			Throw exception // We will just throw these to outer error handler
		}
		Close pFile
	}
	//Use 0
	//Write:pDebug tReturn,!
	Set tReturn = $Translate($Get(tReturn),$Char(9)," ")
	Quit tReturn
}

ClassMethod TranslateServer(pServer As %String = "") As %String
{
	Set tReturnServer = pServer
	Set tNLB = "-nlb-"
	If (pServer [ tNLB) {
		Set tReturnServer = $Piece(pServer,tNLB,1)_"-nlb"
		Quit tReturnServer
	}
	Quit tReturnServer
}

}
