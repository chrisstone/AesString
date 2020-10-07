#### By Chris Stone <chris.stone@nuwavepartners.com> v0.0.9 2020-06-12T14:16:25.480Z
# PSake makes variables declared here available in other scriptblocks
# Init some things
Properties {
	# Find the build folder based on build system
	$ProjectRoot = $ENV:BHProjectPath
	If (-not $ProjectRoot) {
		$ProjectRoot = Resolve-Path "$PSScriptRoot\.."
	}

	$Timestamp = Get-Date -UFormat "%Y%m%d-%H%M%S"
	$PSVersion = $PSVersionTable.PSVersion.Major
	$TestFile = "TestResults_PS$PSVersion`_$TimeStamp.xml"
	$lines = '----------------------------------------------------------------------'

	$Verbose = @{}
	If ($ENV:BHCommitMessage -match "!verbose") {
		$Verbose = @{ Verbose = $True }
	}
}

Task Default -depends Test

Task Init {
	$lines
	Set-Location $ProjectRoot
	"Build System Details:"
	Get-Item ENV:BH*
	"`n"
}

Task Test -depends Init  {
	$lines
	"`n`tSTATUS: Testing with PowerShell $PSVersion"

	# Testing links on github requires >= tls 1.2
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
	# Gather test results. Store them in a variable and file
	$TestResults = Invoke-Pester -Path $ProjectRoot\Tests -PassThru -OutputFormat NUnitXml -OutputFile "$ProjectRoot\$TestFile"

	# In Appveyor?  Upload our tests! #Abstract this into a function?
	If ($ENV:BHBuildSystem -eq 'AppVeyor') {
		(New-Object 'System.Net.WebClient').UploadFile(
			"https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)",
			"$ProjectRoot\$TestFile" )
	}

	Remove-Item "$ProjectRoot\$TestFile" -Force -ErrorAction SilentlyContinue
	# Failed tests?
	# Need to tell psake or it will proceed to the deployment. Danger!
	If ($TestResults.FailedCount -gt 0) {
		Write-Error "Failed '$($TestResults.FailedCount)' tests, build failed"
	}
	"`n"
}

Task Build -depends Test {
	$lines

	# Load, read, update the psd1 FunctionsToExport, AliasesToExport; from BuildHelpers
	Write-Output "Updating Functions"
	Set-ModuleFunction

	Write-Output "Updating Aliases"
	Set-ModuleAlias

	Write-Output "Updating Prerelease Metadata"
	# Set the Prerelease string, or remove
	If ($env:BHBranchName -eq 'master') {
		Set-Content -Path $env:BHPSModuleManifest -Value (Get-Content -Path $env:BHPSModuleManifest | Select-String -Pattern 'Prerelease' -NotMatch)
	} else {
		Update-Metadata -Path $env:BHPSModuleManifest -PropertyName Prerelease -Value "PRE$(($env:BHCommitHash).Substring(0,7))"
	}

	[Version] $Ver = Get-Metadata -Path $env:BHPSModuleManifest -PropertyName 'ModuleVersion'
	Update-Metadata -Path $env:BHPSModuleManifest -PropertyName 'ModuleVersion' -Value (@($Ver.Major,$Ver.Minor,$Env:BHBuildNumber) -join '.')

}

Task Deploy -depends Build {
	$lines

	$Params = @{
		Path = "$ProjectRoot"
		Force = $true
		Recurse = $false # We keep psdeploy artifacts, avoid deploying those : )
	}
	Write-Output "Invoking PSDeploy"
	Invoke-PSDeploy @Verbose @Params
}
