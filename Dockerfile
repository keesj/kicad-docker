FROM ubuntu:18.10

RUN apt-get update

RUN export DEBIAN_FRONTEND=noninteractive \
  && apt-get install -y tzdata \
  && ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime \
  && dpkg-reconfigure --frontend noninteractive tzdata \
  && apt-get install -y git build-essential cmake libwxgtk3.0-dev wx3.0-headers libglew-dev \
    libglm-dev apt-utils libcurl4-openssl-dev libcairo2-dev libboost-all-dev autoconf automake \
    bison flex gcc git libtool make oce-draw liboce-foundation-dev liboce-ocaf-dev swig \
    libwxbase3.0-dev libssl-dev \
    dh-python libpython-stdlib python3-all python3-dev python-wxgtk3.0 libwxgtk3.0-dev python3-wxgtk4.0 libwxgtk3.0-gtk3-dev


# apt-cache showsrc kicad |  grep ^Build-Depends

RUN mkdir -p /opt \
  && cd /opt \
  && git clone --depth 1 -b 5.1 https://github.com/KiCad/kicad-source-mirror.git kicad

RUN cd /opt/kicad/scripting/build_tools \
  && chmod +x get_libngspice_so.sh \
  && ./get_libngspice_so.sh \
  && ./get_libngspice_so.sh install

# https://kicad-source-mirror.readthedocs.io/en/latest/Documentation/development/compiling/
RUN mkdir -p /opt/kicad/build/release \
  && cd /opt/kicad/build/release \
  && cmake -DCMAKE_BUILD_TYPE=Release \
             -DUSE_WX_GRAPHICS_CONTEXT=OFF \
             -DUSE_WX_OVERLAY=ON \
             -DKICAD_SCRIPTING=ON \
             -DKICAD_SCRIPTING_MODULES=ON \
             -DKICAD_SCRIPTING_PYTHON3=ON \
             -DKICAD_SCRIPTING_WXPYTHON=ON \
             -DKICAD_SCRIPTING_WXPYTHON_PHOENIX=ON \
             -DKICAD_SCRIPTING_ACTION_MENU=ON \
             -DBUILD_GITHUB_PLUGIN=ON \
             -DKICAD_USE_OCE=ON \
             -DKICAD_USE_OCC=OFF \
             -DKICAD_SPICE=ON \
             -DPYTHON_EXECUTABLE=/usr/bin/python3 \
             ../../ \
  && make -j8 \
  && make install \
  && ldconfig -v

RUN for i in symbols packages3D footprints templates ; \
  do \
	  mkdir -p /opt/ \
	  && cd /opt/ \
	  && git clone https://github.com/KiCad/kicad-$i.git $i \
	  && cd $i \
	  && cmake -DCMAKE_BUILD_TYPE=Release            \
             . \
	  && make install ;\
   done

CMD /usr/local/bin/kicad
