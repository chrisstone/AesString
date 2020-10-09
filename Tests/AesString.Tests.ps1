#### By Chris Stone <chris.stone@nuwavepartners.com>


$Module = Get-ChildItem -Filter "*.psm1" -Path (Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)) -Recurse -Depth 1

$Script:ModuleName = ($Module -split '\.')[0]
$Script:ModulePath = Split-Path -Path $Module.FullName -Parent

Import-Module -Name "$ModulePath\$ModuleName.psm1" -Force -ErrorAction SilentlyContinue

$TestVectors = @(
	@{
		Key		= [Byte[]]@(0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00)
		InitV	= [Byte[]]@(0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00)
		Plain	= "This is a Test!"
		Cipher	= "CxIU1TSSu3QfBGGO1VXayA=="
	},
	@{
		Key		= [Byte[]]@(0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00)
		InitV	= [Byte[]]@(0xa3, 0xe2, 0x32, 0x30, 0x13, 0xe9, 0x92, 0xd9, 0x6c, 0x13, 0xf1, 0xab, 0x7c, 0x87, 0x64, 0x31)
		Plain	= "This is a Test!"
		Cipher	= "fTWo3eNpFLnI15Dzgc0FMQ=="
	}
)

#################################### TESTS ####################################
Describe "AesString" {

	Context "Protect-AesString" {

		It "Byte-Byte" -TestCases $TestVectors {
			$ER = Protect-AesString -Key $Key -InitializationVector $InitV -String $Plain
			$ER.Cipher | Should -Be $Cipher
		}

		It "String-Byte" -TestCases $TestVectors {
			$ER = Protect-AesString -Key ([System.Convert]::ToBase64String($Key)) -InitializationVector $InitV -String $Plain
			$ER.Cipher | Should -Be $Cipher
		}

		It "Byte-String" -TestCases $TestVectors {
			$ER = Protect-AesString -Key $Key -InitializationVector ([System.Convert]::ToBase64String($InitV)) -String $Plain
			$ER.Cipher | Should -Be $Cipher
		}

		It "String-String" -TestCases $TestVectors {
			$ER = Protect-AesString -Key ([System.Convert]::ToBase64String($Key)) -InitializationVector ([System.Convert]::ToBase64String($InitV)) -String $Plain
			$ER.Cipher | Should -Be $Cipher
		}

	}

	Context "Unprotect-AesString" {

		It "Byte-Byte" -TestCases $TestVectors {
			$DR = Unprotect-AesString -Key $Key -InitializationVector $InitV -Cipher $Cipher
			$DR | Should -Be $Plain
		}

		It "String-Byte" -TestCases $TestVectors {
			$DR = Unprotect-AesString -Key ([System.Convert]::ToBase64String($Key)) -InitializationVector $InitV -Cipher $Cipher
			$DR | Should -Be $Plain
		}

		It "Byte-Byte" -TestCases $TestVectors {
			$DR = Unprotect-AesString -Key $Key -InitializationVector ([System.Convert]::ToBase64String($InitV)) -Cipher $Cipher
			$DR | Should -Be $Plain
		}

		It "String-Byte" -TestCases $TestVectors {
			$DR = Unprotect-AesString -Key ([System.Convert]::ToBase64String($Key)) -InitializationVector ([System.Convert]::ToBase64String($InitV)) -Cipher $Cipher
			$DR | Should -Be $Plain
		}

	}

	Context "Protect and Unprotect" {

		It "Protect-Unprotect" -TestCases $TestVectors {
			$ER = Protect-AesString -Key $Key -InitializationVector $InitV -String $Plain
			$DR = Unprotect-AesString -Key $Key @ER
			$DR | Should -Be $Plain
		}

	}

}
