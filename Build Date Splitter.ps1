<#
Franklin Durbin
Split Build Dates Into Buckets
May 18, 2022

This is a script that will be ran following the scheduling pass/DDL. If file structures are set up properly, simple
array changes will be the only thing required for this script to work properly. The script will look at your build date,
and detect which buckets it needs to parse out. This is setup to seperate into two bucket sizes.
#>

#Lines
$mfgLines = @(
    'TR1',
    'TR2',
    'DH1',
    'DH2',
    'SH1',
    'FX1'
)

#Parts downloaded
$parts = @(
    'Heads',
    'Jambs',
    'Stiles',
    'Rails',
    'MeetRails',
    'TBars',
    'StiffenerBars'
)

#Parts the framesaw uses
$frameSawParts = @(
    'Heads',
    'Jambs'
)

#Parts the sash saw uses
$sashSawParts = @(
    'Stiles',
    'Rails'
)

#Parts the utility saw uses
$utilitySawParts = @(
    'MeetRails',
    'TBars',
    'StiffenerBars'
)

#List of possible buckets
$buckets = @(
    'A','B',
    'C','D',
    'E','F',
    'G','H',
    'I','J',
    'K','L',
    'M','N',
    'O','P',
    'Q','R',
    'S','T',
    'U','V',
    'W','X',
    'Y','Z',
    'AA','AB',
    'AC','AD',
    'AE','AF',
    'AG','AH',
    'AI','AJ',
    'AK','AL',
    'AM','AN',
    'AO','AP',
    'AQ','AR',
    'AS','AT',
    'AU','AV',
    'AW','AX',
    'AY','AZ'
)

#Defualt path that the DDL files will be sent to
$schedulingPath = 'C:\Test\ftproot\Lineal\Scheduling\'

    #Loop to go through every line
    for ($j = 0; $j -lt $mfgLines.Count; $j++) {
        #Loop to go through every part
        for ($ii = 0; $ii -lt $parts.Count; $ii++) {
            #If statements to assign the machine variable based on parts
            if ($parts[$ii] -in $frameSawParts) {
                $machine = 'Frame_Saw'
            }
            elseif ($parts[$ii] -in $sashSawParts) {
                $machine = 'Sash_Saw'
            }
            elseif ($parts[$ii] -in $utilitySawParts) {
                $machine = 'Utility_Saw'
            }
            #Loop through buckets
            for ($x = 0; $x -lt $buckets.Count; $x += 2) {
                #Determining search value and finding the file based on Line/Part
                $fileSearch = '*' + $mfgLines[$j] + '*_' + $parts[$ii] + '*'
                $oldFileName = Get-ChildItem $schedulingPath -Recurse -Include $fileSearch | Select Name
                #If search yeilded results, then procede to generate file.
                if ($oldFileName) {
                    Write-Host $oldFileName.Name
                    #Array to store the contents of the files in
                    $oldFileContents = Get-Content -Path ($schedulingPath+$oldFileName.Name)
                    #If the file contains the bucket then generate file
                    if (($oldFileContents -Like '*' + $mfgLines[$j] + '-' + $buckets[$x] + '-*') -or ($oldFileContents -Like '*' + $mfgLines[$j] + '-' + $buckets[$x + 1] + '-*')) {
                        #Create a new name for the file eliminating extra characters and appending buckets
                        $newFileName = $oldFileName.Name.SubString(0,$oldFileName.Name.Length -13) + $buckets[$x] + '_' + $buckets[$x + 1] + '.csv'
                        #Determine where the file needs to go based on Line/Machine/Part and place one in the bkup location
                        $newFilePath = 'C:\Test\ftproot\lineal\' + $mfgLines[$j] + '\' + $machine + '\' + $parts[$ii]
                        $newFilePathBkup = $newFilePath + '\bkup'
                        #Loop to go through the file 
                        for ($i = 0; $i -lt $oldFileContents.Count; $i++) {
                            if ($i -eq 0) {
                                $oldFileContents[$i] | Out-File -FilePath $newFilePath\$newFileName
                                $oldFileContents[$i] | Out-File -FilePath $newFilePathBkup\$newFileName
                            }
                            #If the line contains either of the 2 buckets then append to the file
                            if (($oldFileContents[$i] -Like '*' + $mfgLines[$j] + '-' + $buckets[$x] + '-*')  -or ($oldFileContents[$i] -Like '*' + $mfgLines[$j] + '-' + $buckets[$x + 1] + '-*')){
                                $oldFileContents[$i] | Out-File -Append $newFilePath\$newFileName
                                $oldFileContents[$i] | Out-File -Append $newFilePathBkup\$newFileName
                            }
                        }   
                    }  
                } 
            }   
        }
    }

    #Delete files in scheduling folder
    Get-ChildItem $schedulingPath | Remove-Item -Recurse