Class Feeder.ResponseTime Extends %Persistent
{

Property RequestTimestamp As %String;

Property ResponseTimestamp As %String;

Property ResponseZCalc As %Integer [ Calculated, SqlComputeCode = {set {*}=##class(Feeder.Util).GetDateTimeDiff({RequestTimestamp},{ResponseTimestamp})}, SqlComputed ];

/// Server to connect to (optional). If not specified, it defaults to 'localhost'.
Property Server As %String(MAXLEN = 255);

/// Port for connection.
Property Port As %String(MAXLEN = 6);

/// URL to connect to (optional).
Property URL As %String(MAXLEN = 255);

/// The HTTP status code. This is useful to determine if the request was
/// successful. Look in the rfc for HTTP to see which codes are supported
/// and what they mean. A human readable form of this code is stored as
/// the <PROPERTY>ReasonPhrase</PROPERTY>
Property StatusCode As %Integer;

/// This is the human readable reason that goes with the <PROPERTY>StatusCode</PROPERTY>.
Property ReasonPhrase As %String;

/// The HTTP status line. This is the first line of the response and signals
/// if the request was successful or if there was a problem.
Property StatusLine As %String;

/// Strict-Transport-Security Response Header
Property HSTS As %String;

Property Filename As %String(MAXLEN = 255);

Property ContentLength As %String;

Property myUnitTest As %String;

Property Status As %Status;

Property whichTest As %String;

ClassMethod NewRequest(pRequest As %Net.HttpRequest, pURL As %String, pAdapterServer As %String, pAdapterPort As %String, pUnitTest As %String, pFilename As %String) As Feeder.ResponseTime
{
	//Set tPort = $Select($Get(pAdapterPort)'="":pAdapterPort,1:pRequest.Port)
	Set tPort = $Get(pAdapterPort)
	Set tServer = $Select($Get(pAdapterServer)'="":pAdapterServer,1:pRequest.Server)
	Set oResponseTime = ..%New()
	Set oResponseTime.RequestTimestamp = $ZDateTime($NOW(),3,1,3)
	If ($Get(pUnitTest) = "") Set pUnitTest = $Get(^myUnitTests)
	Set oResponseTime.myUnitTest = pUnitTest
	Set oResponseTime.ContentLength = pRequest.ContentLength
	Set oResponseTime.Filename = $Get(pFilename)
	Set oResponseTime.Port = tPort
	Set oResponseTime.Server = ##class(Feeder.Util).TranslateServer(tServer)
	Set oResponseTime.URL = $Get(pURL)
	Set oResponseTime.whichTest = $Get(^myUnitTestControl("whichTest"))
	//Set tSC = ##class(Feeder.Test).UpdateTargetPort(pUnitTest,tPort)
	//Set tSC = ##class(Feeder.Test).UpdateTargetServer(pUnitTest,tServer)
	Quit oResponseTime
}

Method SaveResponse(pResponse As %Net.HttpResponse) As %Status
{
	Set ..ResponseTimestamp = $ZDateTime($NOW(),3,1,3)
	If $IsObject(pResponse) {
		Set ..StatusCode = pResponse.StatusCode
		Set ..ReasonPhrase = pResponse.ReasonPhrase
		Set ..StatusLine = pResponse.StatusLine
		Set ..HSTS = pResponse.GetHeader("Strict-Transport-Security")
	}
	Set tSC = ..%Save()
	Quit tSC
}

Method SaveStatus(pStatus As %Status) As %Status
{
	Set ..ResponseTimestamp = $ZDateTime($NOW(),3,1,3)
	Set ..Status = pStatus
	Set tSC = ..%Save()
	Quit tSC
}

Storage Default
{
<Data name="ResponseTimeDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>RequestTimestamp</Value>
</Value>
<Value name="3">
<Value>ResponseTimestamp</Value>
</Value>
<Value name="4">
<Value>Server</Value>
</Value>
<Value name="5">
<Value>Port</Value>
</Value>
<Value name="6">
<Value>URL</Value>
</Value>
<Value name="7">
<Value>StatusCode</Value>
</Value>
<Value name="8">
<Value>ReasonPhrase</Value>
</Value>
<Value name="9">
<Value>myUnitTest</Value>
</Value>
<Value name="10">
<Value>Status</Value>
</Value>
<Value name="11">
<Value>whichTest</Value>
</Value>
<Value name="12">
<Value>StatusLine</Value>
</Value>
<Value name="13">
<Value>HSTS</Value>
</Value>
<Value name="14">
<Value>Filename</Value>
</Value>
<Value name="15">
<Value>ContentLength</Value>
</Value>
</Data>
<DataLocation>^Feeder.ResponseTimeD</DataLocation>
<DefaultData>ResponseTimeDefaultData</DefaultData>
<IdLocation>^Feeder.ResponseTimeD</IdLocation>
<IndexLocation>^Feeder.ResponseTimeI</IndexLocation>
<StreamLocation>^Feeder.ResponseTimeS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
