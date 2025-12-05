<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
      xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
      xmlns:inv="urn:oasis:names:specification:ubl:schema:xsd:Invoice-2"
      xmlns:cac="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2"
      xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2"
      xmlns:ext="urn:oasis:names:specification:ubl:schema:xsd:CommonExtensionComponents-2"
      exclude-result-prefixes="inv cac cbc ext">

  <!-- Glavni izlaz: HTML dokument -->
  <xsl:output method="html" indent="yes" encoding="UTF-8"/>

  <!-- Glavni korijen -->
  <xsl:template match="/">
    <html>
      <head>
        <meta charset="UTF-8"/>
		<link rel="stylesheet" href="invoice.css"/>
        <title>XML pregled – UBL Invoice</title>
        <style>
          body {
            font-family: Consolas, monospace;
            background: #f8f8f8;
            color: #222;
            padding: 20px;
          }
          .element {
            margin-left: 20px;
            border-left: 1px solid #ccc;
            padding-left: 10px;
          }
          .tag {
            color: #0077aa;
          }
          .attr {
            color: #aa5500;
          }
          .text {
            color: #000;
          }
        </style>
      </head>
      <body>
        <h2>Prikaz XML dokumenta</h2>
        <pre>
<xsl:apply-templates select="*"/>
        </pre>
      </body>
    </html>
  </xsl:template>

  <!-- Šablona za sve elemente -->
  <xsl:template match="*">
    <span class="tag">&lt;<xsl:value-of select="name()"/></span>
    <!-- atributi -->
    <xsl:for-each select="@*">
      <span> </span>
      <span class="attr"><xsl:value-of select="name()"/></span>
      ="
      <span class="text"><xsl:value-of select="."/></span>"
    </xsl:for-each>
    <span class="tag">&gt;</span>

    <!-- sadržaj -->
    <xsl:choose>
      <xsl:when test="node()">
        <div class="element">
          <xsl:apply-templates select="node()"/>
        </div>
      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>

    <span class="tag">&lt;/<xsl:value-of select="name()"/>&gt;</span>
  </xsl:template>

  <!-- Šablona za tekst -->
  <xsl:template match="text()">
    <span class="text"><xsl:value-of select="normalize-space(.)"/></span>
  </xsl:template>

  <!-- Komentari -->
  <xsl:template match="comment()">
    <span style="color:gray">&lt;!--<xsl:value-of select="."/>--&gt;</span>
  </xsl:template>

  <!-- Procesne instrukcije (npr. <?xml ... ?>) -->
  <xsl:template match="processing-instruction()">
    <span style="color:gray">&lt;?<xsl:value-of select="name()"/> <xsl:value-of select=".""/>?&gt;</span>
  </xsl:template>

</xsl:stylesheet>
