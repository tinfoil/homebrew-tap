require "formula"

class Phantomjs200tinfoil1 < Formula
  homepage "https://github.com/tinfoil/phantomjs"
  url "https://github.com/tinfoil/phantomjs/releases/download/2.0.0.tinfoil.1/phantomjs-2.0.0.tinfoil.1-macosx.zip"
  sha256 "016cd256770fc5f7de54f78b84e29ddda18af54d9732e67c121ff6bead667d4e"

  def install
    bin.install "bin/phantomjs"
    (share+"phantomjs").install "examples"
  end

  test do
    path = testpath/"test.js"
    path.write <<-EOS
      console.log("hello");
      phantom.exit();
    EOS

    assert_equal "hello", shell_output("#{bin}/phantomjs #{path}").strip
  end
end
