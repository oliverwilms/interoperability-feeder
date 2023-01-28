Class Feeder.DLAOperation Extends EnsLib.HTTP.GenericOperation [ Language = objectscript ]
{

Parameter INVOCATION = "Queue";

/// Invoke a remote HTTP Service given a generic HTTP request
Method OnMessage(pRequest As EnsLib.HTTP.GenericMessage, Output pResponse As EnsLib.HTTP.GenericMessage) As %Status
{
	#define maxRetries 0
	Set tErrorCount = 0
	Set tReturnStatus = $$$OK
 Do {  // } While tRetryFlag
	Set tAbortFlag = $Get(^myFeeder("AbortFlag"),0)
	If (tAbortFlag) {
		//Quit $$$OK
		Quit
	}
	Set pDEBUG = 1
	If (pDEBUG > 1) Do ##class(Feeder.Util).DebugTEST("Feeder.DLAOperation : OnMessage")
	//Do ##class(Feeder.Util).DebugTEST("DEBUG constant macro EnsErrHTTPStatus = "_$$$EnsErrHTTPStatus)
	// DEBUG constant macro EnsErrHTTPStatus = <Ens>ErrHTTPStatus
#dim pStreamContainer As Ens.StreamContainer
	Set pStreamContainer = pRequest
	If (pDEBUG > 1) Do ##class(Feeder.Util).DebugTEST("pRequest = "_$Get(pRequest))
	Set pRequest = ##class(EnsLib.HTTP.GenericMessage).%New()
	If (pDEBUG > 1) Do ##class(Feeder.Util).DebugTEST("pRequest = "_$Get(pRequest))
	Set pRequest.Stream = pStreamContainer.Stream
	If (pDEBUG > 1) Do ##class(Feeder.Util).DebugTEST("pRequest.Stream = "_pRequest.Stream)
	Do pRequest.SetHTTPHeaders("")
	Set tSC=$$$OK, ..%HttpRequest.Location="", ..%HttpRequest.AcceptGzip=0, ..%HttpRequest.FollowRedirect=0, ..%HttpRequest.ReadRawMode=..ReadRawMode,  ..%HttpRequest.WriteRawMode=..WriteRawMode
	Do ..%HttpRequest.Reset()
	Do ..%HttpRequest.RemoveHeader("HOST"), ..%HttpRequest.RemoveHeader("USER-AGENT"), ..%HttpRequest.RemoveHeader("REFERER")
	#; Pass along selected HTTP headers
	Set (tReq,tURL,tCT,tLen,tNParams,tRawParams,tApp,tCfg)=""
	Set tDoNotPassThrough=","_$ZCVT(..%ExcludeOutboundHeaders,"L")_",host,cspapplication,ensconfigname,ensattribute,url,httprequest,httpversion,content-length,content-type,charencoding,translationtable,iparams,params,rawparams,"
	If (pDEBUG > 1) Do ##class(Feeder.Util).DebugTEST("tDoNotPassThrough = "_$Get(tDoNotPassThrough))

	Set tHeaderKey=""
	For {
		Set tHeaderKey=pRequest.HTTPHeaders.Next(tHeaderKey)  Quit:""=tHeaderKey  Set tHeaderLwr=$ZCVT(tHeaderKey,"L")
		Set tPass=(tDoNotPassThrough'[(","_tHeaderLwr_","))  Set:tPass&&(tHeaderLwr?1"iparams_"1.N) tPass=0
		Do:tPass ..%HttpRequest.SetHeader(tHeaderKey,pRequest.HTTPHeaders.GetAt(tHeaderKey)) ; no need to handle multiple on one line
		Set:tHeaderLwr="httprequest" tReq=pRequest.HTTPHeaders.GetAt(tHeaderKey)
		Set:tHeaderLwr="url" tURL=pRequest.HTTPHeaders.GetAt(tHeaderKey)
		Set:tHeaderLwr="content-type" tCT=$TR(pRequest.HTTPHeaders.GetAt(tHeaderKey),$C(34,39)) ; remove possible "  and '
		Set:tHeaderLwr="content-length" tLen=pRequest.HTTPHeaders.GetAt(tHeaderKey)
		Set:tHeaderLwr="iparams" tNParams=pRequest.HTTPHeaders.GetAt(tHeaderKey)
		Set:tHeaderLwr="rawparams" tRawParams=pRequest.HTTPHeaders.GetAt(tHeaderKey)
		Set:tHeaderLwr="cspapplication" tApp=pRequest.HTTPHeaders.GetAt(tHeaderKey)
		Set:tHeaderLwr="ensconfigname" tCfg=pRequest.HTTPHeaders.GetAt(tHeaderKey)
	}
	Set tKey = "USER-AGENT"
	//Set tVal = "FEEDER"
	Set tVal = $SYSTEM.INetInfo.LocalHostName()
	Do ..%HttpRequest.SetHeader(tKey,tVal)
	#; if rawparams then remove any query string from tURL
	If (pDEBUG > 1) Do ##class(Feeder.Util).DebugTEST("tRawParams = "_$Get(tRawParams))
	If (pDEBUG > 1) Do ##class(Feeder.Util).DebugTEST("tURL = "_$Get(tURL))
	If tRawParams'="" Set tURL = $P(tURL,"?",1)
	If (pDEBUG > 1) Do ##class(Feeder.Util).DebugTEST("tURL = "_$Get(tURL))
	Set tReq = "GET"
	#; if you want to POST both form body data and form variables then pass RAWPARAMS - the RAWPARAMS form variables will go in the URL and not in the form body, leaving the form body to contain your data
	Set tFormVarNames="", tDataArray="", n=0, tGenRawParams = ""
	
	If (pDEBUG > 1) Do ##class(Feeder.Util).DebugTEST("tReq = "_$Get(tReq))
	If $IsObject(pRequest.Stream) {
		Set:$Case($ZCVT(tReq,"U"),"":1,"POST":1,:0) tNParams=0
		Set:'tLen tLen=pRequest.Stream.Size
	}
	If (pDEBUG > 1) Do ##class(Feeder.Util).DebugTEST("tLen = "_$Get(tLen))

	If (pDEBUG > 1) Do ##class(Feeder.Util).DebugTEST("tNParams = "_$Get(tNParams))
	For i=1:1:tNParams {
		Set tParam=pRequest.HTTPHeaders.GetAt("IParams_"_i)
		Set tKey=$ZStrip($P(tParam,"="),"<>W"), tVal=$S($F(tParam,"="):$E(tParam,$F(tParam,"="),*),1:"")
		If tRawParams="" Set tGenRawParams=tGenRawParams_$S(tGenRawParams="":"",1:"&")_$S(tKey="":"", 1:tKey)_$S(tVal="":"", 1:"="_tVal)
		If (tKey'=""),(tVal'="") {
			Set tFormVarNames=tFormVarNames_$S(tFormVarNames="":"",1:",")_tKey
			Set tDataArray($I(n))=tVal
		}
	}
		Set tKey = "FILENAME"
		Set tVal = pStreamContainer.OriginalFilename
		Set tVal = ##class(%File).GetFilename(tVal)
		Set tFilename = tVal
		Set tDebug = tKey_" = "_tFilename
	If (pDEBUG > 0) Do ##class(Feeder.Util).DebugTEST(tDebug)
			Set tFormVarNames=tFormVarNames_$S(tFormVarNames="":"",1:",")_tKey
			Set tDataArray($I(n))=tVal
	If (pDEBUG > 1) Do ##class(Feeder.Util).DebugTEST("tFormVarNames = "_$Get(tFormVarNames))
	If (pDEBUG > 1) Do ##class(Feeder.Util).DebugTEST("n = "_$Get(n))

	#; if the conversion to FormVarNames meant we did do not use all e.g. for  ?WSDL&abc=1 we would only set abc=1 then do not use tFormVarNames
	If (pDEBUG > 1) Do ##class(Feeder.Util).DebugTEST("tNParams = "_$Get(tNParams))
	If (pDEBUG > 1) Do ##class(Feeder.Util).DebugTEST("n = "_$Get(n))
	Set tNParams = n
	If +tNParams && (n'=tNParams) {
		Set tFormVarNames=""
		#;if no tRawParams then need to use the one generated from iparams
		//If tRawParams="" {$$$sysTRACE("Using generated RAWPARMS of "_tGenRawParams) Set tRawRarams = tGenRawParams}
		If tRawParams="" {$$$sysTRACE("Using generated RAWPARMS of "_tGenRawParams) Set tRawParams = tGenRawParams}  // corrected typo "tRawRarams"
	}

	#; If no IPARAMS then use RAWPARAMS in the URL
	Set tRawParams=$S(""=tFormVarNames&&$L(tRawParams):"?"_tRawParams, 1:"")
	If (pDEBUG > 1) Do ##class(Feeder.Util).DebugTEST("tRawParams = "_$Get(tRawParams))
	Set tCT = "text/plain"

	If (pDEBUG > 1) Do ##class(Feeder.Util).DebugTEST("tCT = "_$Get(tCT))
	Set ..%HttpRequest.ContentType=tCT
	Set tSC=..constructHTTPRequest(pRequest,tLen,tCT)  // Quit:$$$ISERR(tSC) tSC
	If $$$ISERR(tSC) {
		Set tReturnStatus = tSC
		Quit
	}
	Do ..%HttpRequest.RemoveHeader("filename")
	
	#; Now send to the target address
	Set tAdURL=..Adapter.URL, tAdURL1=$E(tAdURL)
	If (pDEBUG > 1) Do ##class(Feeder.Util).DebugTEST("tAdURL = "_$Get(tAdURL))
	If (pDEBUG > 1) Do ##class(Feeder.Util).DebugTEST("tAdURL1 = "_$Get(tAdURL1))
	If tAdURL1="^" {
		#; strip Application from URL and replace it with the remaining adapter URL part, if any
		Set $E(tAdURL,1)=""  Set:"*"=tAdURL tAdURL=""  Set:"/"'=$E(tAdURL,1) tAdURL="/"_tAdURL
		If (""'=tApp) {
			If (tApp=$E(tURL,1,$L(tApp)))&&("/"=$E(tApp,*)) {
				Set tURL=tAdURL_$S($L(tAdURL)>1:"/",1:"")_$E(tURL,$L(tApp)+1,*), tAdURL=""
			}
		} Else {
			/*	Come in via the adapter and the Application name is not at the front so keep inbound URL.
				Prepend anthing after the | to the URL that came in.
			*/
			Set tURL=$S($L(tAdURL)>1:tAdURL,1:"")_tURL, tAdURL = ""			}
	} ElseIf tAdURL1="|" {
		#; strip Application and ConfigName from URL and replace it with the remaining adapter URL part, if any
		If ""=tApp { Set:""'=tCfg tCfg="/"_tCfg_"/" } Else { Set tCfg=$S(""=tCfg:tApp, 1:tApp_tCfg_"/") }
		Set $E(tAdURL,1)=""  Set:"*"=tAdURL tAdURL=""  Set:"/"'=$E(tAdURL,1) tAdURL="/"_tAdURL
		If (""'=tCfg){
			If (tCfg=$E(tURL,1,$L(tCfg))) {
				Set tURL=tAdURL_$S($L(tAdURL)>1:"/",1:"")_$E(tURL,$L(tCfg)+1,*), tAdURL=""
			} ElseIf (tApp="") {
				/*	Come in via the adapter and the tCfg name is not the same so keep inbound URL. 
					Prepend anthing after the | to the URL that came in.
				*/
				Set tURL=$S($L(tAdURL)>1:tAdURL,1:"")_tURL, tAdURL = ""	
			}
		}
	}
#dim tHttpResponse As %Net.HttpResponse
	If (pDEBUG > 1) Do ##class(Feeder.Util).DebugTEST("tReq = "_tReq)
	Set tReq = "GET"
	If (pDEBUG > 1) Do ##class(Feeder.Util).DebugTEST("tReq = "_tReq)
	If (pDEBUG > 1) Do ##class(Feeder.Util).DebugTEST("tFormVarNames = "_tFormVarNames)
	If (pDEBUG > 1) Do ##class(Feeder.Util).DebugTEST("tAdURL = "_tAdURL)
	//Set tRawParams = "?FILENAME="_##class(%File).GetFilename(pStreamContainer.OriginalFilename)
	If (pDEBUG > 1) Do ##class(Feeder.Util).DebugTEST("tRawParams = "_tRawParams)
	Set pURL=$Case(tAdURL,"":tURL,"*":tURL,:tAdURL)_tRawParams
	If (pDEBUG > 1) Do ##class(Feeder.Util).DebugTEST("pURL = "_pURL)
#dim objResponseTime As Feeder.ResponseTime
	Set tAdPort = ..Adapter.HTTPPort
	Set tAdServer = ..Adapter.HTTPServer
	If ($Get(pUnitTest) = "") Set pUnitTest = $Get(^myUnitTests)

	Set tRetryFlag = 0
	Set objResponseTime = ##class(Feeder.ResponseTime).NewRequest(..%HttpRequest,pURL,tAdServer,tAdPort,pUnitTest,tFilename)
	Set tSC = objResponseTime.%Save()
	If $$$ISERR(tSC) Do ##class(Feeder.Util).DebugStatus(tSC)
	Set tSC=..Adapter.SendFormDataArray(.tHttpResponse,tReq,..%HttpRequest,tFormVarNames,.tDataArray,pURL)

	If $$$ISERR(tSC) Do ##class(Feeder.Util).DebugStatus(tSC)
	Set x = objResponseTime.SaveResponse(tHttpResponse)  // preserve tSC
	If $IsObject(tHttpResponse) {
		If (tHttpResponse.StatusCode '= 200) {
			Do ##class(Feeder.Util).DebugTEST("StatusCode = "_tHttpResponse.StatusCode)
			Do ##class(Feeder.Util).DebugTEST("ReasonPhrase = "_tHttpResponse.ReasonPhrase)
		}
		If (tHttpResponse.StatusCode = 500) {  // Internal Server Error
			If $Increment(tErrorCount) <= $$$maxRetries Set tRetryFlag = 1
		}
		If (tHttpResponse.StatusCode = 400) {  // Empty Stream
			If $Increment(tErrorCount) <= $$$maxRetries Set tRetryFlag = 1
		}
	} Else {
		Do ##class(Feeder.Util).DebugTEST("HttpResponse = "_tHttpResponse)
	}
	If $$$ISERR(tSC),(tRetryFlag = 0) {
		// ERROR #5922: Timed out waiting for response
		// ERROR #6097: Error '<READ>zRead+28^%Net.HttpRequest.1' while using TCP/IP device '9999'
		If $Increment(tErrorCount) <= $$$maxRetries Set tRetryFlag = 1
	}
 } While tRetryFlag
	If tAbortFlag { Quit $$$OK }
	If ##class(Ens.Util.Statistics).StatsStarted(..%ConfigName) {
		Set tStatsUserDimension=$LG(pRequest.HTTPHeaders.GetAt("EnsAttribute"),2)
		If (tStatsUserDimension'="") Do ##class(Ens.Util.Statistics).SetStatsUserDimension(..%ConfigName,tStatsUserDimension)
	}
	If $$$ISERR(tReturnStatus) { Set tSC = tReturnStatus }
	#; Suppress HTTP status errors and just pass back the status, headers and body
	If $$$ISERR(tSC)&&'$$$StatusEquals(tSC,$$$EnsErrHTTPStatus) { Set ..%HttpRequest=##class(%Net.HttpRequest).%New()  Quit tSC }
	If $$$ISERR(tReturnStatus) { Set tSC = tReturnStatus  Quit tSC }
	Quit ..constructResponse(tHttpResponse,.pResponse)
}

}
