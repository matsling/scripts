# Install Crowdstrike - this is meant to be ran as a startup script via GPO

$packageName = "Crowdstrike Windows Sensor"
$returnedPackage = Get-Package | Where-Object { $_.Name -like $packageName } | Select-Object Name

if ($returnedPackage.Name -eq $packageName) {
    Write-Output "Crowdstrike already installed."
    exit
} else {
    C:\WindowsSensor.GovLaggar.exe /install /norestart /quiet CID=<CID here> GROUPING_TAGS=""
    exit
}