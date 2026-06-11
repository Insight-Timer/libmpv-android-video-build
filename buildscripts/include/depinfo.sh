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
# FLTR-20042: dav1d + libxml2 kept in the FFmpeg dep tree. We TRIED to
# drop them since the IT-minimal configure doesn't use them, but
# FFmpeg's `--enable-hwaccels` flag (which we keep, for MediaCodec
# h264/hevc hwaccels) probes for dav1d at configure time, failing with
# "ERROR: dav1d >= 0.5.0 not found using pkg-config" when it isn't
# installed. Easier to keep building dav1d than to drop --enable-hwaccels
# and enumerate every hwaccel by hand. ~1 MB savings deferred.
if [ -n "${ENCODERS_GPL+x}" ]; then
	dep_ffmpeg=(mbedtls dav1d libxml2 libvorbis libvpx libx264)
else
	dep_ffmpeg=(mbedtls dav1d libxml2)
fi
dep_freetype2=()
dep_fribidi=()
dep_harfbuzz=()
dep_libass=(freetype fribidi harfbuzz)
dep_lua=()
dep_shaderc=()
# FLTR-20042: libass kept in the mpv dep tree. We TRIED to drop it (for
# the ~7.8 MB iOS subtitle-stack saving) but mpv 0.36 declares libass
# as a hard meson dependency without a feature-option fallback. Removing
# it requires patching mpv source (mpv-remove-libass.patch) — the patch
# exists for darwin's v0.36.0 pin but doesn't apply against Android's
# mpv pin (`78d43740`, 549 commits ahead of v0.36.0). Regenerating the
# patch against Android's SHA is ~1 day of work; deferred to production
# adoption. For the spike we keep libass building and just take the
# FFmpeg codec/demuxer trim (≈2-3 MB on libmpv.so).
if [ -n "${ENCODERS_GPL+x}" ]; then
	dep_mpv=(ffmpeg libass fftools_ffi)
else
	dep_mpv=(ffmpeg libass)
fi
