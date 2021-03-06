#
# Module manifest for module 'AesString'
# Generated by: Chris Stone <chris@stoneyforest.net>
# Generated on: 10/7/2020
#

@{
	RootModule = 'AesString.psm1'
	ModuleVersion = '0.1.2'
	# CompatiblePSEditions = @()
	GUID = '48dec657-9dce-4833-9243-1a208bf93456'
	Author = 'Chris Stone <chris@stoneyforest.net>'
	Copyright = '(c) 2020 Chris Stone <chris@stoneyforest.net>. All rights reserved.'
	Description = 'A PowerShell module to Encrypt and Decrypt Strings with Microsoft CNG AES'

	FunctionsToExport = @('Protect-AesString', 'Unprotect-AesString')
	CmdletsToExport = @()
	VariablesToExport = '*'
	AliasesToExport = @()

	PrivateData = @{
		PSData = @{

			# Tags applied to this module. These help with module discovery in online galleries.
			# Tags = @()

			# A URL to the license for this module.
			# LicenseUri = ''

			# A URL to the main website for this project.
			# ProjectUri = ''

			# A URL to an icon representing this module.
			# IconUri = ''

			# ReleaseNotes of this module
			# ReleaseNotes = ''

		} # End of PSData hashtable

	} # End of PrivateData hashtable

}
