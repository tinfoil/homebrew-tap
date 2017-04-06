class KubernetesFed < Formula
  desc "Kubernetes Federation command-line interface"
  homepage "https://kubernetes.io/"
  url "https://github.com/kubernetes/kubernetes.git",
      :tag => "v1.6.1",
      :revision => "b0b7a323cc5a4a2019b2e9520c21c7830b7f708e"
  head "https://github.com/kubernetes/kubernetes.git"

  depends_on "go" => :build

  def install
    ENV["GOPATH"] = buildpath
    arch = MacOS.prefer_64_bit? ? "amd64" : "x86"
    dir = buildpath/"src/k8s.io/kubernetes"
    dir.install buildpath.children - [buildpath/".brew_home"]

    cd dir do
      # Race condition still exists in OSX Yosemite
      # Filed issue: https://github.com/kubernetes/kubernetes/issues/34635
      ENV.deparallelize { system "make", "generated_files" }

      # Make binary
      system "make", "kubefed"
      bin.install "_output/local/bin/darwin/#{arch}/kubefed"
    end
  end

  test do
    run_output = shell_output("#{bin}/kubefed 2>&1")
    assert_match "kubefed controls a Kubernetes Cluster Federation.", run_output

    version_output = shell_output("#{bin}/kubefed version --client 2>&1")
    assert_match "GitTreeState:\"clean\"", version_output
  end
end
