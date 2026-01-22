# Uninstall Sophos
$packageName = "Sophos Endpoint Agent"
$returnedPackage = Get-Package | Where-Object { $_.Name -like $packageName } | Select-Object Name

if ($returnedPackage.Name -eq $packageName) {
	Write-Output "Uninstalling Sophos."
	& 'C:\Program Files\Sophos\Sophos Endpoint Agent\SophosUninstall.exe' --quiet
	exit
} else {
	Write-Output "Sophos not found."
	exit
}