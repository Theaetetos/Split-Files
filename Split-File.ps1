# splits passed-in file into smaller files with same name (and therefore location) but with split number appended to
# file name, each one the lesser of $num_lines and number of lines left in file lines long
# assumes that only period in name will be before extension...very bad idea but I don't feel like fixing it now

# This function was run from the command line (Powershell) to split files that were more than approximately 1 gb
# into smaller files to help with processing speed. The files that were split are listed in split_files.csv.

Function Split-File($file_name, $num_lines) {
    
    $sw = new-object System.Diagnostics.Stopwatch
    $f_nm_arr = $file_name.Split(".")
    $base_name = $f_nm_arr[0]
    $ext = $f_nm_arr[1]

    $file_count = 1
    $line_count = 0
    $reader = $null
    $sw.Start()
    
    try{
        $reader = [io.file]::OpenText($file_name)
        try{
            "Creating file number $file_count"
            $writer = [io.file]::CreateText("{0}{1}.{2}" -f ($base_name, $file_count.ToString("000"), $ext))
            $file_count++
            $line_count = 0

            while($reader.EndOfStream -ne $true) {
                "Reading next $num_lines lines..."
                while( ($line_count -lt $num_lines) -and ($reader.EndOfStream -ne $true)){
                    $writer.WriteLine($reader.ReadLine());
                    $line_count++
                }

                if($reader.EndOfStream -ne $true) {
                    "Closing file"
                    $writer.Dispose();

                    "Creating file number $file_count"
                    $writer = [io.file]::CreateText("{0}{1}.{2}" -f ($base_name, $file_count.ToString("000"), $ext))
                    $file_count++
                    $line_count = 0
                }
            }
        } finally {
            $writer.Dispose();
        }
    } finally {
        $reader.Dispose();
    }

    $sw.Stop()
    Write-Host "Split complete in " $sw.Elapsed.TotalSeconds "seconds"

}
New-Alias -name sf -value Split-File -option allscope