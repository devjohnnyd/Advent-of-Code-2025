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

function Test-IsRepeatedTwice([long]$n) {
	$s = $n.ToString()
	$len = $s.Length
	if ($len -band 1) { return $false } # odd length cannot be two repeats
	$half = [long]($len / 2)
	$a = $s.Substring(0, $half)
	$b = $s.Substring($half)
	return ($a -eq $b)
}

$sum = 0

# Extract ranges robustly using regex, ignoring malformed tokens
$rangeMatches = [regex]::Matches($text, '\b(?<start>\d+)-(?<end>\d+)\b')
foreach ($m in $rangeMatches) {
	$start = [long]$m.Groups['start'].Value
	$end = [long]$m.Groups['end'].Value
	if ($end -lt $start) { $t = $start; $start = $end; $end = $t }
	for ($num = $start; $num -le $end; $num++) {
		if (Test-IsRepeatedTwice -n $num) {
			$sum += $num
		}
	}
}

Write-Output $sum