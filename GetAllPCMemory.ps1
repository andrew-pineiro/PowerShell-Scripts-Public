[CmdletBinding()]
param(
	# AD SearchBase paramter. Structered like OU=OU,DC=DC,DC=DC
	[Parameter(Position=0,mandatory=$true)]
	[string] $SearchBase,
	
	[Alias('v')]
	[switch] $VerboseOutput,

	# When there is no reply from the PC it will return 0 GB. 
	# Supplying -a/--IncludeOffline will show those as well
	[Alias('a')]
	[switch] $IncludeOffline,
	
	# Switch to enable outputting the results to CSV
	[Alias('o')]
	[switch] $Output,
	
	# Memory Gigabyte threshold for outputting green text
	[int] $Threshold = 8
)
#Requires -Modules ActiveDirectory

$outputFile = ".\Memlist.csv"
$pcList = (Get-ADComputer -Filter * -SearchBase $searchBase | Select-Object Name).Name
$results = [System.Collections.ArrayList]@()
foreach($pc in $pcList) {
    $totalMemShorthand = 0
    try {
        $totalMemShorthand = (Get-CimInstance Win32_PhysicalMemory -ComputerName $pc  -ErrorAction:Stop | Measure-Object -Property capacity -Sum).sum /1gb
		if($VerboseOutput) {
			[System.ConsoleColor] $color = switch ($totalMemShorthand) {
				{$totalMemShorthand -gt $Threshold} {"GREEN"}
				default {"WHITE"}
			}
			Write-Host "$pc - $totalMemShortHand GB" -ForegroundColor $color
		}
    } catch {
		if($IncludeOffline) {
			Write-Host "$pc - 0 GB" -ForegroundColor Red
		}
        Write-Debug "Unable to connect to $pc"
    }
    [void]$results.Add("$pc,$totalMemShorthand") 
}
if($Output) {
	$results | Export-Csv $outputFile
	Write-Host "Output to $outputFile"
}
