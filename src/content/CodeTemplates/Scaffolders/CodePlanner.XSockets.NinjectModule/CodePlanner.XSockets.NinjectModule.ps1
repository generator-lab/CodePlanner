[T4Scaffolding.Scaffolder(Description = "Enter a description of CodePlanner.XSockets.NinjectModule here")][CmdletBinding()]
param(        
	[parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)][string]$ProjectName = "",
    [string]$Project,
	[string]$CodeLanguage,
	[string[]]$TemplateFolders,
	[switch]$Force = $false
)

#
#Use default proj if not set
#
if($ProjectName -eq ""){ $ProjectName = $Project }

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
$coreProjectName = $rootNamespace + ".Core"
$dataProjectName = $rootNamespace + ".Data"
$serviceProjectName = $rootNamespace + ".Service"

Write-Host "Collecting properties for the model, this might take a while" -ForegroundColor Blue

#open domainmodel files
$files = (Get-Project $coreProjectName).ProjectItems | Where-Object {$_.Name -eq "Model"} | ForEach{$_.ProjectItems }
$files | ForEach{$_.Open(); $_.Document.Activate()}

Start-Sleep -s 2

$namespaces = $DTE.Documents | ForEach{$_.ProjectItem.FileCodeModel.CodeElements | Where-Object{$_.Kind -eq 5}}	
	
$classes = $namespaces | ForEach{$_.Children}

$modelnames = @()  

$classes | ForEach{		
	$current = $_
	$_.Bases | ForEach{
		if($_.Name -eq "PersistentEntity"){		
			$modelnames = $modelnames + $current.Name
		}
	}		
}    


##############################################################
# Create the NinjectModule
##############################################################
$outputPath = "Ninject\ServiceModule"

$ximports = $coreProjectName + ".Interfaces.Data, " + $coreProjectName + ".Interfaces.Service, " + $dataProjectName + "," + $serviceProjectName

$namespace = (Get-Project $ProjectName).Properties.Item("DefaultNamespace").Value + ".Ninject"

Add-ProjectItemViaTemplate $outputPath -Template NinjectModule `
	-Model @{Namespace = $namespace; ModelNames = $modelnames; ExtraUsings = $ximports} `
	-SuccessMessage "Added NinjectModule to $($ProjectName) {0}" `
	-TemplateFolders $TemplateFolders -Project $ProjectName -CodeLanguage $CodeLanguage -Force:$Force

try{
	$file = Get-ProjectItem "$($outputPath).cs" -Project $dataProjectName
	$file.Open()
	$file.Document.Activate()	
	$DTE.ExecuteCommand("Edit.FormatDocument", "")
	$DTE.ActiveDocument.Save()
}catch {
	Write-Host "Hey, you better not be clicking around in VS while we generate code" -ForegroundColor DarkRed
}