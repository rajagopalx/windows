$files=gci -af "E:\" -recurse | % { $_.FullName }
$escaped_file_names = $files -replace "\\","/"
$escaped_file_names
