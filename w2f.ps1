# init
$path=$args[0]
$des_floder="output"
$output=$path+$des_floder
$output_format="flac"
$wav_files = Get-ChildItem -Path $path -Filter *.wav
$lrc_files = Get-ChildItem -Path $path -Filter *.lrc
$vtt_files = Get-ChildItem -Path $path -Filter *.vtt

# create destination dir if not exists
cd $path
$folders=Get-ChildItem -Directory
if(-not (Test-Path -Path "output" -PathType Container)){
    mkdir output
    Write-Host "已创建输出目录output."
}

# convert wav to flac with hightest compression level(8 is hightest)
foreach($file in $wav_files){
    $name=$file.BaseName
	ffmpeg -hide_banner -i $path\$file -compression_level 8 $path\$des_floder\$name.$output_format
}

Write-Host "wav to flac转码完成."
Write-Host "开始处理lyrics..."

# TODO: merge LYRICS into TAGS if *.lrc files are exist

if(($lrc_files.Count -eq 0) -and ($vtt_files.Count -eq 0)){
    Write-Host "lyrics不存在."
}

# convert vtt to lrc
if(-not ($vtt_files.Count -eq 0)){
    foreach($file in $vtt_files){
        ffmpeg -hide_banner -i $file.Name $file.BaseName.lrc
    }
}