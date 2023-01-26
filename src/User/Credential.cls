Class User.Credential
{

ClassMethod MakeCAP() As %Status
{
	Set c = ##class(Ens.Config.Credentials).%New()
	//Set c.Password = ""
	Set c.SystemName = "CAP"
	Set c.Username = "CAPuser"
	Set tSC = c.%Save()
	Quit tSC
}

ClassMethod MakeCCS() As %Status
{
	Set c = ##class(Ens.Config.Credentials).%New()
	//Set c.Password = ""
	Set c.SystemName = "CCS"
	Set c.Username = "CCSuser"
	Set tSC = c.%Save()
	Quit tSC
}

ClassMethod MakeDLA() As %Status
{
	Set c = ##class(Ens.Config.Credentials).%New()
	//Set c.Password = ""
	Set c.SystemName = "DLA"
	Set c.Username = "DLAUser"
	Set tSC = c.%Save()
	Quit tSC
}

ClassMethod MakePOC() As %Status
{
	Set c = ##class(Ens.Config.Credentials).%New()
	//Set c.Password = ""
	Set c.SystemName = "POC"
	Set c.Username = "POCuser"
	Set tSC = c.%Save()
	Quit tSC
}

ClassMethod MakePOU() As %Status
{
	Set c = ##class(Ens.Config.Credentials).%New()
	//Set c.Password = ""
	Set c.SystemName = "POU"
	Set c.Username = "POUuser"
	Set tSC = c.%Save()
	Quit tSC
}

ClassMethod MakeRestapi() As %Status
{
	Set c = ##class(Ens.Config.Credentials).%New()
	//Set c.Password = ""
	Set c.SystemName = "restapi"
	Set c.Username = "user"
	Set tSC = c.%Save()
	Quit tSC
}

ClassMethod Setup() As %Status
{
	Set tSC = ..MakeCCS()
	Set tSC = ..MakeDLA()
	Set tSC = ..MakePOC()
	Set tSC = ..MakePOU()
	Set tSC = ..MakeRestapi()
	Quit $$$OK
}

}
