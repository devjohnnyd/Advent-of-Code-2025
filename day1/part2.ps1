$inputPath = Join-Path $PSScriptRoot 'input.txt'

if (-not (Test-Path $inputPath)) {
    Write-Error "Input file not found: $inputPath"
    exit 1
}

$currentPosition = 50
$zeroClicks = 0

function Get-ZeroHitsRight([int]$currentPosition, [int]$dist) {
    # Steps to first zero when moving right: from currentPosition -> 0 via +1 steps
    $stepsToZero = (100 - $currentPosition) % 100
    if ($stepsToZero -eq 0) { $stepsToZero = 100 }  # next zero after 100 clicks
    if ($dist -lt $stepsToZero) { return 0 }
    return 1 + [math]::Floor(($dist - $stepsToZero) / 100)
}

function Get-ZeroHitsLeft([int]$currentPosition, [int]$dist) {
    # Steps to first zero when moving left: from currentPosition -> 0 via -1 steps
    $stepsToZero = $currentPosition % 100
    if ($stepsToZero -eq 0) { $stepsToZero = 100 }  # next zero after 100 clicks
    if ($dist -lt $stepsToZero) { return 0 }
    return 1 + [math]::Floor(($dist - $stepsToZero) / 100)
}

Get-Content -LiteralPath $inputPath | ForEach-Object {
    $line = $_.Trim()
    if ([string]::IsNullOrWhiteSpace($line)) { return }
    if ($line -notmatch '^[LR]-?\d+$') {
        Write-Error "Invalid rotation line: '$line'"
        exit 1
    }

    $dir = $line.Substring(0,1)
    $dist = [int]$line.Substring(1)
    if ($dist -lt 0) {
        # Normalize: negative distance in opposite direction
        if ($dir -eq 'L') { $dir = 'R' } else { $dir = 'L' }
        $dist = -$dist
    }

    switch ($dir) {
        'R' {
            $zeroClicks += Get-ZeroHitsRight $currentPosition $dist
            $currentPosition = (($currentPosition + $dist) % 100 + 100) % 100
        }
        'L' {
            $zeroClicks += Get-ZeroHitsLeft $currentPosition $dist
            $currentPosition = (($currentPosition - $dist) % 100 + 100) % 100
        }
        default {
            Write-Error "Unexpected direction: $dir"
            exit 1
        }
    }
}

$zeroClicks