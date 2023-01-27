Class Feeder.Task.LBTest Extends %SYS.Task.Definition
{

Parameter TaskName = "LB Test";

/// Number of Files to create for this test
Property Files As %ZEN.Datatype.string [ InitialExpression = 1 ];

Method OnTask() As %Status
{
	Quit ##class(Feeder.FeederTests).LBTest(..Files)
}

}
