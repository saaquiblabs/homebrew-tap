class LostButtons < Formula
  desc "Your mouse's side buttons, back on macOS"
  homepage "https://github.com/saaquiblabs/lost-buttons"
  url "https://github.com/saaquiblabs/lost-buttons/archive/refs/tags/v0.4.4.tar.gz"
  sha256 "22e30a5c9155b80924023889992da28dbb9659a4b1e10c7be446fdbec3487173"
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
      After an upgrade macOS asks again: run `lost-buttons`, choose
      Fix permissions, and allow both prompts.
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/lost-buttons --version")
  end
end
