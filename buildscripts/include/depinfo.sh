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
# FLTR-20042 IT-minimal: dav1d + libxml2 dropped from the FFmpeg dep
# tree. FFmpeg's IT-minimal configure (flavors/default.sh) doesn't
# pass --enable-libdav1d or --enable-libxml2 anymore. Encoders-gpl
# variant still pulls them.
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
# FLTR-20042 IT-minimal: libass dropped from the mpv dep tree. With
# libass not built/installed, pkg-config can't find it at mpv configure
# time and mpv auto-skips libass support — same effect as `-Dlibass=disabled`
# but compatible with mpv 0.36 (which doesn't expose libass as a feature
# option; we hit `meson.build:1:0: ERROR: Unknown option: "libass"` on
# the first attempt). The subtitle stack (freetype + fribidi + harfbuzz)
# transitively disappears since nothing else pulls it in.
if [ -n "${ENCODERS_GPL+x}" ]; then
	dep_mpv=(ffmpeg fftools_ffi)
else
	dep_mpv=(ffmpeg)
fi
