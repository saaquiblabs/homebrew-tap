cask "curtain" do
  version "0.2.2"
  sha256 "81593769c3b617d0b56dbcb2d5cd1fb678bdac9d5a6626e94956707d2ceb2be8"

  url "https://github.com/saaquiblabs/curtain/archive/refs/tags/v#{version}.tar.gz"
  name "Curtain"
  desc "Brightness for every screen, and turn any screen off, from the menu bar"
  homepage "https://github.com/saaquiblabs/curtain"

  depends_on macos: :ventura

  # Built from source on this Mac (needs the Command Line Tools), like the Lost Buttons formula,
  # but as a cask: Curtain.app lands in /Applications, where Spotlight finds it (it doesn't index
  # Homebrew's Cellar), and Homebrew quits it on uninstall and reopens it after an upgrade.
  # `make app` signs it with this Mac's own "Curtain Local Signing" certificate, made once in
  # ~/Library/Keychains and reused by every upgrade, so the Accessibility permission survives.
  preflight_steps do
    # The download is quarantined; the app is built here, so it needs no Gatekeeper check.
    run "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "{{staged_path}}"],
                          must_succeed: false, writable_paths: ["{{staged_path}}"]
    run "/usr/bin/make", args: ["test", "app"], chdir: "curtain-#{version}",
                         env: { "HOME" => Dir.home },
                         writable_paths: ["{{staged_path}}", "#{Dir.home}/Library/Keychains"]
  end

  app "curtain-#{version}/build/Curtain.app"

  # Quitting restores every screen (back on, original brightness and colours).
  uninstall quit:   "com.saaquiblabs.curtain",
            signal: ["TERM", "com.saaquiblabs.curtain"]

  zap trash: [
    "~/Library/Keychains/curtain-signing.keychain-db",
    "~/Library/Preferences/com.saaquiblabs.curtain.plist",
  ]

  caveats <<~EOS
    Open Curtain from Spotlight. For the brightness keys on monitors, allow it in
    System Settings > Privacy & Security > Accessibility when asked; upgrades keep it.
  EOS
end
