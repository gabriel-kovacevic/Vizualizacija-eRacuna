<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:ubl-inv="urn:oasis:names:specification:ubl:schema:xsd:Invoice-2"
  xmlns:ubl-cn="urn:oasis:names:specification:ubl:schema:xsd:CreditNote-2"
  xmlns:cac="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2"
  xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2"
  exclude-result-prefixes="ubl-inv ubl-cn cac cbc">

  <xsl:output method="html" indent="yes" encoding="UTF-8"/>

  <!-- ================= VALUTNI SIMBOLI ================= -->
  <xsl:template name="currency-symbol">
    <xsl:param name="code"/>
    <xsl:choose>
      <xsl:when test="$code='EUR'">€</xsl:when>
      <xsl:when test="$code='USD'">$</xsl:when>
      <xsl:when test="$code='GBP'">£</xsl:when>
      <xsl:when test="$code='HRK'">kn</xsl:when>
      <xsl:when test="$code='JPY'">¥</xsl:when>
      <xsl:otherwise><xsl:value-of select="$code"/></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- ================= OZNAKE JEDINICA MJERE ================= -->
  <xsl:template name="unit-label">
    <xsl:param name="code"/>
    <xsl:choose>
      <xsl:when test="$code='H87'">kom</xsl:when>
      <xsl:when test="$code='KGM'">kg</xsl:when>
      <xsl:when test="$code='LTR'">L</xsl:when>
      <xsl:when test="$code='MTR'">m</xsl:when>
      <xsl:when test="$code='NAR'">stavka</xsl:when>
      <xsl:otherwise><xsl:value-of select="$code"/></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- ================= POČETNI ODABIR DOKUMENTA ================= -->
  <xsl:template match="/">
    <xsl:choose>
      <xsl:when test="/ubl-inv:Invoice">
        <xsl:apply-templates select="/ubl-inv:Invoice"/>
      </xsl:when>
      <xsl:when test="/ubl-cn:CreditNote">
        <xsl:apply-templates select="/ubl-cn:CreditNote"/>
      </xsl:when>
      <xsl:otherwise>
        <html><body><p>Vrsta UBL dokumenta nije podržana.</p></body></html>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- ================= PREDLOŽAK: RAČUN ================= -->
  <xsl:template match="/ubl-inv:Invoice">
    <xsl:call-template name="render-document">
      <xsl:with-param name="docType" select="'Račun '"/>
      <xsl:with-param name="lineElement" select="'cac:InvoiceLine'"/>
      <xsl:with-param name="quantityElement" select="'cbc:InvoicedQuantity'"/>
      <xsl:with-param name="totalLabel" select="'Ukupan iznos za plaćanje: '"/>
    </xsl:call-template>
  </xsl:template>

  <!-- ================= PREDLOŽAK: ODOBRENJE RAČUNA ================= -->
  <xsl:template match="/ubl-cn:CreditNote">
    <xsl:call-template name="render-document">
      <xsl:with-param name="docType" select="'Odobrenje računa '"/>
      <xsl:with-param name="lineElement" select="'cac:CreditNoteLine'"/>
      <xsl:with-param name="quantityElement" select="'cbc:CreditedQuantity'"/>
      <xsl:with-param name="totalLabel" select="'Ukupan iznos odobrenja: '"/>
    </xsl:call-template>
  </xsl:template>

  <!-- ================= GLAVNI PREDLOŽAK ZA PRIKAZ ================= -->
  <xsl:template name="render-document">
    <xsl:param name="docType"/>
    <xsl:param name="lineElement"/>
    <xsl:param name="quantityElement"/>
    <xsl:param name="totalLabel"/>

    <html>
      <head>
        <meta charset="UTF-8"/>
        <title><xsl:value-of select="$docType"/> <xsl:value-of select="cbc:ID"/></title>
        <link rel="stylesheet" href="invoice.css"/>
      </head>
      <body>
        <div class="invoice">

          <!-- ZAGLAVLJE -->
          <div class="invoice-header">
            <h1><xsl:value-of select="$docType"/> <xsl:value-of select="cbc:ID"/></h1>
            <div>
              <strong>Datum izdavanja računa: </strong><xsl:value-of select="cbc:IssueDate"/> |
              <strong>Valuta: </strong><xsl:value-of select="cbc:DocumentCurrencyCode"/>
            </div>
            <xsl:if test="cbc:DueDate">
              <div><strong>Datum dospijeća: </strong><xsl:value-of select="cbc:DueDate"/></div>
            </xsl:if>
            
            <xsl:if test="cac:BillingReference/cac:InvoiceDocumentReference/cbc:ID">
              <div>
                <strong>Povezani račun: </strong>
                <xsl:value-of select="cac:BillingReference/cac:InvoiceDocumentReference/cbc:ID"/>
                (<xsl:value-of select="cac:BillingReference/cac:InvoiceDocumentReference/cbc:IssueDate"/>)
              </div>
            </xsl:if>
          </div>

          <!-- STRANE UGOVORNE -->
          <div class="parties">
            <div>
              <h2>Dobavljač</h2>
              <xsl:value-of select="cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cbc:RegistrationName"/><br/>
              <xsl:value-of select="cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cbc:StreetName"/><br/>
              <xsl:value-of select="cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cbc:CityName"/>,
              <xsl:value-of select="cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cbc:PostalZone"/><br/>
              OIB: <xsl:text> </xsl:text><xsl:value-of select="cac:AccountingSupplierParty/cac:Party/cac:PartyTaxScheme/cbc:CompanyID"/><br/>
              E-pošta: <xsl:text> </xsl:text><xsl:value-of select="cac:AccountingSupplierParty/cac:Party/cac:Contact/cbc:ElectronicMail"/>
            </div>

            <div>
              <h2>Kupac</h2>
              <xsl:value-of select="cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity/cbc:RegistrationName"/><br/>
              <xsl:value-of select="cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cbc:StreetName"/><br/>
              <xsl:value-of select="cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cbc:CityName"/>,
              <xsl:value-of select="cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cbc:PostalZone"/><br/>
              OIB: <xsl:text> </xsl:text><xsl:value-of select="cac:AccountingCustomerParty/cac:Party/cac:PartyTaxScheme/cbc:CompanyID"/>
            </div>
          </div>

          <!-- STAVKE RAČUNA -->
          <div class="invoice-lines">
            <h2>Stavke računa</h2>
            <table>
              <thead>
                <tr>
                  <th>Redni broj</th>
                  <th>Opis artikla/usluge</th>
                  <th>Količina</th>
                  <th>Jedinična cijena</th>
                  <th>Iznos</th>
                </tr>
              </thead>
              <tbody>
                <xsl:for-each select="*[name()=$lineElement]">
                  <tr>
                    <td><xsl:value-of select="cbc:ID"/></td>
                    <td><xsl:value-of select="cac:Item/cbc:Name"/></td>
                    <td>
                      <xsl:value-of select="format-number(number(*[name()=$quantityElement]), '#,##0.###')"/>
                      <xsl:text> </xsl:text>
                      <xsl:call-template name="unit-label">
                        <xsl:with-param name="code" select="*[name()=$quantityElement]/@unitCode"/>
                      </xsl:call-template>
                    </td>
                    <td>
                      <xsl:value-of select="format-number(number(cac:Price/cbc:PriceAmount), '#,##0.00')"/>
                      <xsl:text> </xsl:text>
                      <xsl:call-template name="currency-symbol">
                        <xsl:with-param name="code" select="cac:Price/cbc:PriceAmount/@currencyID"/>
                      </xsl:call-template>
                    </td>
                    <td>
                      <xsl:value-of select="format-number(number(cbc:LineExtensionAmount), '#,##0.00')"/>
                      <xsl:text> </xsl:text>
                      <xsl:call-template name="currency-symbol">
                        <xsl:with-param name="code" select="cbc:LineExtensionAmount/@currencyID"/>
                      </xsl:call-template>
                    </td>
                  </tr>
                </xsl:for-each>
              </tbody>
            </table>
          </div>

          <!-- POREZI I NAKNADE -->
          <div class="taxes">
            <h2>Porezi i naknade</h2>
            <xsl:for-each select="cac:TaxTotal">
              <div class="tax-line">
                <strong>Ukupni iznos poreza: </strong>
                <xsl:value-of select="format-number(number(cbc:TaxAmount), '#,##0.00')"/>
                <xsl:text> </xsl:text>
                <xsl:call-template name="currency-symbol">
                  <xsl:with-param name="code" select="cbc:TaxAmount/@currencyID"/>
                </xsl:call-template><br/>
                <xsl:for-each select="cac:TaxSubtotal">
                  <xsl:value-of select="cac:TaxCategory/cbc:Name"/> — 
                  <xsl:value-of select="format-number(number(cac:TaxCategory/cbc:Percent), '#,##0.##')"/>%
                  (<strong>Porezna osnovica: </strong>
                  <xsl:value-of select="format-number(number(cbc:TaxableAmount), '#,##0.00')"/>
                  <xsl:text> </xsl:text>
                  <xsl:call-template name="currency-symbol">
                    <xsl:with-param name="code" select="cbc:TaxableAmount/@currencyID"/>
                  </xsl:call-template>)
                  <br/>
                </xsl:for-each>
              </div>
            </xsl:for-each>
          </div>

          <!-- UKUPNI IZNOSI -->
          <div class="totals">
            <h2>Ukupni iznosi</h2>
            <div><strong>Ukupno bez PDV-a: </strong>
              <xsl:value-of select="format-number(number(cac:LegalMonetaryTotal/cbc:LineExtensionAmount), '#,##0.00')"/>
              <xsl:text> </xsl:text>
              <xsl:call-template name="currency-symbol">
                <xsl:with-param name="code" select="cac:LegalMonetaryTotal/cbc:LineExtensionAmount/@currencyID"/>
              </xsl:call-template>
            </div>
            <div><strong>Iznos bez poreza: </strong>
              <xsl:value-of select="format-number(number(cac:LegalMonetaryTotal/cbc:TaxExclusiveAmount), '#,##0.00')"/>
              <xsl:text> </xsl:text>
              <xsl:call-template name="currency-symbol">
                <xsl:with-param name="code" select="cac:LegalMonetaryTotal/cbc:TaxExclusiveAmount/@currencyID"/>
              </xsl:call-template>
            </div>
            <div><strong>Iznos s porezom: </strong>
              <xsl:value-of select="format-number(number(cac:LegalMonetaryTotal/cbc:TaxInclusiveAmount), '#,##0.00')"/>
              <xsl:text> </xsl:text>
              <xsl:call-template name="currency-symbol">
                <xsl:with-param name="code" select="cac:LegalMonetaryTotal/cbc:TaxInclusiveAmount/@currencyID"/>
              </xsl:call-template>
            </div>
            <div class="total-amount"><strong><xsl:value-of select="$totalLabel"/></strong>
              <xsl:value-of select="format-number(number(cac:LegalMonetaryTotal/cbc:PayableAmount), '#,##0.00')"/>
              <xsl:text> </xsl:text>
              <xsl:call-template name="currency-symbol">
                <xsl:with-param name="code" select="cac:LegalMonetaryTotal/cbc:PayableAmount/@currencyID"/>
              </xsl:call-template>
            </div>
          </div>

          <!-- PODACI O PLAĆANJU -->
          <div class="notes">
            <h2>Podaci o plaćanju</h2>
            <strong>Napomena za plaćanje: </strong><xsl:value-of select="cac:PaymentMeans/cbc:InstructionNote"/><br/>
            <strong>Identifikator plaćanja: </strong><xsl:value-of select="cac:PaymentMeans/cbc:PaymentID"/><br/>
            <strong>Broj računa primatelja: </strong><xsl:value-of select="cac:PaymentMeans/cac:PayeeFinancialAccount/cbc:ID"/>
          </div>

        </div>
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>
