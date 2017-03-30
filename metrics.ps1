$JSON = ''
Get-WmiObject Win32_PerfFormattedData_PerfProc_Process `
    | Where-Object { $_.name -inotmatch '_total' } `
    | ForEach-Object {
            $id = $_.IDProcess
            $Process = Get-Process -Id $id -IncludeUserName
            $owner = $Process.UserName -replace '\s',''
            $user = $owner.Split('\')[1]
            $name = $_.Name -replace '\s',''
            $computer = $_.PSComputerName
            $cpu_processor_per = $_.PercentProcessorTime
            $cpu_user_per = $_.PercentUserTime
            $ram = ([math]::Round($_.WorkingSetPrivate/1Mb,2))
            $ioreadbytes = ([math]::Round($_.IOReadBytesPersec/1Mb,2))
            $iowritebytes = ([math]::Round($_.IOWriteBytesPersec/1Mb,2))
            $JSON += "windows,computer=$computer,process=$name,user=$user id=$id,cpu_proc_per=$cpu_processor_per,cpu_user_per=$cpu_user_per,ram=$ram,diskread=$ioreadbytes,diskwrite=$iowritebytes `n"
    }
Invoke-WebRequest -uri "http://192.168.30.211:8086/write?db=telegraf" -Method POST -Body  $JSON