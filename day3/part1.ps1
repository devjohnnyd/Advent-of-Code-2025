$inputPath = Join-Path $PSScriptRoot 'input.txt'

if (-not (Test-Path -LiteralPath $inputPath)) {
    Write-Error "Input file not found: $inputPath"
    exit 1
}

$total = 0

# Process each battery bank
Get-Content -LiteralPath $inputPath | ForEach-Object {
    $line = $_.Trim()
    if ([string]::IsNullOrWhiteSpace($line)) { return }

    if ($line -notmatch '^\d+$') {
        Write-Error "Invalid battery bank line: '$line'"
        exit 1
    }

    # Find the maximum two-digit joltage using in-order selection (i < j)
    $maxPrevDigit = -1
    $best = -1
    for ($i = 0; $i -lt $line.Length; $i++) {
        $d = [int]::Parse($line[$i].ToString())
        if ($maxPrevDigit -ge 0) {
            $candidate = (10 * $maxPrevDigit) + $d
            if ($candidate -gt $best) { $best = $candidate }
        }
        if ($d -gt $maxPrevDigit) { $maxPrevDigit = $d }
    }

    if ($best -lt 0) { $best = 0 } # lines with <2 digits produce 0
    $total += $best
}

Write-Output $total