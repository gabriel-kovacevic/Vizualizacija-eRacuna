<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:ubl="urn:oasis:names:specification:ubl:schema:xsd:Invoice-2"
  xmlns:cac="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2"
  xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2"
  xmlns:ext="urn:oasis:names:specification:ubl:schema:xsd:CommonExtensionComponents-2"
  xmlns:sig="urn:oasis:names:specification:ubl:schema:xsd:CommonSignatureComponents-2"
  xmlns:sac="urn:oasis:names:specification:ubl:schema:xsd:SignatureAggregateComponents-2"
  xmlns:hrextac="urn:hzn.hr:schema:xsd:HRExtensionAggregateComponents-1"
  exclude-result-prefixes="ubl cac cbc ext sig sac hrextac">

  <xsl:output method="html" indent="yes" encoding="UTF-8"/>

  <!-- Valutni simboli za čitljiv prikaz -->
  <xsl:template name="currency-symbol">
    <xsl:param name="code"/>
    <xsl:choose>
      <xsl:when test="$code='EUR'">€</xsl:when>
      <xsl:when test="$code='USD'">$</xsl:when>
      <xsl:when test="$code='GBP'">£</xsl:when>
      <xsl:otherwise><xsl:value-of select="$code"/></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Oznake jedinica mjere -->
  <xsl:template name="unit-label">
    <xsl:param name="code"/>
    <xsl:choose>
      <xsl:when test="$code='H87'">kom</xsl:when>
      <xsl:otherwise><xsl:value-of select="$code"/></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- KORIJEN -->
  <xsl:template match="/">
    <xsl:apply-templates select="/ubl:Invoice"/>
  </xsl:template>

  <!-- RENDER INVOICE (točno po tvojoj strukturi) -->
  <xsl:template match="ubl:Invoice">
    <html>
      <head>
        <meta charset="UTF-8"/>
        <title>Račun <xsl:value-of select="cbc:ID"/></title>
        <style>
          body{font-family:system-ui,Segoe UI,Roboto,Arial,sans-serif;margin:24px}
          h1{margin:0 0 8px 0}
          h2{margin:24px 0 8px 0;font-size:1.05rem}
          .grid{display:grid;grid-template-columns:1fr 1fr;gap:16px}
          table{width:100%;border-collapse:collapse;margin-top:8px}
          th,td{border:1px solid #ddd;padding:8px;vertical-align:top}
          th{background:#f7f7f7;text-align:left}
          .muted{color:#666;font-size:.9em}
          .section{margin-top:20px}
          .kv th{width:28%}
          pre{white-space:pre-wrap;margin:0}
          .badge{display:inline-block;border:1px solid #ddd;border-radius:999px;padding:2px 8px;font-size:.8em;background:#fafafa}
        </style>
      </head>
      <body>

        <!-- ZAGLAVLJE -->
        <h1>Račun <span class="badge"><xsl:value-of select="cbc:ID"/></span></h1>
        <div class="muted">
          Datum izdavanja: <xsl:value-of select="cbc:IssueDate"/>
          <xsl:text> </xsl:text>
          <xsl:value-of select="cbc:IssueTime"/>
          <xsl:text> • Dospijeće: </xsl:text><xsl:value-of select="cbc:DueDate"/>
          <xsl:text> • Valuta: </xsl:text><xsl:value-of select="cbc:DocumentCurrencyCode"/>
          <xsl:text> • Tip (kod): </xsl:text><xsl:value-of select="cbc:InvoiceTypeCode"/>
        </div>

        <!-- OPĆI PODACI (točno iz XML-a) -->
        <div class="section">
          <h2>Opći podaci</h2>
          <table class="kv">
            <tr><th>CustomizationID</th><td><xsl:value-of select="cbc:CustomizationID"/></td></tr>
            <tr><th>ProfileID</th><td><xsl:value-of select="cbc:ProfileID"/></td></tr>
            <tr>
              <th>Ekstenzije / potpis</th>
              <td>
                <xsl:choose>
                  <xsl:when test="ext:UBLExtensions/ext:UBLExtension/ext:ExtensionContent/sig:UBLDocumentSignatures/sac:SignatureInformation">
                    Prisutno (UBLDocumentSignatures / SignatureInformation)
                  </xsl:when>
                  <xsl:otherwise>Nema potpisnih podataka</xsl:otherwise>
                </xsl:choose>
              </td>
            </tr>
          </table>
        </div>

        <!-- STRANE -->
        <div class="section">
          <h2>Strane</h2>
          <div class="grid">
            <!-- Dobavljač -->
            <div>
              <h3>Dobavljač (AccountingSupplierParty)</h3>
              <table class="kv">
                <tr><th>EndpointID</th>
                  <td>
                    <xsl:value-of select="cac:AccountingSupplierParty/cac:Party/cbc:EndpointID"/>
                    <xsl:text> (schemeID=</xsl:text><xsl:value-of select="cac:AccountingSupplierParty/cac:Party/cbc:EndpointID/@schemeID"/><xsl:text>)</xsl:text>
                  </td>
                </tr>
                <tr><th>PartyIdentification.ID</th><td><xsl:value-of select="cac:AccountingSupplierParty/cac:Party/cac:PartyIdentification/cbc:ID"/></td></tr>
                <tr><th>Adresa</th>
                  <td>
                    <xsl:value-of select="cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cbc:StreetName"/>,
                    <xsl:text> </xsl:text><xsl:value-of select="cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cbc:CityName"/>
                    <xsl:text> </xsl:text><xsl:value-of select="cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cbc:PostalZone"/>
                    <xsl:text>, </xsl:text><xsl:value-of select="cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cac:Country/cbc:IdentificationCode"/>
                  </td>
                </tr>
                <tr><th>OIB / CompanyID</th><td><xsl:value-of select="cac:AccountingSupplierParty/cac:Party/cac:PartyTaxScheme/cbc:CompanyID"/></td></tr>
                <tr><th>TaxScheme.ID</th><td><xsl:value-of select="cac:AccountingSupplierParty/cac:Party/cac:PartyTaxScheme/cac:TaxScheme/cbc:ID"/></td></tr>
                <tr><th>RegistrationName</th><td><xsl:value-of select="cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cbc:RegistrationName"/></td></tr>
                <tr><th>CompanyLegalForm</th><td><pre><xsl:value-of select="cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cbc:CompanyLegalForm"/></pre></td></tr>
                <tr><th>Kontakt (Name)</th><td><xsl:value-of select="cac:AccountingSupplierParty/cac:Party/cac:Contact/cbc:Name"/></td></tr>
                <tr><th>Kontakt (Email)</th><td><xsl:value-of select="cac:AccountingSupplierParty/cac:Party/cac:Contact/cbc:ElectronicMail"/></td></tr>
                <tr><th>SellerContact.ID</th><td><xsl:value-of select="cac:AccountingSupplierParty/cac:SellerContact/cbc:ID"/></td></tr>
                <tr><th>SellerContact.Name</th><td><xsl:value-of select="cac:AccountingSupplierParty/cac:SellerContact/cbc:Name"/></td></tr>
              </table>
            </div>

            <!-- Kupac -->
            <div>
              <h3>Kupac (AccountingCustomerParty)</h3>
              <table class="kv">
                <tr><th>EndpointID</th>
                  <td>
                    <xsl:value-of select="cac:AccountingCustomerParty/cac:Party/cbc:EndpointID"/>
                    <xsl:text> (schemeID=</xsl:text><xsl:value-of select="cac:AccountingCustomerParty/cac:Party/cbc:EndpointID/@schemeID"/><xsl:text>)</xsl:text>
                  </td>
                </tr>
                <tr><th>Adresa</th>
                  <td>
                    <xsl:value-of select="cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cbc:StreetName"/>,
                    <xsl:text> </xsl:text><xsl:value-of select="cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cbc:CityName"/>
                    <xsl:text> </xsl:text><xsl:value-of select="cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cbc:PostalZone"/>
                    <xsl:text>, </xsl:text><xsl:value-of select="cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cac:Country/cbc:IdentificationCode"/>
                  </td>
                </tr>
                <tr><th>OIB / CompanyID</th><td><xsl:value-of select="cac:AccountingCustomerParty/cac:Party/cac:PartyTaxScheme/cbc:CompanyID"/></td></tr>
                <tr><th>TaxScheme.ID</th><td><xsl:value-of select="cac:AccountingCustomerParty/cac:Party/cac:PartyTaxScheme/cac:TaxScheme/cbc:ID"/></td></tr>
                <tr><th>RegistrationName</th><td><xsl:value-of select="cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity/cbc:RegistrationName"/></td></tr>
              </table>
            </div>
          </div>
        </div>

        <!-- PLAĆANJE -->
        <div class="section">
          <h2>Podaci o plaćanju</h2>
          <table class="kv">
            <tr><th>PaymentMeansCode</th><td><xsl:value-of select="cac:PaymentMeans/cbc:PaymentMeansCode"/></td></tr>
            <tr><th>InstructionNote</th><td><xsl:value-of select="cac:PaymentMeans/cbc:InstructionNote"/></td></tr>
            <tr><th>Poziv na broj (PaymentID)</th><td><xsl:value-of select="cac:PaymentMeans/cbc:PaymentID"/></td></tr>
            <tr><th>IBAN (PayeeFinancialAccount.ID)</th><td><xsl:value-of select="cac:PaymentMeans/cac:PayeeFinancialAccount/cbc:ID"/></td></tr>
          </table>
        </div>

        <!-- POREZI (točna struktura iz XML-a) -->
        <div class="section">
          <h2>Porezi (TaxTotal)</h2>
          <table>
            <thead>
              <tr>
                <th>Ukupan porez</th>
                <th>Valuta</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td><xsl:value-of select="format-number(number(cac:TaxTotal/cbc:TaxAmount),'#,##0.00')"/></td>
                <td><xsl:value-of select="cac:TaxTotal/cbc:TaxAmount/@currencyID"/></td>
              </tr>
            </tbody>
          </table>

          <h3>Stavke poreza (TaxSubtotal)</h3>
          <table>
            <thead>
              <tr>
                <th>Osnovica</th>
                <th>Porez</th>
                <th>Kategorija (ID)</th>
                <th>Stopa %</th>
                <th>TaxScheme.ID</th>
                <th>Valuta</th>
              </tr>
            </thead>
            <tbody>
              <xsl:for-each select="cac:TaxTotal/cac:TaxSubtotal">
                <tr>
                  <td><xsl:value-of select="format-number(number(cbc:TaxableAmount),'#,##0.00')"/></td>
                  <td><xsl:value-of select="format-number(number(cbc:TaxAmount),'#,##0.00')"/></td>
                  <td><xsl:value-of select="cac:TaxCategory/cbc:ID"/></td>
                  <td><xsl:value-of select="format-number(number(cac:TaxCategory/cbc:Percent),'#,##0.##')"/></td>
                  <td><xsl:value-of select="cac:TaxCategory/cac:TaxScheme/cbc:ID"/></td>
                  <td><xsl:value-of select="cbc:TaxableAmount/@currencyID"/></td>
                </tr>
              </xsl:for-each>
            </tbody>
          </table>
        </div>

        <!-- UKUPNO -->
        <div class="section">
          <h2>Ukupni iznosi (LegalMonetaryTotal)</h2>
          <table>
            <thead>
              <tr>
                <th>LineExtensionAmount</th>
                <th>TaxExclusiveAmount</th>
                <th>TaxInclusiveAmount</th>
                <th>PayableAmount</th>
                <th>Valuta</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td><xsl:value-of select="format-number(number(cac:LegalMonetaryTotal/cbc:LineExtensionAmount),'#,##0.00')"/></td>
                <td><xsl:value-of select="format-number(number(cac:LegalMonetaryTotal/cbc:TaxExclusiveAmount),'#,##0.00')"/></td>
                <td><xsl:value-of select="format-number(number(cac:LegalMonetaryTotal/cbc:TaxInclusiveAmount),'#,##0.00')"/></td>
                <td><xsl:value-of select="format-number(number(cac:LegalMonetaryTotal/cbc:PayableAmount),'#,##0.00')"/></td>
                <td><xsl:value-of select="cac:LegalMonetaryTotal/cbc:PayableAmount/@currencyID"/></td>
              </tr>
            </tbody>
          </table>
        </div>

        <!-- STAVKE RAČUNA (InvoiceLine) -->
        <div class="section">
          <h2>Stavke računa (InvoiceLine)</h2>
          <table>
            <thead>
              <tr>
                <th>R.br.</th>
                <th>Opis</th>
                <th>Šifra (listID)</th>
                <th>Količina</th>
                <th>Jed. cijena</th>
                <th>Iznos stavke</th>
                <th>PDV Kategorija</th>
                <th>PDV Naziv</th>
                <th>PDV %</th>
                <th>PDV Shema</th>
              </tr>
            </thead>
            <tbody>
              <xsl:for-each select="cac:InvoiceLine">
                <tr>
                  <td><xsl:value-of select="cbc:ID"/></td>
                  <td><xsl:value-of select="cac:Item/cbc:Name"/></td>
                  <td>
                    <xsl:value-of select="cac:Item/cac:CommodityClassification/cbc:ItemClassificationCode"/>
                    <xsl:if test="cac:Item/cac:CommodityClassification/cbc:ItemClassificationCode/@listID">
                      <xsl:text> (</xsl:text>
                      <xsl:value-of select="cac:Item/cac:CommodityClassification/cbc:ItemClassificationCode/@listID"/>
                      <xsl:text>)</xsl:text>
                    </xsl:if>
                  </td>
                  <td>
                    <xsl:value-of select="format-number(number(cbc:InvoicedQuantity),'#,##0.###')"/>
                    <xsl:text> </xsl:text>
                    <xsl:call-template name="unit-label">
                      <xsl:with-param name="code" select="cbc:InvoicedQuantity/@unitCode"/>
                    </xsl:call-template>
                  </td>
                  <td>
                    <xsl:value-of select="format-number(number(cac:Price/cbc:PriceAmount),'#,##0.000000')"/>
                    <xsl:text> </xsl:text>
                    <xsl:call-template name="currency-symbol">
                      <xsl:with-param name="code" select="cac:Price/cbc:PriceAmount/@currencyID"/>
                    </xsl:call-template>
                    <xsl:text> / </xsl:text>
                    <xsl:value-of select="format-number(number(cac:Price/cbc:BaseQuantity),'#,##0.###')"/>
                    <xsl:text> </xsl:text>
                    <xsl:call-template name="unit-label">
                      <xsl:with-param name="code" select="cac:Price/cbc:BaseQuantity/@unitCode"/>
                    </xsl:call-template>
                  </td>
                  <td>
                    <xsl:value-of select="format-number(number(cbc:LineExtensionAmount),'#,##0.00')"/>
                    <xsl:text> </xsl:text>
                    <xsl:call-template name="currency-symbol">
                      <xsl:with-param name="code" select="cbc:LineExtensionAmount/@currencyID"/>
                    </xsl:call-template>
                  </td>
                  <td><xsl:value-of select="cac:Item/cac:ClassifiedTaxCategory/cbc:ID"/></td>
                  <td><xsl:value-of select="cac:Item/cac:ClassifiedTaxCategory/cbc:Name"/></td>
                  <td><xsl:value-of select="format-number(number(cac:Item/cac:ClassifiedTaxCategory/cbc:Percent),'#,##0.##')"/></td>
                  <td><xsl:value-of select="cac:Item/cac:ClassifiedTaxCategory/cac:TaxScheme/cbc:ID"/></td>
                </tr>
              </xsl:for-each>
            </tbody>
          </table>
        </div>

      </body>
    </html>
  </xsl:template>

</xsl:stylesheet>
