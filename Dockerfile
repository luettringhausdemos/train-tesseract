# Set docker image
FROM ubuntu:20.04
LABEL version="0.1.0"

# Skip the configuration part
ENV DEBIAN_FRONTEND noninteractive

# Update and install depedencies
RUN apt-get update && \
    apt-get install -y wget unzip bc vim python3-pip libleptonica-dev git

# Packages to complie Tesseract
RUN apt-get install -y --reinstall make && \
    apt-get install -y g++ autoconf automake libtool pkg-config libpng-dev libjpeg8-dev libtiff5-dev libicu-dev \
        libpango1.0-dev autoconf-archive libgirepository1.0-dev

# Set working directory
WORKDIR /app

# Getting tesstrain: beware the source might change or not being available
# Complie Tesseract with training options (also feel free to update Tesseract versions and such!)
# Getting data: beware the source might change or not being available
RUN mkdir src && cd /app/src && \
    wget https://github.com/tesseract-ocr/tesseract/archive/refs/heads/main.zip && \
	unzip main.zip && rm main.zip &&\
    cd /app/src/tesseract-main && ./autogen.sh && ./configure && make && make install && ldconfig && \
    make training && make training-install && \
    cd /usr/local/share/tessdata && wget https://github.com/tesseract-ocr/tessdata_best/raw/main/eng.traineddata && \
    wget https://github.com/tesseract-ocr/tessdata_best/raw/main/deu.traineddata && \
    cd /app/src && \
    wget https://github.com/tesseract-ocr/langdata_lstm/archive/refs/heads/main.zip && \
    unzip main.zip && rm main.zip


# Copy requirements into the container at /app
COPY requirements.txt ./
# Setting the data prefix
ENV TESSDATA_PREFIX=/usr/local/share/tessdata

# Install libraries using pip installer
RUN pip3 install -r requirements.txt

# Set the locale
RUN apt-get update
RUN apt-get install -y locales && locale-gen de_DE.UTF-8
ENV LC_ALL=de_DE.UTF-8
ENV LANG=de_DE.UTF-8
ENV LANGUAGE=de_DE.UTF-8
