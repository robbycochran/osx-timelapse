#!/bin/bash
# timelapse
#
# Records a sequence of screencaptures at regular intervals on
# Mac OS X.
#
# Can also record using webcam via the imagesnap program.
#
output_dir="output"
output_dir="capture-$(date '+%Y-%m-%dT%H%M%S')"
screen_size="1400x900!"
SCREENS=( 2 1 3 )
#SCREENS=( 1 )
FFMPEG_BIN="ffmpeg -loglevel panic -y "

mkdir -p $output_dir/screen $output_dir/webcam
SCREEN_LEN=${#SCREENS[@]}
for (( i=0; i<${SCREEN_LEN}; ++i)); do
  mkdir -p $output_dir/screen${SCREENS[$i]}
done

while true; do
    timestamp=$(date '+%Y-%m-%dT%H%M%S');
    screen_file="${output_dir}/screen/screen-$timestamp.jpg"
    screen_filter="${output_dir}/screen%d/screen-$timestamp.jpg"
    webcam_file="${output_dir}/webcam/webcam-$timestamp.jpg"

    # For one screen:
    if [ $SCREEN_LEN -eq 1 ]; then
      echo "Capturing screen at $timestamp."
      screencapture -t jpg -x ${screen_file}
    else
      # For multiple screens:
      echo "Capturing ${SCREEN_LEN} screens at $timestamp."
      capture_files=""
      for (( i=0; i<${SCREEN_LEN}; ++i)); do
        capture_files+=" ${output_dir}/screen${SCREENS[$i]}/screen-${timestamp}.jpg "
      done
      screencapture -t jpg -x ${capture_files}

      # Scale
      for (( i=0; i<${SCREEN_LEN}; ++i)); do
        file_name="${output_dir}/screen${SCREENS[$i]}/screen-${timestamp}.jpg "
        convert ${file_name} -scale ${screen_size} ${file_name}
      done

      # Combine 
      ${FFMPEG_BIN} -i ${screen_filter} -filter_complex tile=${SCREEN_LEN}x1 ${screen_file}
    fi


    # If you have a webcam, you might want to capture that too.
    echo "Capturing webcam at $timestamp."
    image_webcam="${output_dir}/webcam/webcam-$timestamp.jpg"
    #./imagesnap/imagesnap -q "${output_dir}/webcam/webcam-$timestamp.jpg";
    imagesnap -w 2 -q ${image_webcam}
    annotation="$(date '+%m-%d-%Y %l:%M %p')"
    pointsize=72
    convert ${image_webcam} -font arial -pointsize $pointsize -fill white -gravity southeast -annotate +10+10 "${annotation}" ${image_webcam}

    sleep 28
done;

# After it's finished, you probably want to play around with image
# magick to stitch the images together and create a movie.
# Specifically look at the tools montage and convert.

