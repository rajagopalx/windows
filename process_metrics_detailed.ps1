# Set-ExecutionPolicy RemoteSigned
# Install PSTerminalServices

Import-Module PSTerminalServices

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
               if (!$user) { $user = "None"}
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

  Get-TSSession -ComputerName "localhost" | Where-Object { $_.UserName -ne "" } `
  | ForEach-Object {
      $isloggedin = 0
      $username = $_.UserName
      $status = $_.ConnectionState
      if ($status -eq 'Active') {$isloggedin = 1}
      $clientname = $_.ClientName
      if (!$clientname) { $clientname = "None"}
      $clientipaddress = $_.ClientIPAddress.IPAddressToString
      if (!$clientipaddress) { $clientipaddress = "None"}
      $computername = $env:COMPUTERNAME
      $POSTDATA += "usersessions,computer=$computername,user=$username,clientname=$clientname,clientip=$clientipaddress,status=$status isloggedin=$isloggedin `n" 
  }

  Invoke-WebRequest -UseBasicParsing -uri "http://106.51.2.141:8086/write?db=telegraf" -Method POST -Body  $POSTDATA
  
 }
 catch {
    $_ | Out-File C:\monitoring\errors.txt -Append
 }

 # wait for a minute
 Start-Sleep 1
}
