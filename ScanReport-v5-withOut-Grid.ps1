# Programmer: Laban Seay
# Date: 2019-04-26
# Nesses Debug CSV Source File Parser
# This program uses Regex .net assembles to parse the nesses_debug.csv source file.
# [System.GC]::Collect()
# Clear-Host
$ErrorActionPreference = 'silentlycontinue'
# Show an Open File Dialog and return the file selected by the user.
function Read-OpenFileDialog([string]$WindowTitle, [string]$InitialDirectory, [string]$Filter = "All files (*.*)|*.*", [switch]$AllowMultiSelect)
{
    Add-Type -AssemblyName System.Windows.Forms
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openFileDialog.Title = $WindowTitle
    if (![string]::IsNullOrWhiteSpace($InitialDirectory)) { $openFileDialog.InitialDirectory = $InitialDirectory }
    $openFileDialog.Filter = $Filter
    if ($AllowMultiSelect) { $openFileDialog.MultiSelect = $true }
    $openFileDialog.ShowHelp = $false    # Without this line the ShowDialog() function may hang depending on system configuration and running from console vs. ISE.
    $openFileDialog.ShowDialog() > $null
    if ($AllowMultiSelect) { return $openFileDialog.Filenames } else { return $openFileDialog.Filename }
}


$filePath = Read-OpenFileDialog -WindowTitle "Select the CSV or TXT File for parsing: " -InitialDirectory 'C:\' -Filter "CSV file (*.csv)|*.csv| TXT files (*.txt)|*.txt" -AllowMultiSelect false -Title "Select csv/txt file to read a file"

### Laban Seay: added code to check that a file was selected.
if (![string]::IsNullOrEmpty($filePath)){Write-Host "You selected the file: $filePath"}
else{"You did not select a file...Please select a CSV or TXT file."}

$input_file = $filePath
$input_csv =@{}

<#================================= Engine =================#>
try{

 $nl = [Environment]::NewLine
  $input_csv = Import-Csv $input_file |    
    Select-Object "Plugin", "IP Address", "Repository", "MAC Address", "DNS Name", "NetBIOS Name", "Last Observed", 
        @{Label = 'Plugin Text: ScannerIP'; Expression = {[regex]::Match($_.'Plugin Text','Scanner IP : (\d+\.\d+\.\d+\.\d+)').groups[1].value}}, 
        @{Label = 'Plugin Text: Calc_Scan_Duration'; Expression = {[regex]::Match($_.'Plugin Text', 'Scan duration : (\d+) sec').groups[1].value/60}},
        @{Label = 'Plugin Text: Scan Duration/Sec'; Expression = {[regex]::Match($_.'Plugin Text', 'Scan duration : (.*)').groups[1].value}},  
        @{Label = 'Plugin Text: Calc_Scan_Duration'; Expression = {[regex]::Match($_.'Plugin Text', 'Scan duration : (\d+) sec').groups[1].value/60}},
        @{Label = 'Plugin Text: Scan Policy'; Expression = {[regex]::Match($_.'Plugin Text', 'Scan policy used : (.*)').groups[1].value}}, 
        @{Label = 'Plugin Text: Safe Checks'; Expression = {[regex]::Match($_.'Plugin Text', 'Safe checks : (.*)').groups[1].value}},
        @{Label = 'Plugin Text: Scan Start Date'; Expression = {[regex]::Match($_.'Plugin Text', 'Scan Start Date : (.*)').groups[1].value}},
        @{Label = 'Plugin Text: Credentialed_Scan'; Expression = {[regex]::Match($_.'Plugin Text', 'Credentialed_Scan: (.*)').groups[1].value}},
        @{Label = 'Plugin Text: Credentialed checks'; Expression = {[regex]::Match($_.'Plugin Text', 'Credentialed checks (.*)').groups[1].value}},
        @{Label = 'Plugin Text: Method'; Expression = {[regex]::Match($_.'Plugin Text', 'Method : (.*)').groups[1].value}},
        @{Label = 'Plugin Text: Remote operating system'; Expression = {[regex]::Match($_.'Plugin Text', 'Remote operating system : (.*)').groups[1].value}},
        @{Label = 'Plugin Text: Plugin Output'; Expression = {[regex]::Match($_.'Plugin Text', 'Plugin Output: (.*)').groups[1].value}} | Out-GridView
}catch {
   Write-Host $_.Exception.Message -ForegroundColor Green
} finally {
    Write-Host $_.Exception.Message -ForegroundColor Blue
}


