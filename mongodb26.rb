class Mongodb26 < Formula
  desc "High-performance document-oriented database"
  homepage "https://www.mongodb.org/"
  url "https://fastdl.mongodb.org/src/mongodb-src-r2.6.12.tar.gz"
  sha256 "2dd51eabcfcd133573be74c0131c85b67764042833e7d94077e86adc0b9406dc"

  bottle do
    cellar :any_skip_relocation
    sha256 "235b90185354f6cb9274cbc590471c0d4f27a79303b5754eb2e586582a427bef" => :sierra
    sha256 "1c92e42c7e6c54e5aec5ed89e65507c7ee173eb2d39734d1122467dc3ecc7a83" => :el_capitan
    sha256 "c81d5e37dc2cef21b4a65ad67c74270dc6cc99a5987c67190c4e1281ebfd4138" => :yosemite
  end

  option "with-boost", "Compile using installed boost, not the version shipped with mongodb"

  depends_on :macos => :snow_leopard
  depends_on "scons" => :build
  depends_on "boost" => :optional
  depends_on "openssl" => :optional

  def install
    # This modifies the SConstruct file to include 10.10, 10.11, and 10.12 osx versions as accepted build options.
    inreplace "SConstruct", /osx_version_choices = \[.+?\]/, "osx_version_choices = ['10.6', '10.7', '10.8', '10.9', '10.10', '10.11', '10.12']"

    args = %W[
      --prefix=#{prefix}
      -j#{ENV.make_jobs}
      --cc=#{ENV.cc}
      --cxx=#{ENV.cxx}
      --osx-version-min=#{MacOS.version}
      --full
    ]

    args << "--use-system-boost" if build.with? "boost"
    args << "--64" if MacOS.prefer_64_bit?

    # Pass the --disable-warnings-as-errors flag to Scons when on Yosemite
    # or later, otherwise 2.6.x won't build from source due to a Clang 3.5+
    # error - https://github.com/mongodb/mongo/pull/956#issuecomment-94545753
    args << "--disable-warnings-as-errors" if MacOS.version >= :yosemite

    if build.with? "openssl"
      args << "--ssl" << "--extrapath=#{Formula["openssl"].opt_prefix}"
    end

    scons "install", *args

    (buildpath+"mongod.conf").write mongodb_conf
    etc.install "mongod.conf"

    (var/"mongodb").mkpath
    (var/"log/mongodb").mkpath
  end

  def mongodb_conf; <<-EOS.undent
    systemLog:
      destination: file
      path: #{var}/log/mongodb/mongo.log
      logAppend: true
    storage:
      dbPath: #{var}/mongodb
    net:
      bindIp: 127.0.0.1
    EOS
  end

  plist_options :manual => "mongod --config #{HOMEBREW_PREFIX}/etc/mongod.conf"

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>ProgramArguments</key>
      <array>
        <string>#{opt_bin}/mongod</string>
        <string>--config</string>
        <string>#{etc}/mongod.conf</string>
      </array>
      <key>RunAtLoad</key>
      <true/>
      <key>KeepAlive</key>
      <false/>
      <key>WorkingDirectory</key>
      <string>#{HOMEBREW_PREFIX}</string>
      <key>StandardErrorPath</key>
      <string>#{var}/log/mongodb/output.log</string>
      <key>StandardOutPath</key>
      <string>#{var}/log/mongodb/output.log</string>
      <key>HardResourceLimits</key>
      <dict>
        <key>NumberOfFiles</key>
        <integer>1024</integer>
      </dict>
      <key>SoftResourceLimits</key>
      <dict>
        <key>NumberOfFiles</key>
        <integer>1024</integer>
      </dict>
    </dict>
    </plist>
    EOS
  end

  test do
    system "#{bin}/mongod", "--sysinfo"
  end
end
