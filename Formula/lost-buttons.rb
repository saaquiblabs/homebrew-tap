class LostButtons < Formula
  desc "Your mouse's side buttons, back on macOS"
  homepage "https://github.com/saaquiblabs/lost-buttons"
  url "https://github.com/saaquiblabs/lost-buttons/archive/refs/tags/v0.3.0.tar.gz"
  sha256 "00405a2b936894c36bc498a4576bde8990bfad5844bb14cf8b21f1562c16704e"
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

  # 0.3 starts itself as a macOS login item (`lost-buttons start`). This block stays only so that
  # people coming from 0.2 can still run `brew services stop lost-buttons`.
  service do
    run [opt_prefix/"Lost Buttons.app/Contents/MacOS/lost-buttons"]
    keep_alive true
    process_type :interactive
    log_path var/"log/lost-buttons.log"
    error_log_path var/"log/lost-buttons.log"
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
      Coming from 0.2? Run `brew services stop lost-buttons` first.
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/lost-buttons --version")
  end
end
