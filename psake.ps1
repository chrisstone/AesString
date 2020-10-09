#### By Chris Stone <chris.stone@nuwavepartners.com>
# PSake makes variables declared here available in other scriptblocks
# Init some things
Properties {

	$TimeStamp = (Get-Date).ToUniversalTime() | Get-Date -UFormat "%Y%m%d-%H%M%SZ"

	# Find the build folder based on build system
	$ProjectRoot = $ENV:BHProjectPath
	If (-not $ProjectRoot) {
		$ProjectRoot = Resolve-Path "$PSScriptRoot\.."
	}

	$Verbose = @{}
	If ($ENV:BHCommitMessage -match "!verbose") {
		$Verbose = @{ Verbose = $True }
	}

}

TaskSetup {

	Write-Output "Task $TaskName ".PadRight(70,'-')

}

Task Default -depends Test

Task Init {

	Set-Location $ProjectRoot
	"Build System Details:"
	Get-Item ENV:BH*

}

Task Test -depends Init  {

	# Testing links on github requires >= tls 1.2
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

	# Gather test results. Store them in a variable and file
	Import-Module Pester
	$PesterConf = [PesterConfiguration]@{
		Run = @{
			Path = "$ProjectRoot\Tests"
			PassThru = $true
		}
		TestResult = @{
			Enabled = $true
			OutputPath = ("TestResult_{0}.xml" -f $TimeStamp)
			OutputFormat = "NUnitXml"
		}
	}
	$TestResults = Invoke-Pester -Configuration $PesterConf

	# In Appveyor?  Upload our tests! #Abstract this into a function?
	If ($ENV:BHBuildSystem -eq 'AppVeyor') {
		(New-Object 'System.Net.WebClient').UploadFile(
			"https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)",
			$PesterConf.TestResult.OutputPath.Value )
	}

	# Cleanup
	Remove-Item -Path $PesterConf.TestResult.OutputPath.Value -Force -ErrorAction SilentlyContinue

	# Failed tests?
	# Need to tell psake or it will proceed to the deployment. Danger!
	If ($TestResults.FailedCount -gt 0) {
		Write-Error "Failed '$($TestResults.FailedCount)' tests, build failed"
	}

}

Task Build -depends Test {

	Write-Output "Updating Module Manifest:"

	# Load, read, update the psd1 FunctionsToExport, AliasesToExport; from BuildHelpers
	Write-Output "`Functions"
	Set-ModuleFunction
	Write-Output "`Aliases"
	Set-ModuleAlias

	# Set the Prerelease string, or remove
	Write-Output "`tPrerelease Metadata"
	If ($env:BHBranchName -eq 'master') {
		Set-Content -Path $env:BHPSModuleManifest -Value (Get-Content -Path $env:BHPSModuleManifest | Select-String -Pattern 'Prerelease' -NotMatch)
	} else {
		Update-Metadata -Path $env:BHPSModuleManifest -PropertyName Prerelease -Value "PRE$(($env:BHCommitHash).Substring(0,7))"
	}

	# Set build number in manifest
	Write-Output "`tVersion Build"
	[Version] $Ver = Get-Metadata -Path $env:BHPSModuleManifest -PropertyName 'ModuleVersion'
	Update-Metadata -Path $env:BHPSModuleManifest -PropertyName 'ModuleVersion' -Value (@($Ver.Major,$Ver.Minor,$Env:BHBuildNumber) -join '.')

}

Task Deploy -depends Build {

	$Params = @{
		Path = "$ProjectRoot"
		Force = $true
		Recurse = $false # We keep psdeploy artifacts, avoid deploying those : )
	}
	Write-Output "Invoking PSDeploy"
	Invoke-PSDeploy @Verbose @Params

}
