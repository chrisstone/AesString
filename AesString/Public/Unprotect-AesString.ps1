<#
.SYNOPSIS
  Decrypts an AES Cipher to a String
#>

Function Unprotect-AesString {
	[CmdletBinding()]
	[OutputType([System.String])]
	Param (
		[Parameter(Mandatory=$true)]
		[Object]
		$Key,

		[Parameter(Mandatory=$true)]
		[Alias("InitV")]
		[Object]
		$InitializationVector,

		[Parameter(Mandatory=$false)]
		[System.Security.Cryptography.CipherMode]
		$Mode = [System.Security.Cryptography.CipherMode]::CBC,

		[Parameter(Mandatory=$true)]
		[string]
		$Cipher
	)

	# Create CSP
	$AesCsp = New-Object System.Security.Cryptography.AesCryptoServiceProvider

	# Setup
	Switch ($Key.GetType().Name) {
		'String'	{ $AesCsp.Key = [System.Convert]::FromBase64String($Key); Break }
		'Byte[]'	{ $AesCsp.Key = $Key; Break }
		Default		{ Throw "Key must be a String or ByteArray" }
	}
	Switch ($InitializationVector.GetType().Name) {
		'String'	{ $AesCsp.IV = [System.Convert]::FromBase64String($InitializationVector); Break }
		'Byte[]'	{ $AesCsp.IV = $InitializationVector; Break }
		Default		{ Throw "Initialization Vector must be a String or ByteArray" }
	}
	$AesCsp.Mode			= $Mode

	# Decrypt
	$EncryptedBytes	= [System.Convert]::FromBase64String($Cipher)
	$UnencryptedBytes	= $AesCsp.CreateDecryptor().TransformFinalBlock($EncryptedBytes, 0, $EncryptedBytes.Length)

	$R = [System.Text.Encoding]::UTF8.GetString($UnencryptedBytes)

	# Cleanup
	$AesCsp.Dispose()

	Return $R
}

Export-ModuleMember -Function Unprotect-AesString
