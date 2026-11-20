class LostButtons < Formula
  desc "Your mouse's side buttons, back on macOS"
  homepage "https://github.com/saaquiblabs/lost-buttons"
  url "https://github.com/saaquiblabs/lost-buttons/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "168b34a67078a6d069613a91ee520185e85b84ed36839e58393ee24c585c6b4a"
  license "MIT"

  depends_on :macos

  def install
    system "make", "test"
    system "make", "install", "PREFIX=#{prefix}"
  end

  service do
    run [opt_bin/"lost-buttons"]
    keep_alive true
    process_type :interactive
    log_path var/"log/lost-buttons.log"
    error_log_path var/"log/lost-buttons.log"
  end

  def caveats
    <<~EOS
      Start it (and at every login):
        brew services start lost-buttons
      Check your mouse:
        lost-buttons doctor
      macOS will ask for Input Monitoring and Accessibility the first time an
      affected mouse is plugged in.
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/lost-buttons --version")
  end
end
