[T4Scaffolding.Scaffolder(Description = "Enter a description of CodePlanner.JS.XSocketsCall.For here")][CmdletBinding()]
param(
	[parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)][string]$ModelType,
	[parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)][string]$Controller,      
    [string]$Project,
	[string]$CodeLanguage,
	[string[]]$TemplateFolders,
	[switch]$Force = $false
)

##############################################################
# NAMESPACE
##############################################################
$namespace = (Get-Project $Project).Properties.Item("DefaultNamespace").Value
$rootNamespace = $namespace
$dotIX = $namespace.LastIndexOf('.')
if($dotIX -gt 0){
	$rootNamespace = $namespace.Substring(0,$namespace.LastIndexOf('.'))
}

##############################################################
# Project Name
##############################################################
$mvcProjectName = $namespace
$coreProjectName = $rootNamespace + ".Core"

##############################################################
# Info about ModelType
##############################################################
$foundModelType = Get-ProjectType $ModelType -Project $coreProjectName
if (!$foundModelType) { 
	Write-Host "Could not find an entity of type $($ModelType)" -ForegroundColor Red 
	return 
}
Write-Host "Collecting properties for the model, this might take a while" -ForegroundColor Blue

#Get regular properties
$properties = @()
(Get-ProjectType $ModelType).Children | Where-Object{$_.Kind -eq 4 -and $_.Type.TypeKind -ne 1 } | ForEach{
	$p = "$($_.Name),$($_.Type.AsString)"; 
	$properties = $properties + $p
}
#Enums
(Get-ProjectType $ModelType).Children | Where-Object{$_.Kind -eq 4 -and $_.Type.TypeKind -eq 1 -and $_.Type.CodeType.Kind -eq 10} | ForEach{	
	$p = "$($_.Name),$($_.Type.AsString)"; 
	$properties = $properties + $p
}

#Get properties
#$properties = @()
#(Get-ProjectType PersistentEntity).Children | Where-Object{$_.Kind -eq 4 -and $_.Type.TypeKind -ne 5} | ForEach{
#	if($_.Type.AsString -eq "string"){
#		$p = "$($_.Name):'$($_.Type.AsString)'"; 
#	}
#	else{
#		$p = "$($_.Name):$($_.Type.AsString)"; 
#	}
#	$properties = $properties + $p
#}
#(Get-ProjectType $ModelType).Children | Where-Object{$_.Kind -eq 4 -and $_.Type.CodeType.Kind -eq 10} | ForEach{
#	$p = "$($_.Name):int (enum)"; 
#	$properties = $properties + $p
#}
#(Get-ProjectType $ModelType).Children | Where-Object{$_.Kind -eq 4 -and $_.Type.TypeKind -ne 1} | ForEach{
#	if($_.Type.AsString -eq "string"){
#		$p = "$($_.Name):'$($_.Type.AsString)'"; 
#	}
#	else{
#		$p = "$($_.Name):$($_.Type.AsString)"; 
#	}
#	$properties = $properties + $p
#}

Write-Host "//ToDo: Declare ws in the window scope! var ws = undefined;" -ForegroundColor Yellow
Write-Host "ws = new XSockets.WebSocket('ws:127.0.0.1:4502/$($Controller)');" -ForegroundColor DarkGreen
Write-Host ""
Write-Host "//Catch and console.log any errors" -ForegroundColor Yellow
Write-Host "ws.bind(XSockets.Events.onError, function (error) {" -ForegroundColor DarkGreen
Write-Host "	console.log('An error occured :(',error);" -ForegroundColor DarkGreen
Write-Host "});" -ForegroundColor DarkGreen
Write-Host ""
Write-Host "ws.bind(XSockets.Events.open, function (client) {" -ForegroundColor DarkGreen
Write-Host ""
Write-Host "	//When the getall returns data" -ForegroundColor Yellow
Write-Host "	ws.bind('$($ModelType)GetAll', function (d) {" -ForegroundColor DarkGreen
Write-Host "		console.log('$($ModelType)GetAll',d);" -ForegroundColor DarkGreen
Write-Host "	});" -ForegroundColor DarkGreen
Write-Host ""            
Write-Host "	//When a entity is saved/updated (by me or someone else)" -ForegroundColor Yellow
Write-Host "	ws.bind('$($ModelType)SaveOrUpdate', function (d) {" -ForegroundColor DarkGreen
Write-Host "		console.log('$($ModelType)SaveOrUpdate',d);" -ForegroundColor DarkGreen
Write-Host "	});" -ForegroundColor DarkGreen
Write-Host ""          
Write-Host "	//When a entity is deleted (by me or someone else)" -ForegroundColor Yellow
Write-Host "	ws.bind('$($ModelType)Delete', function (d) {" -ForegroundColor DarkGreen
Write-Host "		console.log('$($ModelType)Delete',d);" -ForegroundColor DarkGreen
Write-Host "	});" -ForegroundColor DarkGreen
Write-Host ""
Write-Host "	//Get all entities when connection is open." -ForegroundColor Yellow
Write-Host "	ws.trigger('$($ModelType)GetAll', {});" -ForegroundColor DarkGreen
Write-Host ""              
Write-Host "	//Delete example" -ForegroundColor Yellow
Write-Host "	//ws.trigger('$($ModelType)Delete', { id: idToDelete });" -ForegroundColor DarkGreen
Write-Host ""                
Write-Host "	//SaveOrUpdate example" -ForegroundColor Yellow
Write-Host "	//var json  = {" -ForegroundColor DarkGreen
foreach ($element in $properties) {
Write-Host	"	//  	$($element)," -ForegroundColor DarkGreen
}
Write-Host "	//};" -ForegroundColor DarkGreen
Write-Host "	//ws.trigger('$($ModelType)SaveOrUpdate', json);" -ForegroundColor DarkGreen
Write-Host "});" -ForegroundColor DarkGreen
Write-Host ""
Write-Host "If you have not yet done it, remember to run:" -ForegroundColor Red
Write-Host "Scaffold CodePlanner.XSockets.Controller.For $($ModelType) $($Controller) [-ProjectName is optional]" -ForegroundColor Red