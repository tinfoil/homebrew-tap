cask 'kubernetes-helm-registry' do
  version '0.3.7'
  sha256 'a333643feac85f9967ec01b050f180e3c39e51663a8ca7ef74eac611aa40289a'
  url "https://github.com/app-registry/helm-plugin/releases/download/v#{version}/registry-helm-plugin-v#{version}-dev-osx-x64.tar.gz"

  depends_on formula: 'kubernetes-helm'

  artifact 'registry', target: File.join(Dir.home, '.helm', 'plugins', 'registry')
end
