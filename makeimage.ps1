param (
    $distname, 
    $storename,
    $downloadurl = "https://cloud-images.ubuntu.com/wsl/jammy/current/ubuntu-jammy-wsl-amd64-wsl.rootfs.tar.gz"
)

#$base = $env:Home
$base = $env:UserProfile

if ([System.String]::IsNullOrWhiteSpace($storename)) {
    $storepath = Join-Path -Path $base -ChildPath "wsl"
} else {
    if (-not [System.IO.Path]::IsPathRooted($storename)) {
        $storename = Join-Path -Path $env:Home -ChildPath $storename
    }
    if (Test-Path $storename) {
        $storepath = Resolve-Path -Path $storename
    } else {
        throw "Directory {0} not found" -f $storename
    }
}
$fullstorepath = Join-Path -Path $storepath -ChildPath $distname
$cachepath = Join-Path -Path $storepath -ChildPath '.cache'
$basename = $downloadurl.Substring($downloadurl.LastIndexOf("/") + 1)
$imagefile = Join-Path -Path $cachepath -ChildPath $basename

New-Item -ItemType Directory -Path $cachepath -ErrorAction SilentlyContinue

Write-Host "DIST", $distname
Write-Host "HOME", $env:Home
Write-Host "SN", $storename
Write-Host "SP", $storepath
Write-Host "FSP", $fullstorepath

if (Test-Path $fullstorepath) {
    throw "Directory {0} already exists. Will not continue" -f $fullstorepath
}

Write-Host "IMAGE", $imagefile
New-Item -Path $fullstorepath -ItemType Directory > $null

if (-not (Test-Path $imagefile)) {
    $webclient = New-Object System.Net.WebClient
    Write-Host "Downloading image"
    $webclient.DownloadFile($downloadurl, $imagefile.ToString())
    Write-Host "Image downloaded"
}

Write-Host "Importing"
wsl.exe --import $distname $fullstorepath $imagefile
Write-Host "Imported"

Write-Host "Installing"
$installscript = Get-Content .\install.sh -Raw

Push-Location $env:Home

Write-Output $installscript  | wsl.exe -d $distname 'cat' '|' 'sed' '$ s/.$//' '>' '/tmp/install.sh' # Bloody powershell...
Write-Output $installscript  | wsl.exe -d $distname 'cat' '/tmp/install2.sh'
wsl.exe -d $distname chmod 755 /tmp/install.sh
wsl.exe -d $distname cat /tmp/install.sh
wsl.exe -d $distname file /tmp/install.sh /tmp/install2.sh
wsl.exe -d $distname /tmp/install.sh
Write-Host "Installed"

wsl.exe -t $distname

Pop-Location

wsl.exe --export $distname outputfile.tar
