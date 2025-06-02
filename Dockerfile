FROM alpine

RUN apk add git
RUN git clone https://github.com/ggerganov/whisper.cpp

RUN apk add build-base
RUN apk add make
RUN apk add cmake

RUN (cd whisper.cpp; make -j)

RUN apk add wget

RUN (cd whisper.cpp; ./models/download-ggml-model.sh medium)

RUN apk add bash
RUN apk add ffmpeg

COPY ./run.sh /
ENTRYPOINT ["/run.sh"]
