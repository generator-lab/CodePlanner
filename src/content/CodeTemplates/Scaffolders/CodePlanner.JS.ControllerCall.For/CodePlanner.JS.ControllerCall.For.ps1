[T4Scaffolding.Scaffolder(Description = "Enter a description of CodePlanner.JS.ControllerCall.For here")][CmdletBinding()]
param(
	[parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)][string]$ModelType,       
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

##############################################################
# Create the examples
##############################################################
Write-Host "//GetAll, no parameters" -ForegroundColor Yellow 
Write-Host "$.getJSON('/$($ModelType)/GetAll').success(function (result) {" -ForegroundColor DarkGreen
Write-Host "    console.log('GetAll',result);" -ForegroundColor DarkGreen
Write-Host "}).error(function(err) {" -ForegroundColor DarkGreen
Write-Host "    console.log('Error', err);" -ForegroundColor DarkGreen
Write-Host "});" -ForegroundColor DarkGreen

Write-Host ""
Write-Host "//SaveOrUpdate, omit id to create a new entity" -ForegroundColor Yellow 
#Get regular properties
$properties = @()
(Get-ProjectType PersistentEntity).Children | Where-Object{$_.Kind -eq 4 -and $_.Type.TypeKind -ne 5} | ForEach{
	if($_.Type.AsString -eq "string"){
		$p = "$($_.Name):'$($_.Type.AsString)'"; 
	}
	else{
		$p = "$($_.Name):$($_.Type.AsString)"; 
	}
	$properties = $properties + $p
}
(Get-ProjectType $ModelType).Children | Where-Object{$_.Kind -eq 4 -and $_.Type.CodeType.Kind -eq 10} | ForEach{
	$p = "$($_.Name):int (enum)"; 
	$properties = $properties + $p
}
(Get-ProjectType $ModelType).Children | Where-Object{$_.Kind -eq 4 -and $_.Type.TypeKind -ne 1} | ForEach{
	if($_.Type.AsString -eq "string"){
		$p = "$($_.Name):'$($_.Type.AsString)'"; 
	}
	else{
		$p = "$($_.Name):$($_.Type.AsString)"; 
	}
	$properties = $properties + $p
}

Write-Host "var json  = {" -ForegroundColor DarkGreen
foreach ($element in $properties) {
Write-Host	"	$($element)," -ForegroundColor DarkGreen
}
Write-Host "};" -ForegroundColor DarkGreen
Write-Host "$.post('/$($ModelType)/SaveOrUpdate/', json).success(function (d) {" -ForegroundColor DarkGreen
Write-Host "    console.log('SaveOrUpdate', d);" -ForegroundColor DarkGreen
Write-Host "}).error(function (err) {" -ForegroundColor DarkGreen
Write-Host "    console.log('Error', err);" -ForegroundColor DarkGreen
Write-Host "});" -ForegroundColor DarkGreen

Write-Host ""
Write-Host "//Delete, replace 666 with the id of the entity to remove" -ForegroundColor Yellow 
Write-Host "$.post('/$($ModelType)/Delete', { id: 666 }).success(function (d) {" -ForegroundColor DarkGreen
Write-Host "    console.log('Deleted', d);" -ForegroundColor DarkGreen
Write-Host "}).error(function(err) {" -ForegroundColor DarkGreen
Write-Host "    console.log('Error', err);" -ForegroundColor DarkGreen
Write-Host "});" -ForegroundColor DarkGreen

Write-Host ""
Write-Host "//GetById, replace 666 with the id of the entity to get" -ForegroundColor Yellow 
Write-Host "$.getJSON('/$($ModelType)/GetById', { id: 666 }).success(function (d) {" -ForegroundColor DarkGreen
Write-Host "    console.log('GetById',d);" -ForegroundColor DarkGreen
Write-Host "}).error(function(err) {" -ForegroundColor DarkGreen
Write-Host "    console.log('Error', err);" -ForegroundColor DarkGreen
Write-Host "});" -ForegroundColor DarkGreen