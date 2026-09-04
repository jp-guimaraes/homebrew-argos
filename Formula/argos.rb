class Argos < Formula
  desc "Create bootable Windows and Linux installer USB drives, for BIOS and UEFI"
  homepage "https://github.com/jp-guimaraes/argos"
  url "https://github.com/jp-guimaraes/argos/archive/refs/tags/v1.5.1.tar.gz"
  sha256 "ab57f6b63b1e46d3c69fb53de94088bbab1338820fc007885de3cebe4dda3d16"
  license any_of: ["MIT", "Apache-2.0"]
  head "https://github.com/jp-guimaraes/argos.git", branch: "main"

  depends_on "rust" => :build

  def install
    # Two binaries from two crates, deliberately: argos-helper is the only
    # thing that ever runs elevated, and it never links clap or touches the
    # terminal. They must land next to each other in `bin` -- `argos` looks
    # for its helper as a sibling of its own path (locate_helper_binary in
    # crates/argos-cli/src/commands/helper.rs).
    system "cargo", "install", *std_cargo_args(path: "crates/argos-cli")
    system "cargo", "install", *std_cargo_args(path: "crates/argos-privileged")

    generate_completions_from_executable(bin/"argos", "completions")
    man1.install Utils.safe_popen_read(bin/"argos", "man") => "argos.1"
  end

  def caveats
    <<~EOS
      Writing to a disk needs root. `argos` re-runs `argos-helper` under
      sudo for exactly that one step; nothing else in the tool asks for it.

      Run `argos list` first -- it marks which disks are safe to write to.
    EOS
  end

  test do
    assert_match "argos #{version}", shell_output("#{bin}/argos --version")

    # The helper has to land beside `argos`: the CLI locates it as a sibling
    # of its own path, so a formula that installed only one of the two would
    # produce a binary that fails the moment it needs privilege.
    assert_path_exists bin/"argos-helper"

    assert_match "argos", shell_output("#{bin}/argos man")
  end
end
