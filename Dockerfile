FROM rustlang/rust:nightly

RUN apt-get -y update \
    && apt-get -y upgrade \
    && apt-get -y autoremove

# Install build dependencies
RUN apt-get -y install \
    clang \
    gcc \
    g++ \
    cmake \
    ninja-build \
    zlib1g-dev \
    libmpc-dev \
    libmpfr-dev \
    libgmp-dev \
    git \
    wget

# osxcross
WORKDIR /usr/local
RUN git clone https://github.com/tpoechtrager/osxcross
WORKDIR /usr/local/osxcross
RUN wget -nc https://github.com/phracker/MacOSX-SDKs/releases/download/10.15/MacOSX10.11.sdk.tar.xz
RUN mv MacOSX10.*.sdk.tar.xz tarballs/
RUN UNATTENDED=yes OSX_VERSION_MIN=10.7 ./build.sh
WORKDIR /usr/local

# Add macOS Rust target
RUN rustup target add x86_64-apple-darwin

RUN { \
    echo '[target.x86_64-apple-darwin]'; \
    echo 'linker = "x86_64-apple-darwin15-clang"'; \
    echo 'ar = "x86_64-apple-darwin15-ar"'; \
    } > /usr/local/cargo/config

ENV PATH "/usr/local/osxcross/target/bin:$PATH"

RUN { \
    echo 'cargo build --target x86_64-apple-darwin'; \
    } > /usr/local/bin/cargo_build_macos.sh \
    && chmod 755 /usr/local/bin/cargo_build_macos.sh
RUN { \
    echo 'cargo build --release --target x86_64-apple-darwin'; \
    } > /usr/local/bin/cargo_build_release_macos.sh \
    && chmod 755 /usr/local/bin/cargo_build_release_macos.sh

WORKDIR /usr/src
CMD ["/bin/bash"]
