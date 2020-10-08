<#
.SYNOPSIS
  Encrypts a string with AES
#>

Function Protect-AesString {
	[CmdletBinding()]
	[OutputType([System.Collections.Hashtable])]
	Param (
		[Parameter(Mandatory=$true)]
		[Object]
		$Key,

		[Parameter(Mandatory=$false)]
		[Alias("InitV")]
		[Object]
		$InitializationVector,

		[Parameter(Mandatory=$false)]
		[System.Security.Cryptography.CipherMode]
		$Mode = [System.Security.Cryptography.CipherMode]::CBC,

		[Parameter(Mandatory=$true)]
		[string]
		$String
	)

	# Create CSP
	$AesCsp = New-Object System.Security.Cryptography.AesCryptoServiceProvider

	# Setup
	Switch ($Key.GetType().Name) {
		'String'	{ $AesCsp.Key = [System.Convert]::FromBase64String($Key); Break }
		'Byte[]'	{ $AesCsp.Key = $Key; Break }
		Default		{ Throw "Key must be a String or ByteArray" }
	}
	If ($PSBoundParameters.ContainsKey('InitializationVector')) {
		Switch ($InitializationVector.GetType().Name) {
			'String'	{ $AesCsp.IV = [System.Convert]::FromBase64String($InitializationVector); Break }
			'Byte[]'	{ $AesCsp.IV = $InitializationVector; Break }
			Default		{ Throw "Initialization Vector must be a String or ByteArray" }
		}
	} Else {
		$AesCsp.GenerateIV()
	}
	$AesCsp.Mode	= $Mode

	# Encrypt
	$UnencryptedBytes	= [System.Text.Encoding]::UTF8.GetBytes($String)
	$EncryptedBytes	= $AesCsp.CreateEncryptor().TransformFinalBlock($UnencryptedBytes, 0, $UnencryptedBytes.Length)

	$R = @{
		'InitV' = [System.Convert]::ToBase64String($AesCsp.IV);
		'Mode' = $AesCsp.Mode.ToString();
		'Cipher' = [System.Convert]::ToBase64String($EncryptedBytes)
	}

	# Cleanup
	$AesCsp.Dispose()

	Return $R
}

Export-ModuleMember -Function Protect-AesString
