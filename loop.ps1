for(;;) {
 try {
  # invoke the worker script
  powershell F:\monitoring\metrics.ps1
 }
 catch {
  # do something with $_, log it, more likely
 }

 # wait for a minute
 Start-Sleep 1
}