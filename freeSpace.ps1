##This script will check for old plots if there is not enough space left after a given time. 
##This way, you can hold your solo plots as long as possible.

$folders = New-Object Collections.Generic.List[String]
$folders.Add("\PoolDir") #repeat this line for each subfolder. "\" for root folder.
$drive = "C:" #drive to check
$delaySeconds = 1800 #delay for checking in seconds
$mustBeOlderThan = "07.07.2021"  #date your first pooling plots were written on this drive (or ever). check the format to match your local format
$minGBLeft = 102 # space that must be left for the next plot to be copied successfully
$dateFormat = "dd.MM.yyyy HH:mm:ss" # each output line will have a timestamp at the beginning of the first line. 
                                 # head to https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/get-date?view=powershell-7.1
                                 #to get your format   

while(1 -eq 1){ 
    Write-Host (Get-Date -Format $dateFormat)" Checking free space"
    $cim = Get-CimInstance -ClassName Win32_LogicalDisk | Select-Object -Property DeviceID,FreeSpace
    $freeSpaces = Get-CimInstance -ClassName Win32_LogicalDisk | Select-Object -Property DeviceID,@{'Name' = 'FreeSpace (GB)'; Expression= { [int]($_.FreeSpace / 1GB) }}
    $currentDrive = $freeSpaces | Where {$_.DeviceID -eq $drive}
    if($currentDrive."FreeSpace (GB)" -lt $minGBLeft){
        Write-Host (Get-Date -Format $dateFormat) " Not enough free space left for new plots. Trying to find an old plot."
        $deleted = ""
        foreach($folder in $folders){
            $files = Get-ChildItem -Path $drive$folder -Filter *.plot -File -Name 
            foreach($file in $files){
                if($deleted -eq "" -and $file.LastWriteTime -lt $mustBeOlderThan){
                    del $drive$folder"\"$file
                    $deleted = $file
                    Write-Host (Get-Date -Format $dateFormat) " Deleted "$deleted"."
                }
            }
        }
        if($deleted -eq ""){
            Write-Host "*******************************"
            Write-Host "*******************************"
            Write-Host (Get-Date -Format $dateFormat)" No item to delete was found. Please change the config or switch to another drive."
            Write-Host "*******************************"
            Write-Host "*******************************"
        }
    }
    else{
        Write-Host (Get-Date -Format $dateFormat) " There is still enough space left. Will check again in " $delaySeconds " seconds."
    }
    
    Start-Sleep -s $delaySeconds

}





