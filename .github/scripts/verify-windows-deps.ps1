<#
.SYNOPSIS
  Verifies a Windows plugin binary is x64 and that every DLL it imports
  is either a Windows system DLL or shipped next to the binary.

.PARAMETER Path
  Path to the .4DX to check.
#>
param(
  [Parameter(Mandatory = $true)][string]$Path
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
  Write-Error "Binary not found: $Path"
  exit 1
}
$Path = (Resolve-Path -LiteralPath $Path).Path
$binDir = Split-Path -Parent $Path

# PE machine must be IMAGE_FILE_MACHINE_AMD64 (0x8664)
$bytes = [System.IO.File]::ReadAllBytes($Path)
if ($bytes.Length -lt 0x40 -or $bytes[0] -ne 0x4D -or $bytes[1] -ne 0x5A) {
  Write-Error "$Path is not a PE file (missing MZ header)"
  exit 1
}
$peOffset = [BitConverter]::ToInt32($bytes, 0x3C)
if ($peOffset -le 0 -or ($peOffset + 6) -gt $bytes.Length -or
    $bytes[$peOffset] -ne 0x50 -or $bytes[$peOffset + 1] -ne 0x45) {
  Write-Error "$Path has an invalid PE header"
  exit 1
}
$machine = [BitConverter]::ToUInt16($bytes, $peOffset + 4)
Write-Host ("PE machine: 0x{0:X4}" -f $machine)
if ($machine -ne 0x8664) {
  Write-Error ("{0} is not x64 (PE machine 0x{1:X4}, expected 0x8664)" -f $Path, $machine)
  exit 1
}

$dumpbin = $null
$vswhere = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio\Installer\vswhere.exe'
if (Test-Path $vswhere) {
  $vsPath = & $vswhere -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
  if ($vsPath) {
    $dumpbin = Get-ChildItem -Path (Join-Path $vsPath 'VC\Tools\MSVC') -Recurse -Filter dumpbin.exe -ErrorAction SilentlyContinue |
      Where-Object { $_.FullName -match '\\bin\\Hostx64\\x64\\' } |
      Select-Object -First 1 -ExpandProperty FullName
  }
}
if (-not $dumpbin) {
  $cmd = Get-Command dumpbin.exe -ErrorAction SilentlyContinue
  if ($cmd) { $dumpbin = $cmd.Source }
}
if (-not $dumpbin) {
  Write-Error 'dumpbin.exe not found; cannot verify imports'
  exit 1
}

$output = & $dumpbin /nologo /dependents $Path
if ($LASTEXITCODE -ne 0) {
  $output | Write-Host
  Write-Error "dumpbin failed on $Path"
  exit 1
}

$imports = $output |
  ForEach-Object { $_.Trim() } |
  Where-Object { $_ -match '^[\w\.\-]+\.dll$' } |
  Sort-Object -Unique

$system32 = Join-Path $env:SystemRoot 'System32'
# VC++ redistributable DLLs exist in System32 on the runner but not on every
# user machine, so they must be bundled (or the CRT linked statically).
$redistPattern = '^(vcruntime|msvcp|concrt|vcomp|vccorlib|mfc)\d+.*\.dll$'

$missing = @()
foreach ($dll in $imports) {
  if (Test-Path -LiteralPath (Join-Path $binDir $dll)) {
    Write-Host "  [bundled] $dll"
  } elseif ($dll -match '^(api|ext)-ms-win-') {
    Write-Host "  [apiset]  $dll"
  } elseif ($dll -notmatch $redistPattern -and (Test-Path -LiteralPath (Join-Path $system32 $dll))) {
    Write-Host "  [system]  $dll"
  } else {
    Write-Host "  [MISSING] $dll"
    $missing += $dll
  }
}

if ($missing.Count -gt 0) {
  Write-Error ("{0} imports DLLs that are neither system DLLs nor bundled next to it: {1}" -f $Path, ($missing -join ', '))
  exit 1
}

Write-Host "OK: $Path is x64 and all imports resolve."
