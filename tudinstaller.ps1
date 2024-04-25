param (
    $downloadurl = "https://github.com/mmaschenk/actiontester/releases/latest/download/tudelft.tgz"
)

function Update-ImageCacheFile {
    param (
        [Parameter(Position=0, Mandatory=$true)] $downloadurl,
        $storename = 'wsl',
        $cachepath = '.cache',
        $base = $env:UserProfile
    )
    
    if (-not [System.IO.Path]::IsPathRooted($storename)) {
        $storename = Join-Path -Path $base -ChildPath $storename
    }
    if (-not [System.IO.Path]::IsPathRooted($cachepath)) {
        $cachepath = Join-Path -Path $storename -ChildPath $cachepath
    }
    $basename = $downloadurl.Substring($downloadurl.LastIndexOf("/") + 1)
    $imagefile = Join-Path -Path $cachepath -ChildPath $basename
    $hashurl = "${downloadurl}.hash"

    Write-Host "Downloadurl", $downloadurl
    Write-Host "Base is", $base
    Write-Host "Storename", $storename
    Write-Host "Cache path", $cachepath
    Write-Host "Imagefile", $imagefile
    Write-Host "Hashurl", $hashurl

    New-Item -ItemType Directory -Path $cachepath -ErrorAction SilentlyContinue

    if (Test-Path -Path $imagefile -PathType leaf) {
        Write-Host "Image file already present"
        $localhashvalue = (Get-FileHash $imagefile).Hash.Trim()
    } else {
        Write-Host "Image file not yet present"
        $localhashvalue = "NOTPRESENT"
    }

    $remotehash = Invoke-WebRequest -URI $hashurl

    $remotehashvalue = [System.Text.Encoding]::ASCII.GetString($remotehash.Content).Trim()
    Write-Host("Local hash value: [{0}]" -f $localhashvalue)
    Write-Host("Remote hash value: [{0}]" -f $remotehashvalue)

    if ($remotehashvalue -ne $localhashvalue) {
        Write-Host "Need to download"
        $webclient = New-Object System.Net.WebClient
        Write-Host "Downloading image"
        $webclient.DownloadFile($downloadurl, $imagefile.ToString())
        Write-Host "Image downloaded"
    }

    Write-Host $remotehashvalue.GetType()
    Write-Host $localhashvalue.GetType()

    Write-Host ("[{0}] =?= [{1}]" -f $remotehashvalue, $localhashvalue)

    return $imagefile
}

function Initialize-WSLStoreLocation {
    param(
        [Parameter(Position=0, Mandatory=$true)] $distribution,
        $storename = 'wsl',
        $base = $env:UserProfile
    )

    if (-not [System.IO.Path]::IsPathRooted($storename)) {
        $storename = Join-Path -Path $base -ChildPath $storename
    }

    $fullstorepath = Join-Path -Path $storename -ChildPath $distribution

    if (Test-Path $fullstorepath) {
        throw ("Directory {0} already exists." -f $fullstorepath)
        
    }

    Write-Host("Fullstorepath: {0}" -f $fullstorepath)

    return $fullstorepath
}

function  Register-ImageFile {
    param (
        [Parameter(Position=0, Mandatory=$true)] $downloadurl,
        $registrationname = 'tudelfttest'
    )

    $cachefile = Update-ImageCacheFile($downloadurl)
    $storepath = Initialize-WSLStoreLocation($registrationname)

    Write-Host("cachefile returned: {0}" -f $cachefile)
    Write-Host("registration name: {0}" -f $registrationname)
    Write-Host("storepath: {0}" -f $storepath)

    wsl.exe --import $registrationname $storepath $cachefile
}


Write-Host("Installing: {0}" -f $downloadurl)
Register-ImageFile -downloadurl $downloadurl