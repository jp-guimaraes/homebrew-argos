# homebrew-argos

Homebrew tap for [Argos](https://github.com/jp-guimaraes/argos), a
free-software tool for creating bootable Windows and Linux installer USB
drives from macOS or Linux, targeting both legacy BIOS/MBR and modern
UEFI/GPT machines.

## Install

```sh
brew install jp-guimaraes/argos/argos
```

This builds `argos` and `argos-helper` from source (via `cargo install`) --
there is no pre-built bottle. A working Rust toolchain is pulled in as a
build dependency automatically; you don't need one installed yourself.

## Usage

See the [main repository](https://github.com/jp-guimaraes/argos) for what
Argos does and how to use it. In short:

```sh
argos list                                    # see what's safe to write to
argos write path/to/some.iso --device /dev/diskN
```

Writing to a disk needs root -- `argos` re-runs `argos-helper` under `sudo`
for that one step.

## Updating the formula for a new release

The formula's `url`/`sha256` point at a specific tagged source tarball, not
a branch, so they need bumping by hand for each Argos release:

```sh
curl -sL -o /tmp/argos.tar.gz \
  https://github.com/jp-guimaraes/argos/archive/refs/tags/vX.Y.Z.tar.gz
shasum -a 256 /tmp/argos.tar.gz
```

Update `Formula/argos.rb` with the new tag and checksum, commit, and push --
CI (`.github/workflows/tests.yml`) builds and tests the formula on a real
macOS runner before it lands.
