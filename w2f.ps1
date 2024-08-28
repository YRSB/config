# init
$path=$args[0]
$des_floder="output"
$output=$path+$des_floder
$output_format="flac"
$files = Get-ChildItem -Path $path -Filter *.wav

# create destination dir if not exists
cd $path
$folders=Get-ChildItem -Directory
if(-not Test-Path -Path "output" -PathType Container){
    mkdir output
}

# convert wav to flac with hightest compression level(8)
foreach($file in $files){
    $name=$file.BaseName
	ffmpeg -hide_banner -i $path\$file -compression_level 8 $path\$des_floder\$name.$output_format
}

# TODO: merge LYRICS into TAGS if *.lyc files are exist