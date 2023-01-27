Include (%occInclude, Ensemble)

Class Feeder.Ensemble
{

/// This method starts the production running.
/// pProductionName: The name of the production to be started.  If not specified, defaults to the "last" production used (if any).
ClassMethod StartProduction(pProductionName As %String = {$GET(^Ens.Configuration("csp","LastProduction"))}) As %Status
{
	Do ##class(Feeder.Util).DebugTEST("Feeder.Ensemble - StartProduction")
	Try {
		Set tSC = ##class(Ens.Director).StartProduction(pProductionName)
	} Catch {
		Do ##class(Feeder.Util).DebugTEST("Something went wrong")
	}
	Do ##class(Feeder.Util).DebugStatus(tSC)
	Quit tSC
}

/// This method stops the running production.
/// pTimeout: How many seconds to wait for the jobs to go down.
/// pForce:   It indicates if we should forcefully kill the jobs which can not stop by themselves.
ClassMethod StopProduction(
	pTimeout As %Numeric = 10,
	pForce As %Boolean = 0) As %Status
{
	Do ##class(Feeder.Util).DebugTEST("Feeder.Ensemble - StopProduction")
	Set tSC = ##class(Ens.Director).StopProduction(pTimeout, pForce)
	Do ##class(Feeder.Util).DebugStatus(tSC)
	Quit tSC
}

}
