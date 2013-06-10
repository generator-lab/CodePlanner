##############################################################################
# Copyright (c) 2013 
# Ulf Tomas Bjorklund
# http://average-uffe.blogspot.com/
# http://twitter.com/ulfbjo
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
##############################################################################
[T4Scaffolding.Scaffolder(Description = "Enter a description of CodePlanner.JS.KnockoutVM.For here")][CmdletBinding()]
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
if (!$foundModelType) { return }

##############################################################
# Create the ko-viewmodel
##############################################################
$outputPath = "js\"+$foundModelType.Name+"ViewModel"

$pluralName = Get-PluralizedWord $foundModelType.Name

Add-ProjectItemViaTemplate $outputPath -Template KoViewModel `
	-Model @{ 	
	DataType = [MarshalByRefObject]$foundModelType;	
	DataTypeName = $foundModelType.Name;
	PluralName = $pluralName
	} `
	-SuccessMessage "Added KoViewModel for $ModelType {0}" `
	-TemplateFolders $TemplateFolders -Project $mvcProjectName -CodeLanguage $CodeLanguage -Force:$Force

try{
	$file = Get-ProjectItem "$($outputPath).js" -Project $mvcProjectName
	$file.Open()
	$file.Document.Activate()	
	$DTE.ExecuteCommand("Edit.FormatDocument", "")
	$DTE.ActiveDocument.Save()
}catch {

}