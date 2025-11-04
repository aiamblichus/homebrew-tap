class SaxonHe < Formula
  desc "Open-source XSLT, XQuery, and XPath processor for Java"
  homepage "https://www.saxonica.com/products/EDN/HE.html"
  url "https://github.com/Saxonica/Saxon-HE/releases/download/SaxonHE12-9/SaxonHE12-9J.zip"
  version "12.9"
  sha256 "f2895bef3794112c650a158be27c39a86e88c1717ebb8e0e88067d1f07635d12"
  license "MPL-2.0"

  depends_on "java"

  def install
    # Install all files to libexec
    libexec.install Dir["*"]

    # Build classpath with all JARs (main JARs and lib JARs)
    main_jars = Dir[libexec/"*.jar"].sort
    lib_jars = Dir[libexec/"lib/*.jar"].sort
    classpath = (main_jars + lib_jars).join(":")

    # Create wrapper script for saxon-he (XSLT)
    (bin/"saxon-he").write <<~EOS
      #!/bin/bash
      exec "#{Formula["java"].opt_bin}/java" \\
        -cp "#{classpath}" \\
        net.sf.saxon.Transform \\
        "$@"
    EOS

    # Create wrapper script for saxon-xqj (XQuery)
    (bin/"saxon-xqj").write <<~EOS
      #!/bin/bash
      exec "#{Formula["java"].opt_bin}/java" \\
        -cp "#{classpath}" \\
        net.sf.saxon.Query \\
        "$@"
    EOS

    chmod 0755, bin/"saxon-he"
    chmod 0755, bin/"saxon-xqj"
  end

  test do
    # Create a simple XML file
    (testpath/"test.xml").write <<~EOS
      <?xml version="1.0"?>
      <root>
        <child>Hello, World!</child>
      </root>
    EOS

    # Create a simple XSLT file
    (testpath/"test.xsl").write <<~EOS
      <?xml version="1.0"?>
      <xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
        <xsl:output method="html" indent="yes"/>
        <xsl:template match="/">
          <html>
            <body>
              <h1><xsl:value-of select="root/child"/></h1>
            </body>
          </html>
        </xsl:template>
      </xsl:stylesheet>
    EOS

    # Test the transformation
    system "#{bin}/saxon-he", "-s:test.xml", "-xsl:test.xsl", "-o:output.html"
    assert_predicate testpath/"output.html", :exist?
    assert_match "<h1>Hello, World!</h1>", (testpath/"output.html").read
  end
end

