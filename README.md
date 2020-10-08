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
[psg-url]:		https://powershellgallery.com/
