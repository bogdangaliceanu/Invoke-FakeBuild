$TargetCompletion = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)

    $BuildScript = 'build.fsx'

    for ($i = 0; $i -lt $commandAst.CommandElements.Count; $i++) {
        if ($commandAst.CommandElements[$i].ParameterName -eq 'BuildScript') {
            $BuildScript = $commandAst.CommandElements[$i + 1].Value
            break
        }
    }

    $TargetMatches = [System.Text.RegularExpressions.Regex]::Matches((Get-Content $BuildScript -Raw), '(?<!//[^\r\n]*)Target\s+@?"(.+?)"')

    $TargetMatches |
    foreach { $_.Groups[1].Value } |
    where { if ($wordToComplete) { $_ -like "$wordToComplete*" } else { $True } } |
    sort |
    foreach {
        New-Object System.Management.Automation.CompletionResult $_, $_, 'ParameterValue', $_
    }
}


if (-not $global:options) {
    $global:options = @{ CustomArgumentCompleters = @{}; NativeArgumentCompleters = @{} }
}
$global:options['CustomArgumentCompleters']['Invoke-FakeBuild:Target'] = $TargetCompletion

$function:tabexpansion2 = $function:tabexpansion2 -replace 'End\r\n{','End { if ($null -ne $options) { $options += $global:options} else {$options = $global:options}'


<#
.SYNOPSIS
Calls the FAKE - F# Make executable to run a target from a build script.

.DESCRIPTION
The Invoke-FakeBuild cmdlet calls the FAKE - F# Make executable to run a target from a build script. Useful features include tab expansion (autocomplete) for Target, which dynamically adapts depending on the specified build script.

.PARAMETER Target
The name of the target from the build script to run.

.PARAMETER FakePath
The path to the Fake executable. This path is probed for a file called 'fake.exe'. If no such file is found, probing is attempted in the \fake\tools subdirectory of this path.

.PARAMETER BuildScript
The path to the build script.

.EXAMPLE
fake TestRelease

.EXAMPLE
Invoke-FakeBuild -Target BuildDebug -FakePath .\buildtools -BuildScript .\build.fsx
#>
Function Invoke-FakeBuild {
    [CmdletBinding()]
    param(
        [string]$Target = '',
        [string]$BuildScript = 'build.fsx',
        [string]$FakePath = 'bin'
    )

    Write-Verbose "Working directory = $(Get-Location)"
    
    If (-not ((Test-Path ($FakePath + '\fake.exe')) -or (Test-Path ($FakePath + '\fake\tools\fake.exe')))) {
        Write-Verbose "Fake was not found"

        If (Test-Path .nuget\NuGet.exe) {
            Write-Verbose "Installing Fake with NuGet"
            .nuget\NuGet.exe install FAKE -OutputDirectory $FakePath -ExcludeVersion
        }
        Else {
            Write-Verbose "NuGet was not found (no .nuget folder with nuget executable inside)"

            If ((Test-Path .paket\paket.bootstrapper.exe) -and (-not (Test-Path .paket\paket.exe))) {
                .paket\paket.bootstrapper.exe
            }
            If (Test-Path .paket\paket.exe) {
                Write-Verbose "Installing Fake with Paket"
                .paket\paket.exe restore group Build
                Copy-Item -Path packages\Build\FAKE -Destination $FakePath -Recurse
            }
            Else {
                Write-Verbose "Paket was not found (no .paket folder with bootstrapper or paket executable inside)"
            }
        }
    }

    If (Test-Path ($FakePath + '\fake.exe')) {
        $FakeExePath = $FakePath + '\fake.exe'
    }
    Else {
        $FakeExePath = $FakePath + '\fake\tools\fake.exe'
    }

    Write-Verbose "Fake exe path = $FakeExePath"

    # Invoke fake.exe
    & $FakeExePath $BuildScript, $Target
}