$inputPath = Join-Path $PSScriptRoot 'input.txt'

if (-not (Test-Path -LiteralPath $inputPath)) {
    Write-Error "Input file not found: $inputPath"
    exit 1
}

function Get-MaxSubsequenceOfLength([string]$s, [int]$k) {
    if ($null -eq $s) { return "0" }
    $n = $s.Length
    if ($n -lt $k) { return "0" }
    $pos = 0
    $remaining = $k
    $sb = New-Object System.Text.StringBuilder ($k)
    while ($remaining -gt 0) {
        $end = $n - $remaining
        $maxChar = '0'
        $maxIdx = -1
        for ($i = $pos; $i -le $end; $i++) {
            $c = $s[$i]
            if ($c -gt $maxChar) {
                $maxChar = $c
                $maxIdx = $i
                if ($maxChar -eq '9') { break }
            }
        }
        [void]$sb.Append($maxChar)
        $pos = $maxIdx + 1
        $remaining--
    }
    return $sb.ToString()
}

$total = [decimal]0

# Process each battery bank
Get-Content -LiteralPath $inputPath | ForEach-Object {
    $line = $_.Trim()
    if ([string]::IsNullOrWhiteSpace($line)) { return }

    if ($line -notmatch '^\d+$') {
        Write-Error "Invalid battery bank line: '$line'"
        exit 1
    }

    $chosen = Get-MaxSubsequenceOfLength -s $line -k 12
    $value = [decimal]::Parse($chosen)
    $total += $value
}

Write-Output $total