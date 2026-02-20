class NextPlaid < Formula
  desc "Multi-vector REST API server with built-in ColBERT text encoding"
  homepage "https://github.com/lightonai/next-plaid"
  # GitHub archive of the tagged release — no prebuilt next-plaid-api binaries exist in releases
  url "https://github.com/lightonai/next-plaid/archive/refs/tags/1.0.7.tar.gz"
  sha256 "5a5449ac01b9d2e7301d02c7f74097d1f38a90265a4106113429328aa35bb21d"
  license "Apache-2.0"

  depends_on "rust" => :build

  def install
    # accelerate = Apple Accelerate framework (BLAS) for matrix ops on macOS
    # model      = ONNX Runtime encoder support (enables /encode + *_with_encoding endpoints)
    # coreml is NOT a valid feature (only: accelerate, openblas, model, cuda)
    # std_cargo_args adds --locked (reproducible build) and installs directly into prefix/bin
    system "cargo", "install", *std_cargo_args(path: "next-plaid-api"),
           "--features", "accelerate,model"
  end

  def caveats
    <<~EOS
      next-plaid-api runs in two modes:

        # Embeddings-only (pass pre-computed vectors; no model required)
        next-plaid-api -p 8080 -d ~/.local/share/next-plaid

        # With built-in text encoding (downloads a HuggingFace ColBERT ONNX model)
        next-plaid-api -p 8080 -d ~/.local/share/next-plaid \\
          --model lightonai/answerai-colbert-small-v1-onnx --int8

      Each server instance loads exactly one model. Run separate instances on
      different ports if you need multiple models simultaneously.

      Swagger UI: http://localhost:8080/swagger-ui
    EOS
  end

  test do
    port = free_port
    server_pid = fork do
      exec bin/"next-plaid-api", "--port", port.to_s, "--index-dir", (testpath/"indices").to_s
    end
    sleep 2
    assert_match "healthy", shell_output("curl -sf http://localhost:#{port}/health")
  ensure
    Process.kill("TERM", server_pid) if server_pid
    Process.wait(server_pid) if server_pid
  end
end
