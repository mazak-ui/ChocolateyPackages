﻿$ErrorActionPreference = 'Stop'
$toolsDir       = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$packageName    = 'hp-universal-print-driver-pcl' 
$url            = 'https://ftp.hp.com/pub/softlib/software13/COL40842/ds-99353-23/upd-pcl6-x32-7.0.0.24832.exe'
$checksum       = '746D1EACADD2C4502E5C403724F43DA9FE06B0CB20FD172F9AD90EC3618A6D7F'
$url64          = 'https://ftp.hp.com/pub/softlib/software13/COL40842/ds-99374-23/upd-pcl6-x64-7.0.0.24832.exe'
$checksum64     = 'B6AA40D5A55946EE974E00E197F6AE00C0A397000E08D43851241E37D899E670'
$softwareName   = ''
$fileLocation   = "$toolsDir\unzippedfiles\install.exe"

# Make sure Print Spooler service is up and running stolen from cutepdf package.
try {
  $serviceName = 'Spooler'
  $spoolerService = Get-WmiObject -Class Win32_Service -Property StartMode,State -Filter "Name='$serviceName'"
  if ($null -eq $spoolerService) { throw "Service $serviceName was not found" }
  Write-Host "Print Spooler service state: $($spoolerService.StartMode) / $($spoolerService.State)"
  if ($spoolerService.StartMode -ne 'Auto' -or $spoolerService.State -ne 'Running') {
    Set-Service $serviceName -StartupType Automatic -Status Running
    Write-Host 'Print Spooler service new state: Auto / Running'
  }
} catch {
  Write-Warning "Unexpected error while checking Print Spooler service: $($_.Exception.Message)"
}

New-Item $fileLocation -Type directory | Out-Null

$packageArgs = @{
  packageName    = $packageName
  unzipLocation  = "$toolsDir\unzippedfiles"
  fileType       = 'ZIP' 
  url            = $url
  checksum       = $checksum
  checksumType   = 'sha256'
  url64          = $url64
  checksum64     = $checksum64
  checksumType64 = 'sha256'  
}

Install-ChocolateyZipPackage @packageArgs 

$packageArgs = @{
  packageName    = $packageName
  fileType       = 'EXE'
  file           = $fileLocation
  silentArgs     = '/dm /nd /npf /q /h'
  validExitCodes = @(0, 3010, 1641)
  softwareName   = $softwareName
}
 
Install-ChocolateyInstallPackage @packageArgs

Remove-Item "$toolsDir\unzippedfiles" -Recurse | Out-Null
