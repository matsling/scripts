#
#    This script is meant to be ran as a scheduled task to clear stuck print jobs
#    on your domain print server.
#    Copyright (C) <2026>  <matsling>
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <https://www.gnu.org/licenses/>.

# Logfile
$logFilePath = "C:\"
$logFileName = "printjob.log"

# Function to add lines to logfiles
Function AddLogLine {
    Param ([string]$logstring)
    $logprotoline = "$(Get-Date) $($logstring)"

    Add-Content -Path "$logFilePath$logFileName" -Value $logprotoline -PassThru
}

# test if the log file exists, if not, create it
if (-Not (Test-Path ($logFilePath + $logFileName))) {
    New-Item -Path $logFilePath -Name $logFileName -ItemType "File"
}

# List of Printer Network Names
$printerList = @(
    "example printer name 1",
    "example printer name 2",
)

# Get the jobs for each printer listed above
foreach ($printer in $printerList) {

    # empty array to store jobs
    $foundJobs = @()

    # try to get a list of jobs, if fails, continue to next printer
    $foundJobs += Get-PrintJob -PrinterName $printer

    # if the number of found jobs is greater than zero (this may be redundant)
    if ($foundjobs -and $foundjobs.Count -gt 0) {

        # loop through each individual job
        foreach ($job in $foundjobs) {

            # determine how old the job is
            $age = (Get-Date) - $job.SubmittedTime

            # remove the job if in an error state
            if ($job.JobStatus -match 'Error') {
                AddLogLine "$($printer) $($job.PrinterName) $($job.DocumentName) $($job.SubmittedTime) $($job.JobStatus)"
                Remove-PrintJob -PrinterName $printer -ID $job.ID

                # wait for job to clear
                Start-Sleep -Seconds 3
            }

            # if the job is in printing status but older 15 minutes, remove
            if (($job.JobStatus -match 'Printing') -and ($age.Hours -ne 0 -or $age.Minutes -gt 15)) {
                AddLogLine "$($printer) $($job.PrinterName) $($job.DocumentName) $($job.SubmittedTime) $($job.JobStatus)"
                Remove-PrintJob -PrinterName $printer -ID $job.ID

                # wait for the job to clear
                Start-Sleep -Seconds 3
            } 
            
            # if the job is in normal status but older than one day, remove
            if  ($job.JobStatus -match 'Normal' -and ($age.Days -ne 0)){
                AddLogLine "$($printer) $($job.PrinterName) $($job.DocumentName) $($job.SubmittedTime) $($job.JobStatus)"
                Remove-PrintJob -PrinterName $printer -ID $job.ID

                # wait for the job to clear
                Start-Sleep -Seconds 3
            }

            if ($job.JobStatus -match 'Deleting, Print*' -and ($age.Hours -ne 0 -or $age.Minutes -gt 15)) {
                AddLogLine "$($printer) $($job.PrinterName) $($job.DocumentName) $($job.SubmittedTime) $($job.JobStatus)"
                Restart-Service Spooler
                break
            }
        }
    }
}