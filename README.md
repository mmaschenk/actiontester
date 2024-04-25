# actiontester

Download the image from https://github.com/mmaschenk/actiontester/releases/latest/download/tudelft.tgz


Open a Powershell window and copy-paste the following line into it:
```
 (New-Object System.Net.WebClient).DownloadString('https://github.com/mmaschenk/actiontester/releases/latest/download/tudelft.tgz') | iex
```