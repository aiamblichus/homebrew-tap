class Colgrep < Formula
  desc "Semantic code search for your terminal and coding agents"
  homepage "https://github.com/lightonai/next-plaid"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/lightonai/next-plaid/releases/download/1.0.7/colgrep-aarch64-apple-darwin.tar.xz"
      sha256 "67eabc691f8eb77118ca5dc41eb86389b6500ac42cd0b491a36965d5ee3edf7b"
    end

    on_intel do
      url "https://github.com/lightonai/next-plaid/releases/download/1.0.7/colgrep-x86_64-apple-darwin.tar.xz"
      sha256 "cd39b59c1f2828b801b3dcc5cf3bc9674d21df115d31ec3b98523dfdc00d9e2b"
    end
  end

  def install
    bin.install "colgrep"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/colgrep --version 2>&1")
  end
end
