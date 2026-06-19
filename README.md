# libmpv build (Android)

Provides builds of [libmpv](https://github.com/mpv-player/mpv) for Android, used by [media_kit](https://github.com/media-kit/media-kit).

## Insight-Timer fork conventions

This is the Insight-Timer fork of upstream's libmpv build infrastructure. Two long-lived branches:

- **`master`** *(default)*: Insight-Timer's integration branch (carries the IT trim patches). PR-protected. CI publishes releases from here.
- **`upstream`**: tracks upstream's default branch (mostly read-only on our side). Periodically merged into `master`.

### Release versioning

Tags follow `vUPSTREAM-it.N`:
- `vUPSTREAM` — the upstream tag we forked from (e.g. `v0.7.0` for Darwin, `v1.1.11` for Android)
- `it` — Insight-Timer
- `N` — Insight-Timer's release iteration off that upstream base (starts at 1, increments per rebuild)

Examples:
- `v0.7.0-it.1` — Insight-Timer's 1st release off upstream Darwin `v0.7.0`
- `v1.1.11-it.1` — Insight-Timer's 1st release off upstream Android `v1.1.11`

When upstream moves to `v0.8.0` and we re-fork: `v0.8.0-it.1`. When we patch our fork further on the same upstream base: `v0.7.0-it.2`.

These release artifacts are consumed by the Insight-Timer media-kit fork's `libs/ios/media_kit_libs_ios_video/ios/Makefile` (or `libs/android/media_kit_libs_android_video/android/build.gradle`), which the IT app pulls via `dependency_overrides`.

Background: see [FLTR-20042](https://insight-timer.atlassian.net/browse/FLTR-20042).
