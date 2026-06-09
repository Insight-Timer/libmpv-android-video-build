#!/bin/bash -e

# IT-minimal FFmpeg build for FLTR-20042.
#
# Trimmed codec/demuxer/protocol set vs the upstream "default" flavor.
# Targets only IT's actual playback needs:
#   - HLS (VOD + live) + plain MP4 over HTTPS
#   - h264 + HEVC video
#   - AAC + AC-3 + E-AC-3 audio
#   - mp4/fMP4 + MPEG-TS segment containers
#   - VideoToolbox / MediaCodec hardware decode
#   - No subtitles, no DASH, no AV1, no encoders, no RTMP/RTSP
#
# Estimated savings vs upstream default: ~6-7 MB on libmpv.so per ABI.

. ../../include/depinfo.sh
. ../../include/path.sh

if [ "$1" == "build" ]; then
	true
elif [ "$1" == "clean" ]; then
	rm -rf _build$ndk_suffix
	exit 0
else
	exit 255
fi

mkdir -p _build$ndk_suffix
cd _build$ndk_suffix

cpu=armv7-a
[[ "$ndk_triple" == "aarch64"* ]] && cpu=armv8-a
[[ "$ndk_triple" == "x86_64"* ]] && cpu=generic
[[ "$ndk_triple" == "i686"* ]] && cpu="i686 --disable-asm"

cpuflags=
[[ "$ndk_triple" == "arm"* ]] && cpuflags="$cpuflags -mfpu=neon -mcpu=cortex-a8"

../configure \
	--target-os=android --enable-cross-compile --cross-prefix=$ndk_triple- --ar=$AR --cc=$CC --nm=llvm-nm --ranlib=$RANLIB \
	--arch=${ndk_triple%%-*} --cpu=$cpu --pkg-config=pkg-config \
	--extra-cflags="-I$prefix_dir/include $cpuflags" --extra-ldflags="-L$prefix_dir/lib" \
	\
	--disable-gpl \
	--disable-nonfree \
	--enable-version3 \
	--enable-static \
	--disable-shared \
	--disable-vulkan \
	--disable-iconv \
	--disable-stripping \
	--pkg-config-flags=--static \
	\
	--disable-muxers \
	--disable-decoders \
	--disable-encoders \
	--disable-demuxers \
	--disable-parsers \
	--disable-protocols \
	--disable-devices \
	--disable-filters \
	--disable-bsfs \
	--disable-doc \
	--disable-avdevice \
	--disable-postproc \
	--disable-programs \
	--disable-gray \
	--disable-swscale-alpha \
	\
	--enable-jni \
	--enable-mediacodec \
	\
	--disable-dxva2 \
	--disable-vaapi \
	--disable-vdpau \
	--disable-bzlib \
	--disable-linux-perf \
	--disable-videotoolbox \
	--disable-audiotoolbox \
	\
	--enable-small \
	--enable-hwaccels \
	--enable-optimizations \
	--enable-runtime-cpudetect \
	\
	--enable-mbedtls \
	\
	--enable-avutil \
	--enable-avcodec \
	--enable-avfilter \
	--enable-avformat \
	--enable-swscale \
	--enable-swresample \
	\
	--enable-decoder=h264* \
	--enable-decoder=hevc* \
	\
	--enable-decoder=aac* \
	--enable-decoder=ac3 \
	--enable-decoder=eac3 \
	--enable-decoder=pcm* \
	\
	--enable-demuxer=hls \
	--enable-demuxer=mov \
	--enable-demuxer=mpegts \
	--enable-demuxer=aac \
	\
	--enable-parser=h264 \
	--enable-parser=hevc \
	--enable-parser=aac* \
	--enable-parser=ac3 \
	\
	--enable-bsf=aac_adtstoasc \
	--enable-bsf=h264_mp4toannexb \
	--enable-bsf=hevc_mp4toannexb \
	\
	--enable-protocol=file \
	--enable-protocol=http \
	--enable-protocol=https \
	--enable-protocol=tcp \
	--enable-protocol=tls \
	--enable-protocol=hls \
	\
	--enable-network \

make -j$cores
make DESTDIR="$prefix_dir" install

ln -sf "$prefix_dir"/lib/libswresample.so "$native_dir"
ln -sf "$prefix_dir"/lib/libpostproc.so "$native_dir"
ln -sf "$prefix_dir"/lib/libavutil.so "$native_dir"
ln -sf "$prefix_dir"/lib/libavcodec.so "$native_dir"
ln -sf "$prefix_dir"/lib/libavformat.so "$native_dir"
ln -sf "$prefix_dir"/lib/libswscale.so "$native_dir"
ln -sf "$prefix_dir"/lib/libavfilter.so "$native_dir"
ln -sf "$prefix_dir"/lib/libavdevice.so "$native_dir"
