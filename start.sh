docker build -t gosu-loongarch64 .
docker run --rm -v "$(pwd)"/dist:/dist gosu-loongarch64
ls -al "$(pwd)"/dist
