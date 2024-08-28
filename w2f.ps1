# init
$wav_files = Get-ChildItem -Filter *.wav
$lrc_files = Get-ChildItem -Filter *.lrc
# vtt could be *.vtt or *.txt, but lrc is always *.lrc  
$vtt_files = Get-ChildItem | Where-Object {$_.FullName -match "\w+\.(txt|vtt)$"}

# create destination dir if not exists
$folders=Get-ChildItem -Directory
if(-not (Test-Path .\output)){
    mkdir output
    Write-Host "mkdir output..."
}

# convert wav to flac with hightest compression level(8 is hightest)
foreach($file in $wav_files){
    $output=[System.IO.Path]::ChangeExtension($file.Name),".flac"
    if(-not (Test-Path .\output\$output)){
        ffmpeg -hide_banner -i .\$file -compression_level 8 .\output\$output
    }
    Write-Host "skip existing file .\output\$output."
}

Write-Host "finish convert wav to flac."
Write-Host "handling lyrics..."

# TODO: merge LYRICS into TAGS if *.lrc files are exist
# 情况：
# 1. 不存在lyrics：无需处理
# 2. vtt格式：ffmpeg转换成lrc，再嵌入
# 3. lrc格式：直接嵌入
# 

if(($lrc_files.Count -eq 0) -and ($vtt_files.Count -eq 0)){
    Write-Host "lyrics do not exist"
}else{
    # convert vtt to lrc
    if(-not ($vtt_files.Count -eq 0)){
        foreach($file in $vtt_files){
            $output=$file.BaseName+".lrc"
            ffmpeg -hide_banner -i $file.Name .\output\$output
        }
    }else{
        Copy-Item *.lrc .\output\
    }
}

Set-Location output
$lrc_files = Get-ChildItem . -Filter *.lrc
$ext = ".flac"
foreach($lrc in $lrc_files){
    $lrc_name = $lrc.Name.Split('.')[0]
    if(Test-Path ($lrc_name+$ext)){
        $lrcContent = Get-Content $lrc -Encoding UTF8
        if (Get-Command metaflac -ErrorAction SilentlyContinue) {
            metaflac --set-tag="LYRICS=$lrcContent" $lrc_name.flac
            Write-Host "$(lrc.Name)has been embedded in $($lrc_name.flac)"
        } else {
            Write-Error "metaflac tool not found. Please ensure it is installed and in your system path."
        }
    }
}