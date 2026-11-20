class LostButtons < Formula
  desc "Your mouse's side buttons, back on macOS"
  homepage "https://github.com/saaquiblabs/lost-buttons"
  url "https://github.com/saaquiblabs/lost-buttons/archive/refs/tags/v0.4.0.tar.gz"
  sha256 "3ebb3be30378da9d403297db7734a5ff63e4adff9a09c0d5027488d77b06d6b2"
  license "MIT"

  depends_on :macos

  def install
    system "make", "test"
    system "make", "app"
    # Same layout as homebrew-core's pinentry-mac: the app lives in the prefix, and the
    # `lost-buttons` command is a small script that runs the binary inside it.
    prefix.install "build/Lost Buttons.app"
    bin.write_exec_script prefix/"Lost Buttons.app/Contents/MacOS/lost-buttons"
  end

  service do
    run [opt_prefix/"Lost Buttons.app/Contents/MacOS/lost-buttons", "run"]
    keep_alive true
    process_type :interactive
    log_path var/"log/lost-buttons.log"
    error_log_path var/"log/lost-buttons.log"
  end

  def caveats
    <<~EOS
      Start it (and at every login):
        brew services start lost-buttons
      Then run `lost-buttons` for a menu: status, your mice, permission settings.
      macOS will ask for Input Monitoring and Accessibility the first time an
      affected mouse is plugged in. Both lists show it as "Lost Buttons".
      After an upgrade, macOS asks again: remove the old "Lost Buttons" entries
      (select, click -) and switch on the new one.
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/lost-buttons --version")
  end
end
