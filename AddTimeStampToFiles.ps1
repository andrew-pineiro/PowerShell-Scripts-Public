<#
    PURPOSE:
        Rename all files in a directory to include the timestamp based on the LastWriteTime of that file.

    REQUIREMENTS:
        Populate `$RootDirectory` variable with the correct directory
            and the `$Delimeter` variable with a character to split the file name and timestamp by. 
            
    AUTHOR:
        Andrew Pineiro
#>

$RootDirectory = "H:\TestZone\Test"                                                                     # Root Directory where files are saved.
$Delimeter = '_'                                                                                        # Delimeter for recreating file name (goes between file name and timestamp)

Get-ChildItem $RootDirectory | Where-Object {$_.PSIsContainer -eq $false}  
    | Select-Object Name, LastWriteTime | % {
        $TimeStamp = $_.LastWriteTime.ToString("yyyyMMddHHmmss")                                        # Convert LastWriteTime to a timestamp value
        $OriginalFile = $_.Name                                                                         # Capture original file full name
        $OriginalExtension = [System.IO.Path]::GetExtension($OriginalFile)                              # Capture original extension of the file
        $NewFileName = $OriginalFile
        if ($OriginalFile -like "*$TimeStamp*") {                                                       # Check if timestamp is already present
            continue                                                                                    # If present, moves to next item
        }

        $WorkingFileName  = $OriginalFile.Substring(0,$OriginalFile.IndexOf('.'))                       # Capture original file name, no extension
        if ($OriginalFile -match '\(\d+\)') {                                                            # Check if file has a (i) in the name
            $WorkingFileName = $WorkingFileName.Substring(0,$WorkingFileName.IndexOf('('))              # Captures the name of the file, without the (i)
        }
        
        $NewFileName = $WorkingFileName+$Delimeter+$TimeStamp+$OriginalExtension                        # Rebuild file name with timestamp
        Rename-Item -Path "$RootDirectory\$OriginalFile" -NewName $NewFileName                          # Rename the file to the new name
        Write-Host "[+] $OriginalFile => $NewFileName" -f Cyan                                          
    }
