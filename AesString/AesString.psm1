<#
.SYNOPSIS
    AesString entry script
#>
#requires -Version 2.0

$ModuleHome = Split-Path -Path $MyInvocation.MyCommand.Path -Parent

. "$ModuleHome\Public\Protect-AesString.ps1"
. "$ModuleHome\Public\Unprotect-AesString.ps1"
