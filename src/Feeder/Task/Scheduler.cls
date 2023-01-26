Class Feeder.Task.Scheduler Extends %SYS.Task.Definition
{

Parameter TaskName = "Scheduler";

Method OnTask() As %Status
{
	Set pDebug = 0
	Set file = ##class(Feeder.Util).GetTaskFile()
	Set myJSONstring = ##class(Feeder.Util).ReadJsonFile(file)
	If (myJSONstring = "") { Quit $$$OK }

	Do:pDebug ##class(Feeder.Util).DebugTEST("JSON: "_myJSONstring)
	Set tAbortFlag = 0
	Set myObject = ##class(%DynamicAbstractObject).%FromJSON(myJSONstring)
	Set tAbortValue = myObject.AbortFlag
	If (tAbortValue) Set tAbortFlag = 1
	If tAbortFlag {
		Set ^myFeeder("AbortFlag") = tAbortFlag
	}
	Set myTaskName = myObject.TaskName
	Set myTaskId = ##class(Feeder.Util).FindMyTask(myTaskName)
	Do:pDebug ##class(Feeder.Util).DebugTEST("TaskId: "_myTaskId)
	Set tUpdateFlag = 0
	If (myTaskId '= "") {
		Set tAbortValue = $Get(^myFeeder("Config","TaskScheduler",file,"AbortFlag"))
		If (myObject.AbortFlag '= tAbortValue) Set tUpdateFlag = 1
		Set tStartDate = $Get(^myFeeder("Config","TaskScheduler",file,"StartDate"))
		If (myObject.StartDate '= tStartDate) Set tUpdateFlag = 1
		Set tEndDate = $Get(^myFeeder("Config","TaskScheduler",file,"EndDate"))
		If (myObject.EndDate '= tEndDate) Set tUpdateFlag = 1
		Set tDailyStartTime = $Get(^myFeeder("Config","TaskScheduler",file,"DailyStartTime"))
		If (myObject.DailyStartTime '= tDailyStartTime) Set tUpdateFlag = 1
		Set tNumberOfFiles = $Get(^myFeeder("Config","TaskScheduler",file,"NumberOfFiles"))
		If (myObject.NumberOfFiles '= tNumberOfFiles) Set tUpdateFlag = 1
		If tUpdateFlag Set task = ##class(%SYS.Task).%OpenId(myTaskId)
	}
	If (myTaskId = "") {
		Set task = ##class(%SYS.Task).%New()
		Set task.Name = myTaskName
		Set task.Description = myTaskName
		Set task.NameSpace = "FEEDER"
		Set task.RunAsUser = "_SYSTEM"
		Set task.TaskClass = "Feeder.Task.LBTest"
		Set task.TimePeriod=5  // (DISPLAYLIST = ",Daily,Weekly,Monthly,Monthly Special,Run After,On Demand", VALUELIST = ",0,1,2,3,4,5")
		If (myObject.TimePeriod = "Daily") Set task.TimePeriod = 0
		//Set task.TimePeriodEvery=1
		Set task.TimePeriodDay=""
		Set task.DailyFrequency=1  // (DISPLAYLIST = ",Once,Several", VALUELIST = ",0,1")
		If (myObject.DailyFrequency = "Once") Set task.DailyFrequency = 0
		//Set task.DailyFrequencyTime=0  // (DISPLAYLIST = ",Minutes,Hourly", VALUELIST = ",0,1")
		Set task.DailyIncrement=1  // Run every # 
		Set task.DailyStartTime=0
		Set tUpdateFlag = 1
	}
	If tUpdateFlag {
		If (myObject.DailyStartTime '= "") Set task.DailyStartTime = $ZTIMEH(myObject.DailyStartTime)
		Set task.DailyEndTime=""
		Set task.Priority=0  // (DISPLAYLIST = ",Normal,Low,High", VALUELIST = ",0,1,2")
		//Set task.StartDate=+$H  // Start today instead of tomorrow
		If (myObject.StartDate '= "") Set task.StartDate = $ZDATEH(myObject.StartDate)
		If (myObject.EndDate '= "") Set task.EndDate = $ZDATEH(myObject.EndDate)
		If (myObject.NumberOfFiles > 0) Set task.Settings = $LISTBUILD("Files",myObject.NumberOfFiles)
		Set task.DeleteAfterRun = 1
		Set tSC = task.%Save()
		If $$$ISERR(tSC) Do ##class(Feeder.Util).DebugStatus(tSC)
		Set ^myFeeder("Config","TaskScheduler",file,"StartDate") = myObject.StartDate
		Set ^myFeeder("Config","TaskScheduler",file,"EndDate") = myObject.EndDate
		Set ^myFeeder("Config","TaskScheduler",file,"DailyStartTime") = myObject.DailyStartTime
		Set ^myFeeder("Config","TaskScheduler",file,"NumberOfFiles") = myObject.NumberOfFiles
		Set ^myFeeder("Config","TaskScheduler",file,"AbortFlag") = myObject.AbortFlag
	}
    Try {
		If (myObject.MINRUN '= "") Set ^myFeeder("Config","TestProduction","MINRUN") = myObject.MINRUN
	}
    Catch exception {
		If exception.%IsA("%Exception.SystemException") {
			Do BACK^%ETN // Log error in error log
		} Else {
			Throw exception // We will just throw these to outer error handler
		}
		//Quit
	}
    Quit ##class(Feeder.Util).DebugTEST("Feeder.Task.Scheduler:OnTask")
}

}
