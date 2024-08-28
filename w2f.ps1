# init
$wav_files = Get-ChildItem -Filter *.wav
$lrc_files = Get-ChildItem -Filter *.lrc
# vtt could be *.vtt or *.txt, but lrc is always *.lrc  
$vtt_files = Get-ChildItem | Where-Object {$_.FullName -match "\w+\.(txt|vtt)$"}

# create destination dir if not exists

$folders=Get-ChildItem -Directory
if(-not (Test-Path .\output)){
    mkdir output
    Write-Host "已创建输出目录output."
}

# convert wav to flac with hightest compression level(8 is hightest)
foreach($file in $wav_files){
    $output=[System.IO.Path]::ChangeExtension($file.Name),".flac")
    if(-not (Test-Path .\output\$output){
        ffmpeg -hide_banner -i .\$file -compression_level 8 .\output\$output
    }
    Write-Host "文件.\output\$output 已存在，跳过转码."
}

Write-Host "wav to flac转码完成."
Write-Host "开始处理lyrics..."

# TODO: merge LYRICS into TAGS if *.lrc files are exist
# 情况：
# 1. 不存在lyrics：无需处理
# 2. vtt格式：ffmpeg转换成lrc，再嵌入
# 3. lrc格式：直接嵌入
# 

if(($lrc_files.Count -eq 0) -and ($vtt_files.Count -eq 0)){
    Write-Host "lyrics不存在, 无需处理."
}else{
    # convert vtt to lrc
    if(-not ($vtt_files.Count -eq 0)){
        foreach($file in $vtt_files){
            $output=$file.BaseName+lrc
            ffmpeg -hide_banner -i $file.Name .\output\$output
        }
    }
    # update lrc_files
    $lrc_files = Get-ChildItem .\output -Filter *.lrc
}

Set-Location output


# 遍历指定目录中的所有 .flac 文件
Get-ChildItem -Filter *.flac | ForEach-Object {
    $flac = $_
    # *.flac.lrc
    $lrc1 = $flac.Name+".lrc"
    # *.lrc
    $lrc2 = [System.IO.Path]::ChangeExtension($flac.Name, ".lrc")
    # 检查是否存在对应的 .lrc 文件
    # 情况1：a.flac 和 a.flac.lrc，此时$flac.Name和$lrc.BaseName比
    # 情况2：a.flac 和 a.lrc

    if (Test-Path $lrc) {
        $lyricsContent = Get-Content $lrcFilePath -Raw
        
        # 确保 metaflac 工具可用
        if (Get-Command metaflac -ErrorAction SilentlyContinue) {
            # 使用 metaflac 添加 lyrics 标签
            & metaflac --set-tag="LYRICS=$lyricsContent" $flacFile.FullName
            Write-Host "歌词已嵌入到文件: $($flacFile.FullName)"
        } else {
            Write-Error "metaflac 工具未找到，请确保它已安装并在系统路径中。"
        }
    } else {
        Write-Warning "找不到对应的 lrc 文件: $lrcFilePath"
    }
}
