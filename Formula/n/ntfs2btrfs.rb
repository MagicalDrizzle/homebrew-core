class Ntfs2btrfs < Formula
  desc "In-place conversion of NTFS filesystem to Btrfs"
  homepage "https://github.com/maharmstone/ntfs2btrfs"
  url "https://github.com/maharmstone/ntfs2btrfs/archive/refs/tags/20260810.tar.gz"
  sha256 "be3d2deb3c042c862df3ca75b46245300f45e279206bddabd8aa1fc8c92c1a58"
  license "GPL-2.0-only"

  depends_on "cmake" => :build
  depends_on "fmt" => :build
  depends_on "ninja" => :build
  depends_on "btrfs-progs" => :test
  depends_on "file-formula" => :test
  depends_on "ntfs-3g" => :test
  depends_on "lzo"
  depends_on "zlib-ng-compat"
  depends_on "zstd"

  def install
    system "cmake", "-DCMAKE_BUILD_TYPE=Release",
                    "-DCMAKE_INTERPROCEDURAL_OPTIMIZATION=ON",
                    "-DCMAKE_INSTALL_SBINDIR=#{bin}",
                    "-G", "Ninja", "-S", ".", "-B", "build", *std_cmake_args
    system "ninja", "-C", "build"
    system "ninja", "-C", "build", "install"
  end

  test do
    system "truncate", "-s", "1G", "testdisk"
    system "mkfs.ntfs", "-f", "-F", "testdisk"
    assert_match %r{NTFS partition \w+ was processed successfully}, shell_output("ntfsfix -n testdisk")
    assert_match %r{Calculating checksums (\d+) / \1}, shell_output("#{bin}/ntfs2btrfs testdisk")
    assert_match %r{found [1-9]\d* bytes used, no error found}, shell_output("btrfs check testdisk")
  end
end
