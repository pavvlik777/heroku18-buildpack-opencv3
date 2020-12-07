# Version: 0.0.1
FROM heroku/heroku:18-build

# INSTALL ALL
RUN apt-get update  \
&& apt-get install -y  \
    build-essential \
    cmake \
    git \
    libgtk2.0-dev \
    pkg-config  \
    libavcodec-dev \ 
	libusb-1.0-0 \
    libavformat-dev  \
    libswscale-dev \
    libtbb2  \
    libtbb-dev \ 
    libjpeg-dev \
    libpng-dev  \
	libusb-1.0-0 \
    software-properties-common \
    libtiff-dev  \
    libdc1394-22-dev \
    python-dev  \
	libgstreamer1.0-dev \
	libgstreamer-plugins-base1.0-dev \
    python-numpy
	
RUN add-apt-repository "deb http://security.ubuntu.com/ubuntu xenial-security main" && apt-get update && apt-get -y install --no-install-recommends \
      libjasper1 \
      libtiff-dev \
      libavcodec-dev \
      libavformat-dev \
      libswscale-dev \
      libdc1394-22-dev \
      libxine2-dev \
      libv4l-dev

RUN cd /usr/include/linux && \
    ln -s -f ../libv4l1-videodev.h videodev.h && \
    cd ~ 
	
RUN apt-get update && apt-get -y install --no-install-recommends \
      tesseract-ocr libtesseract-dev libleptonica-dev \
      libgdiplus \
    && apt-get -y clean \
    && rm -rf /var/lib/apt/lists/*


ENV OPENCV_VER 4.5.0

RUN git clone https://github.com/opencv/opencv.git \
    && cd opencv \
    && git checkout ${OPENCV_VER} \
    && mkdir build

WORKDIR "opencv/build"

RUN cmake -D CMAKE_BUILD_TYPE=RELEASE \
    -D CMAKE_INSTALL_PREFIX=/usr/local \
    -D INSTALL_PYTHON_EXAMPLES=OFF \
    -D INSTALL_C_EXAMPLES=OFF \
    -D PYTHON_EXECUTABLE=/usr/bin/python \	
    -D BUILD_SHARED_LIBS=OFF \
    -D ENABLE_CXX11=ON \
    -D BUILD_EXAMPLES=OFF \
    -D BUILD_DOCS=OFF \
    -D BUILD_PERF_TESTS=OFF \
    -D BUILD_TESTS=OFF \
    -D BUILD_JAVA=OFF \
    -D BUILD_opencv_app=OFF \
    -D BUILD_opencv_java_bindings_generator=OFF \
    -D BUILD_opencv_python_bindings_generator=OFF \
    -D BUILD_opencv_python_tests=OFF \
    -D BUILD_opencv_ts=OFF \
    -D BUILD_opencv_js=OFF \ 
    -D BUILD_opencv_bioinspired=OFF \
    -D BUILD_opencv_ccalib=OFF \
    -D BUILD_opencv_datasets=OFF \
    -D BUILD_opencv_dnn_objdetect=OFF \
    -D BUILD_opencv_dnn_superres=OFF \
    -D BUILD_opencv_dpm=OFF \
    -D BUILD_opencv_fuzzy=OFF \
    -D BUILD_opencv_gapi=OFF \
    -D BUILD_opencv_intensity_transform=OFF \
    -D BUILD_opencv_mcc=OFF \
    -D BUILD_opencv_rapid=OFF \
    -D BUILD_opencv_reg=OFF \
    -D BUILD_opencv_stereo=OFF \
    -D BUILD_opencv_structured_light=OFF \
    -D BUILD_opencv_surface_matching=OFF \
    -D BUILD_opencv_videostab=OFF \
    -D WITH_GSTREAMER=OFF \ 
    -D OPENCV_ENABLE_NONFREE=ON \
	.. && make -j6 && make install && ldconfig

RUN make
RUN make install
ENV LD_LIBRARY_PATH /usr/local/lib


# Construct buildpack for heroku
ENV HOME /root
WORKDIR $HOME

RUN mkdir .heroku \
    && mkdir .heroku/vendor \
    && cp -r /usr/local/bin .heroku/vendor/ \
    && cp -r /usr/local/include .heroku/vendor/ \
    && cp -r /usr/local/man .heroku/vendor/ \
    && cp -r /usr/local/share .heroku/vendor/ \
    && cp -r /usr/local/lib .heroku/vendor/ \
    && cp -r /usr/lib/lib* .heroku/vendor/lib/ \
    && cp -r /lib/x86_64-linux-gnu/lib* .heroku/vendor/lib/ \
    && cp -r /usr/lib/x86_64-linux-gnu/lib* .heroku/vendor/lib/

# Clean buildpack
# RUN rm -rf .heroku/vendor/lib/python*
RUN rm .heroku/vendor/lib/libicudata* 
RUN rm .heroku/vendor/lib/libLLVM*

RUN tar -czvf "heroku18-buildpack-opencv${OPENCV_VER}.tar.gz" .heroku

CMD ["true"]
