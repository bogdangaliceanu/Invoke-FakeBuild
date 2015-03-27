# Invoke-FakeBuild
A PowerShell module that makes using FAKE from the cli a little easier

## Summary
This cmdlet aims to make the awesome [FAKE - F# Make](https://github.com/fsharp/FAKE) a bit more discoverable when working at the command line.

The main goal is to spare you from having to remember or look up your build targets. This is achieved by simply analyzing the build script in order to determine which targets are available, and presenting them as tab expansion suggestions.

## Usage
The full name of the cmdlet is *Invoke-FakeBuild*, but the installer sets up the alias *fake* for conveniece.

There are 3 parameters:

1. Target - the name of the target as it appears in the build script
2. BuildScript - the path to the .fsx file you intend to supply to FAKE
3. FakePath - where to find the FAKE executable

*Examples:*
* fake TestRelease
* Invoke-FakeBuild -Target BuildDebug -FakePath .\buildtools -BuildScript .\build.fsx

For more information please see the cmdlet's help: Get-Help Invoke-FakeBuild -ShowWindow

## Licensing
You may use and modify these scripts to suit commercial or non-commercial needs.
