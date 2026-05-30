FROM ubuntu:25.10

# Install gnucobol compiler
RUN apt-get update && apt-get install -y \
    build-essential \
    autoconf \
    clang \
    curl \
    libgmp3-dev \
    texinfo \
    && rm -rf /var/lib/apt/lists/*

# Build the gnucobol compiler
COPY docker/*.sh .
RUN ./build-gnucobol.sh


# Build the application source code
COPY src src/
RUN cobc -x src/*.cob

# Run the program
ENTRYPOINT ["./Activity"]

CMD ["hello, world"]

