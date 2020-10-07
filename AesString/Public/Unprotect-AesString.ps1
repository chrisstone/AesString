<#
.SYNOPSIS
  Decrypts an AES Cipher to a String
#>

Function Unprotect-AesString {
	[CmdletBinding()]
	[OutputType([System.String])]
	Param (
		[Parameter(Mandatory=$true)]
		[Object]	$Key,
		[Parameter(Mandatory=$true)]
		[Object]	$IV,
		[Parameter(Mandatory=$false)]
		[System.Security.Cryptography.CipherMode]	$Mode = [System.Security.Cryptography.CipherMode]::CBC,
		[Parameter(Mandatory=$true)]
		[string]	$Cipher
	)

	$AesCsp = New-Object System.Security.Cryptography.AesCryptoServiceProvider

	# Setup
	Switch ($Key.GetType()) {
		[string]:			{ $AesCsp.Key = [System.Convert]::FromBase64String($Key); Break }
		[System.Byte[]]:	{ $AesCsp.Key = $Key; Break }
		Default:			{ Throw "Key must be a String or ByteArray" }
	}
	Switch ($IV.GetType()) {
		[string]:			{ $AesCsp.IV = [System.Convert]::FromBase64String($IV); Break }
		[System.Byte[]]:	{ $AesCsp.IV = $IV; Break }
		Default:			{ Throw "IV must be a String or ByteArray" }
	}
	$AesCsp.Mode	= $InputObject.Mode

	# Decrypt
	$EncryptedBytes	= [System.Convert]::FromBase64String($InputObject.Cipher)
	$UnencryptedBytes	= $AesCsp.CreateDecryptor().TransformFinalBlock($EncryptedBytes, 0, $EncryptedBytes.Length)

	# Cleanup
	$AesCsp.Dispose()

	Return [System.Text.Encoding]::UTF8.GetString($UnencryptedBytes)
}