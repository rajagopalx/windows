# Set-ExecutionPolicy RemoteSigned

for(;;) {
 try {
   $POSTDATA = ''
   $localusers = Get-WmiObject -Class Win32_UserAccount | foreach { $_.Caption }
   Get-WmiObject Win32_PerfFormattedData_PerfProc_Process `
       | Where-Object { $_.name -inotmatch '_total' } `
       | ForEach-Object {
               $islocaluser = 0
               $id = $_.IDProcess
               $Process = Get-Process -Id $id -IncludeUserName
               $app = $Process.Product -replace '\s',''
               if (!$app) { $app = "None"}
               $owner = $Process.UserName
               if (  $localusers.Contains($owner)) { 
                   $islocaluser = 1
               }
               $owner = $owner -replace '\s',''
               if (!$owner) { $owner = "None"}
               $user = $owner.Split('\')[1]
               $name = $_.Name -replace '\s',''
               $computer = $_.PSComputerName
               $cpu_processor_per = $_.PercentProcessorTime
               $cpu_user_per = $_.PercentUserTime
               $ram = ([math]::Round($_.WorkingSetPrivate/1Mb,2))
               $ioreadbytes = ([math]::Round($_.IOReadBytesPersec/1Mb,2))
               $iowritebytes = ([math]::Round($_.IOWriteBytesPersec/1Mb,2))
               $ioreadops = $_.IOReadOperationsPersec
               $iowriteops = $_.IOWriteOperationsPersec
               $POSTDATA += "windows,computer=$computer,process=$name,user=$user,title=$app,id=$id cpu_proc_per=$cpu_processor_per,cpu_user_per=$cpu_user_per,ram=$ram,diskread=$ioreadbytes,diskwrite=$iowritebytes,readops=$ioreadops,writeops=$iowriteops,localuser=$islocaluser `n"
       }
   Invoke-WebRequest -UseBasicParsing -uri "http://192.168.30.200:8086/write?db=telegraf" -Method POST -Body  $POSTDATA
 }
 catch {
  # do something with $_, log it, more likely
 }

 # wait for a minute
 Start-Sleep 1
}
