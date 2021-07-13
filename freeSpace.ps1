﻿##This script will check for old plots if there is not enough space left after a given time. 
##This way, you can hold your solo plots as long as possible.

$folders = New-Object Collections.Generic.List[String]
$folders.Add("\PlotsFolder") #repeat this line for each Folder
$drive = "C:" #drive to check
$delaySeconds = 10 #delay for checking in seconds
$mustBeOlderThan = "14.07.2021"  #date your first pooling plots were written on this drive (or ever). check the format to match your local format
$minGBLeft = 102 # space that must be left for the next plot to be copied successfully

while(1 -eq 1){
    Write-Host "Checking free space"
    $cim = Get-CimInstance -ClassName Win32_LogicalDisk | Select-Object -Property DeviceID,FreeSpace
    $freeSpaces = Get-CimInstance -ClassName Win32_LogicalDisk | Select-Object -Property DeviceID,@{'Name' = 'FreeSpace (GB)'; Expression= { [int]($_.FreeSpace / 1GB) }}
    $currentDrive = $freeSpaces | Where {$_.DeviceID -eq $drive}
    if($currentDrive."FreeSpace (GB)" -lt $minGBLeft){
        Write-Host "Not enough free space for plots left. Trying to find an old plot."
        $deleted = ""
        foreach($folder in $folders){
            $files = Get-ChildItem -Path $drive$folder -Filter *.plot -File -Name 
            foreach($file in $files){
                if($deleted -eq "" -and $file.LastWriteTime -lt $mustBeOlderThan){
                    del $drive$folder"\"$file
                    $deleted = $file
                    Write-Host "Deleted "$deleted"."
                }
            }
        }
        if($deleted -eq ""){
            Write-Host "No item to delete was found. Please change the config or switch to another drive."
        }
    }
    else{
        Write-Host "There is still enough space left. Checking again in " $delaySeconds " seconds."
    }
    
    Start-Sleep -s $delaySeconds

}


