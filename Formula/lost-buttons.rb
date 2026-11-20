class LostButtons < Formula
  desc "Your mouse's side buttons, back on macOS"
  homepage "https://github.com/saaquiblabs/lost-buttons"
  url "https://github.com/saaquiblabs/lost-buttons/archive/refs/tags/v0.3.3.tar.gz"
  sha256 "8dc2dab3d767c45c283a29a79c33c499c039c6efdf39edaae3b81a9836d6a72f"
  license "MIT"

  depends_on macos: :ventura

  def install
    system "make", "test"
    system "make", "app"
    # Same layout as homebrew-core's pinentry-mac: the app lives in the prefix, and the
    # `lost-buttons` command is a small script that runs the binary inside it.
    prefix.install "build/Lost Buttons.app"
    bin.write_exec_script prefix/"Lost Buttons.app/Contents/MacOS/lost-buttons"
  end

  def caveats
    <<~EOS
      Start it (and at every login):
        lost-buttons start
      Check your mouse:
        lost-buttons doctor
      macOS will ask for Input Monitoring and Accessibility the first time an
      affected mouse is plugged in. Both lists show it as "Lost Buttons".

      After every upgrade, run `lost-buttons start` again. macOS may ask for
      the two permissions again: remove the old "Lost Buttons" entries
      (select, click -) and switch on the new one.
      Coming from 0.2? `lost-buttons start` stops the old Homebrew service.
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/lost-buttons --version")
  end
end
