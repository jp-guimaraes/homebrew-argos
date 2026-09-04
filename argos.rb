class Argos < Formula
  desc "Create bootable Windows and Linux installer USB drives, for BIOS and UEFI"
  homepage "https://github.com/jp-guimaraes/argos"
  url "https://github.com/jp-guimaraes/argos/archive/refs/tags/v1.5.0.tar.gz"
  sha256 "be509f4dc53a91894ab82f66355da669d9a94e2b72a80eb53c3b987b37c6d9b3"
  license any_of: ["MIT", "Apache-2.0"]
  head "https://github.com/jp-guimaraes/argos.git", branch: "main"

  depends_on "rust" => :build

  def install
    # Two binaries from two crates, deliberately: `argos-helper` is the only
    # thing that runs elevated, and it never links clap or touches the
    # terminal. They must land next to each other -- `argos` looks for its
    # helper as a sibling of its own path.
    system "cargo", "install", *std_cargo_args(path: "crates/argos-cli")
    system "cargo", "install", *std_cargo_args(path: "crates/argos-privileged")
  end

  def caveats
    <<~EOS
      Writing to a disk needs root. `argos` re-runs `argos-helper` under
      sudo for exactly that step; nothing else in the tool asks for it.

      Run `argos list` first -- it marks which disks are safe to write to.
    EOS
  end

  test do
    assert_match "argos #{version}", shell_output("#{bin}/argos --version")

    # The helper has to land beside `argos`: the CLI locates it as a sibling
    # of its own path, so a formula that installed only one of the two would
    # produce a binary that fails the moment it needs privilege.
    assert_predicate bin/"argos-helper", :exist?
  end
end
