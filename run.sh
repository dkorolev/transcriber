#!/bin/bash

# To run: `docker build`, and `docker run -v $PATH_TO_MP4_FILES:/data`.

# To collate the output: See below.

set -e

(
  cd /data;
  for DIR in $(find . -type d | sort); do
    (
      cd $DIR;
      if [ -f audio.wav ] ; then
        echo "Already has 'audio.wav' in $DIR."
      else
        FN=$(ls -S *.mp4 | head -n 1);
        if [ "$FN" != "" ] ; then
          rm -f audio.tmp.wav
          echo "Generating '$DIR/audio.wav'."
          ffmpeg -i "$FN" -ar 16000 -ac 1 -c:a pcm_s16le audio.tmp.wav
          mv audio.tmp.wav audio.wav
          echo "Generated '$DIR/audio.wav'."
        fi
      fi

      if [ -f audio.wav ] ; then
        if [ -f audio.txt ] ; then
          echo "Already has 'audio.txt' in $DIR."
        else
          IN="$PWD/audio.wav"
          echo "Generating '$DIR/audio.txt'."
          (cd /whisper.cpp; ./build/bin/whisper-cli -m models/ggml-medium.bin -l ru -f "$IN" --output-txt) | tee audio.tmp.txt
          mv audio.tmp.txt audio.txt
          echo "Generated '$DIR/audio.txt'."
        fi
      fi
    );
  done
)

# NOTE(dkorolev): It looks like `audio.wav.txt` without any timekeys will be created, and is best to be used. As in:
# for i in $(find . -iname audio.wav.txt | sort); do echo; echo $i ; echo ; cat $i ; done
