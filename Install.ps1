$InstallLocationRoot = $env:PSModulePath -split ';' | where { $_ -like '*Users*Documents\WindowsPowerShell\Modules' }
$InstallLocation = $InstallLocationRoot + '\Invoke-FakeBuild'
Write-Output "Install location = $InstallLocation"

if (-not (Test-Path $InstallLocation)) {
    Write-Output 'Install location does not exist; creating it'
    New-Item $InstallLocation -ItemType directory
}

Copy-Item '.\Invoke-FakeBuild.psm1' $InstallLocation
Write-Output 'Copied module to install location'

if (Test-Path $profile) {
    $ProfileContent = Get-Content $profile

    if (-not ($ProfileContent -contains 'Import-Module Invoke-FakeBuild')) {
        $ProfileContent = $ProfileContent + [Environment]::NewLine + 'Import-Module Invoke-FakeBuild' + [Environment]::NewLine
    }
    if (-not ($ProfileContent -contains 'Set-Alias fake Invoke-FakeBuild')) {
        $ProfileContent = $ProfileContent + [Environment]::NewLine + 'Set-Alias fake Invoke-FakeBuild' + [Environment]::NewLine
    }

    Set-Content $profile -Value $ProfileContent
}
else {
    New-Item $profile -ItemType file -Value ('Import-Module Invoke-FakeBuild' + [Environment]::NewLine + 'Set-Alias fake Invoke-FakeBuild' + [Environment]::NewLine)
}
Write-Output 'Added auto-load and alias instruction to profile'


Write-Output 'Please restart PowerShell for changes to take effect'