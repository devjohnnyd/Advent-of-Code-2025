$inputPath = Join-Path $PSScriptRoot 'input.txt'

if (-not (Test-Path -LiteralPath $inputPath)) {
	Write-Error "Input file not found: $inputPath"
	exit 1
}

# Read full text to support single-line or multi-line inputs
$text = Get-Content -LiteralPath $inputPath -Raw
if ([string]::IsNullOrWhiteSpace($text)) {
	Write-Error "Input is empty"
	exit 1
}

function Test-IsRepeatedAtLeastTwice([long]$n) {
	$s = $n.ToString()
	$len = $s.Length
	if ($len -lt 2) { return $false }
	# If s appears inside (s+s) with ends trimmed, it's a repetition of a smaller substring
	$ss = $s + $s
	$window = $ss.Substring(1, ($ss.Length - 2))
	return $window.Contains($s)
}

$sum = [long]0

# Extract ranges robustly using regex, ignoring malformed tokens
$rangeMatches = [regex]::Matches($text, '\b(?<start>\d+)-(?<end>\d+)\b')
foreach ($m in $rangeMatches) {
	$start = [long]$m.Groups['start'].Value
	$end = [long]$m.Groups['end'].Value
	if ($end -lt $start) { $t = $start; $start = $end; $end = $t }
	for ($num = $start; $num -le $end; $num++) {
		if (Test-IsRepeatedAtLeastTwice -n $num) {
			$sum += $num
		}
	}
}

Write-Output $sum