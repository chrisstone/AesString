# AesString Module
> A PowerShell module to Encrypt and Decrypt Strings with Microsoft CNG AES

[![AppVeyor Build][appv-b-img]][appv-url]
[![PSG Version][psg-v-img]][psg-url]
[![PSG Downloads][psg-dt-img]][psg-url]


## Installation

```powershell
Install-Module -Name AesString
```

Use `-AllowPrerelease` to install 'devel' versions (expect bugs).


## Quick Start

```powershell
Import-Module -Name AesString
$R = Protect-AesString -Key 'gAAAAAAAAAAAAAAAAAAAAA==' -String 'Protect this string.'
Unprotect-AesString -Key 'gAAAAAAAAAAAAAAAAAAAAA==' @R
```

## More Typical Usage

Use ECC Key-pairs to derive a shared key for AES

```powershell
## Alice needs to publish a Public Key
# Creation parameter to allow Exporting
$keyParam = New-Object System.Security.Cryptography.CngKeyCreationParameters
$keyParam.ExportPolicy  = [System.Security.Cryptography.CngExportPolicies]::AllowPlaintextExport
# Create the private key
$aliceKey = [System.Security.Cryptography.CngKey]::Create([System.Security.Cryptography.CngAlgorithm]::ECDiffieHellmanP256, 'aliceKey', $keyParam)

# Get the Base64-Encoded keys; send the Public key to Bob
# Keep the private key well protected, it's not encrypted or otherwise protected in this format.
$alicePrivate = [System.Convert]::ToBase64String($aliceKey.Export([System.Security.Cryptography.CngKeyBlobFormat]::EccPrivateBlob))
$alicePublic = [System.Convert]::ToBase64String($aliceKey.Export([System.Security.Cryptography.CngKeyBlobFormat]::EccPublicBlob))

#--------------------------------------------------------------------

## Bob sends
# Open the Alice key from the Base64-Encoded Public Key
$aliceKey = [System.Security.Cryptography.CngKey]::Import([System.Convert]::FromBase64String($alicePublic), [System.Security.Cryptography.CngKeyBlobFormat]::EccPublicBlob)

# If Bob already has a key, open it. Otherwise create a new key.
Try {
	$bobKey = [System.Security.Cryptography.CngKey]::Open('bobKey')
} Catch {
	If ($null -eq $MyKey) {
		$keyParam = New-Object System.Security.Cryptography.CngKeyCreationParameters
		$keyParam.ExportPolicy  = [System.Security.Cryptography.CngExportPolicies]::AllowExport
		$bobKey = [System.Security.Cryptography.CngKey]::Create([System.Security.Cryptography.CngAlgorithm]::ECDiffieHellmanP256, 'bobKey', $keyParam)
	} else {
		Throw 'Error in key open or create'
	}
}
$bobPublic = [System.Convert]::ToBase64String($bobKey.Export([System.Security.Cryptography.CngKeyBlobFormat]::EccPublicBlob))

# Derive a shared secret from the keys
[System.Security.Cryptography.ECDiffieHellmanCng]$ECDH = New-Object System.Security.Cryptography.ECDiffieHellmanCng($bobKey)
$SharedKey = $ECDH.DeriveKeyMaterial($aliceKey)

# Encrypt
$encryptedMessage = Protect-AesString -Key $SharedKey -String "Top Sneaky"

#--------------------------------------------------------------------

## Alice receives
# Open the Bob key from the Base64-Encoded Public Key
$bobKey = [System.Security.Cryptography.CngKey]::Import([System.Convert]::FromBase64String($bobPublic), [System.Security.Cryptography.CngKeyBlobFormat]::EccPublicBlob)

# Alice re-opens her key or imports it from the string
$aliceKey = [System.Security.Cryptography.CngKey]::Open('aliceKey')
$aliceKey = [System.Security.Cryptography.CngKey]::Import([System.Convert]::FromBase64String($alicePrivate), [System.Security.Cryptography.CngKeyBlobFormat]::EccPrivateBlob)

# Derive a shared secret from the keys
[System.Security.Cryptography.ECDiffieHellmanCng]$ECDH = New-Object System.Security.Cryptography.ECDiffieHellmanCng($aliceKey)
$SharedKey = $ECDH.DeriveKeyMaterial($bobKey)

# Decrypt
$decryptedMessage = Unprotect-AesString -Key $SharedKey @encryptedMessage

Write-Output $decryptedMessage
```

## Release History

* 0.1.x
    * Work in Progress - Keep your expectations low, very low


## Documentation

TODO Documentation


## Contributing

1. Fork it (<https://github.com/chrisstone/AesString/fork>)
2. Create your branch (`git checkout -b feature/fooBar`)
3. Commit your changes (`git commit -am 'Add some fooBar'`)
4. Push to the branch (`git push origin feature/fooBar`)
5. Create a new Pull Request

Branches

| Naming    | Description               | CI        | Pester    |
|-----------|---------------------------|-----------|-----------|
| master    | Stable releases           | PSGallery | Required  |
| devel     | Prereleases               | PSGallery | Required  |
| feature/* | Feature development       | None      | Voluntary |
| issue/*   | Fixes for Problem Reports | None      | Voluntary |


<!-- Defines -->
[appv-b-img]:	https://img.shields.io/appveyor/build/chrisstone/AesString.svg
[appv-url]:		https://ci.appveyor.com/project/chrisstone/aesstring
[psg-v-img]:	https://img.shields.io/powershellgallery/v/AesString.svg
[psg-dt-img]:	https://img.shields.io/powershellgallery/dt/AesString.svg
[psg-url]:		https://www.powershellgallery.com/packages/AesString
