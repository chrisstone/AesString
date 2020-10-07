<#
.SYNOPSIS
  Encrypts a string with AES
#>

Function Protect-AesString {
	[CmdletBinding()]
	[OutputType([System.Collection.Hashtable])]
	Param (
		[System.Byte[]]								$Key,
		[System.Byte[]]								$IV = $null,
		[System.Security.Cryptography.CipherMode]	$Mode = [System.Security.Cryptography.CipherMode]::CBC,
		[string]									$InputObject
	)

	# Create CSP
	$AesCsp = New-Object System.Security.Cryptography.AesCryptoServiceProvider

	# Setup
	$AesCsp.Key		= $Key
	If ($null -ne $IV) {
		$AesCsp.IV = $IV
	} Else {
		$AesCsp.GenerateIV()
	}
	$AesCsp.Mode	= $Mode

	# Encrypt
	$UnencryptedBytes	= [System.Text.Encoding]::UTF8.GetBytes($InputObject)
	$EncryptedBytes	= $AesCsp.CreateEncryptor().TransformFinalBlock($UnencryptedBytes, 0, $UnencryptedBytes.Length)

	# Cleanup
	$AesCsp.Dispose()

	Return @{
		'IV' = [System.Convert]::ToBase64String($AesCsp.IV);
		'Mode' = $AesCsp.Mode.ToString();
		'Cipher' = [System.Convert]::ToBase64String($EncryptedBytes)
	}
}