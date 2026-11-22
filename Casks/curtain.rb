cask "curtain" do
  version "0.3.0"
  sha256 "248d52bbd7c2ef8798661c5fcac8c77bcde9601d343b5531d0271576d3549d51"

  url "https://github.com/saaquiblabs/curtain/archive/refs/tags/v#{version}.tar.gz"
  name "Curtain"
  desc "Brightness for every screen, and turn any screen off, from the menu bar"
  homepage "https://github.com/saaquiblabs/curtain"

  depends_on macos: :ventura

  app "curtain-#{version}/build/Curtain.app"

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
                         # Homebrew swaps HOME for a temp dir here; the certificate must stay in
                         # the real one or every upgrade makes a new one (brew style flags this).
                         env: { "HOME" => Dir.home },
                         writable_paths: ["{{staged_path}}", "#{Dir.home}/Library/Keychains"]
  end

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
