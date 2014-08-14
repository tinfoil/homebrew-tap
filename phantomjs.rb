require "formula"

class Phantomjs < Formula
  homepage "https://github.com/tinfoil/phantomjs"
  url "https://github.com/tinfoil/phantomjs/releases/download/1.10.0.tinfoil.1/phantomjs-1.10.0.tinfoil.1-macosx.zip"
  sha1 "4436042a7c3c326fddf0415d2eaec72a86472339"

  depends_on :x11

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
