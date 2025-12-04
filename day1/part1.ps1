$inputPath = Join-Path $PSScriptRoot 'input.txt'

if (-not (Test-Path $inputPath)) {
    Write-Error "Input file not found: $inputPath"
    exit 1
}

# Dial state
$currentPosition = 50
$zeroCount = 0

# Process each rotation
Get-Content -LiteralPath $inputPath | ForEach-Object {
    $line = $_.Trim()
    if ([string]::IsNullOrWhiteSpace($line)) { return }

    # Expect format like: L68 or R14
    if ($line -notmatch '^[LR]-?\d+$') {
        Write-Error "Invalid rotation line: '$line'"
        exit 1
    }

    $dir = $line.Substring(0,1)
    $dist = [int]$line.Substring(1)

    switch ($dir) {
        'L' {
            # Move left (toward lower numbers), wrap around 0..99
            $currentPosition = (($currentPosition - $dist) % 100 + 100) % 100
        }
        'R' {
            # Move right (toward higher numbers), wrap around 0..99
            $currentPosition = (($currentPosition + $dist) % 100 + 100) % 100
        }
        default {
            Write-Error "Unexpected direction: $dir"
            exit 1
        }
    }

    if ($currentPosition -eq 0) { $zeroCount++ }
}

# Output the password (times the dial points at 0)
$zeroCount