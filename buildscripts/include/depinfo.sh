#!/bin/bash -e

## Dependency versions

v_sdk=9123335_latest
v_ndk=25.2.9519653
v_sdk_build_tools=33.0.2

v_libass=0.17.1
v_harfbuzz=7.2.0
v_fribidi=1.0.12
v_freetype=2-13-0
v_mbedtls=3.4.0
v_dav1d=1.2.0
v_libxml2=2.10.3
v_ffmpeg=6.0
v_mpv=78d43740f52db817d98bcf24fb30a76ab6fa13ff
v_libogg=1.3.5
v_libvorbis=1.3.7
v_libvpx=1.13


## Dependency tree
# I would've used a dict but putting arrays in a dict is not a thing

dep_mbedtls=()
dep_dav1d=()
dep_libvorbis=(libogg)
# FLTR-20042 IT-minimal Phase 2: dav1d + libxml2 dropped. Works because
# flavors/default.sh replaces `--enable-hwaccels` (which would auto-probe
# for libdav1d even though we never enable av1 decoders) with explicit
# `--enable-hwaccel=h264_mediacodec` + `--enable-hwaccel=hevc_mediacodec`.
# Encoders-gpl flavor still pulls dav1d + libxml2 for its own reasons.
if [ -n "${ENCODERS_GPL+x}" ]; then
	dep_ffmpeg=(mbedtls dav1d libxml2 libvorbis libvpx libx264)
else
	dep_ffmpeg=(mbedtls)
fi
dep_freetype2=()
dep_fribidi=()
dep_harfbuzz=()
dep_libass=(freetype fribidi harfbuzz)
dep_lua=()
dep_shaderc=()
# FLTR-20042 IT-minimal Phase 2: libass dropped from dep_mpv. Works
# because `patches/mpv/mpv_remove_libass.patch` (regenerated against
# Android's mpv SHA 78d43740) strips every libass call site from mpv
# source — mpv no longer requires libass at configure time. Subtitle
# stack (freetype + fribidi + harfbuzz) cascades out since nothing
# else pulls them in. Estimated ~4 MB more saving on libmpv.so per
# ABI vs Phase 1.
if [ -n "${ENCODERS_GPL+x}" ]; then
	dep_mpv=(ffmpeg fftools_ffi)
else
	dep_mpv=(ffmpeg)
fi
