<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:ubl-inv="urn:oasis:names:specification:ubl:schema:xsd:Invoice-2"
  xmlns:ubl-cn="urn:oasis:names:specification:ubl:schema:xsd:CreditNote-2"
  xmlns:cac="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2"
  xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2"
  xmlns:ext="urn:oasis:names:specification:ubl:schema:xsd:CommonExtensionComponents-2"
  xmlns:sig="urn:oasis:names:specification:ubl:schema:xsd:CommonSignatureComponents-2"
  xmlns:sac="urn:oasis:names:specification:ubl:schema:xsd:SignatureAggregateComponents-2"
  xmlns:hrextac="urn:hzn.hr:schema:xsd:HRExtensionAggregateComponents-1"
  exclude-result-prefixes="ubl-inv ubl-cn cac cbc ext sig sac hrextac">

  <xsl:output method="html" indent="yes" encoding="UTF-8" />

  <!-- ================= VALUTNI SIMBOLI ================= -->
  <xsl:template name="currency-symbol">
    <xsl:param name="code" />
    <xsl:choose>
      <xsl:when test="$code='EUR'">€</xsl:when>
      <xsl:when test="$code='USD'">$</xsl:when>
      <xsl:when test="$code='GBP'">£</xsl:when>
      <xsl:when test="$code='HRK'">kn</xsl:when>
      <xsl:when test="$code='JPY'">¥</xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$code" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- ================= OZNAKE JEDINICA MJERE ================= -->
  <xsl:template name="unit-label">
    <xsl:param name="code" />
    <xsl:choose>
      <xsl:when test="$code='H87'">kom</xsl:when>
      <xsl:when test="$code='KGM'">kg</xsl:when>
      <xsl:when test="$code='LTR'">L</xsl:when>
      <xsl:when test="$code='MTR'">m</xsl:when>
      <xsl:when test="$code='NAR'">stavka</xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$code" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- ================= ODABIR VRSTE DOKUMENTA ================= -->
  <xsl:template match="/">
    <xsl:choose>
      <xsl:when test="/ubl-inv:Invoice">
        <xsl:apply-templates select="/ubl-inv:Invoice" />
      </xsl:when>
      <xsl:when test="/ubl-cn:CreditNote">
        <xsl:apply-templates select="/ubl-cn:CreditNote" />
      </xsl:when>
      <xsl:otherwise>
        <html>
          <body>
            <p>Vrsta UBL dokumenta nije podržana.</p>
          </body>
        </html>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- ================= INVOICE ================= -->
  <xsl:template match="/ubl-inv:Invoice">
    <xsl:call-template name="render-document">
      <xsl:with-param name="docType" select="'Račun'" />
      <xsl:with-param name="lineElement" select="'cac:InvoiceLine'" />
      <xsl:with-param name="typeCode" select="'cbc:InvoiceTypeCode'" />
      <xsl:with-param name="quantityElement" select="'cbc:InvoicedQuantity'" />
      <xsl:with-param name="totalLabel" select="'Ukupan iznos za plaćanje:'" />
    </xsl:call-template>
  </xsl:template>

  <!-- ================= CREDIT NOTE ================= -->
  <xsl:template match="/ubl-cn:CreditNote">
    <xsl:call-template name="render-document">
      <xsl:with-param name="docType" select="'Odobrenje računa'" />
      <xsl:with-param name="lineElement" select="'cac:CreditNoteLine'" />
      <xsl:with-param name="typeCode" select="'cbc:CreditNoteTypeCode'" />
      <xsl:with-param name="quantityElement" select="'cbc:CreditedQuantity'" />
      <xsl:with-param name="totalLabel" select="'Ukupan iznos odobrenja:'" />
    </xsl:call-template>
  </xsl:template>

  <!-- ================= GLAVNI PREDLOŽAK ================= -->
  <xsl:template name="render-document">
    <xsl:param name="docType" />
    <xsl:param name="lineElement" />
    <xsl:param name="quantityElement" />
    <xsl:param name="totalLabel" />
    <xsl:param name="typeCode" />

    <html>
      <head>
        <meta charset="UTF-8" />
        <title>
          <xsl:value-of select="$docType" />
          <xsl:value-of select="cbc:ID" />
        </title>
        <link rel="stylesheet" href="invoice.css" />
      </head>
      <body>
        <div class="invoice">

          <!-- ========== ZAGLAVLJE ========== -->
          <div class="invoice-header">
            <h1>
              <xsl:value-of select="$docType" />
              <xsl:text> </xsl:text>
              <xsl:value-of select="cbc:ID" />
            </h1>
            <div>
              <strong>Datum izdavanja: </strong><xsl:value-of select="cbc:IssueDate" />
              <xsl:if
                test="cbc:IssueTime">
                <xsl:text> </xsl:text>
                <xsl:value-of select="cbc:IssueTime" />
              </xsl:if> | <strong>Valuta: </strong><xsl:value-of
                select="cbc:DocumentCurrencyCode" />
            </div>
            <div>
              <strong>Vrsta dokumenta (kod): </strong>
              <xsl:value-of select="*[name()=$typeCode]" />
            </div>
            <!-- FISKALNI PODACI -->
            <xsl:if test="cbc:DueDate">
              <div>
                <strong>Datum dospijeća: </strong>
                <xsl:value-of select="cbc:DueDate" />
              </div>
            </xsl:if>
          </div>

          <!-- ========== OPĆI PODACI ========== -->

          <!-- ========== STRANE ========== -->
          <div class="parties">
            <div>
              <h2>Dobavljač</h2>
              <xsl:value-of
                select="cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cbc:RegistrationName" /><br />
              <xsl:value-of
                select="cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cbc:StreetName" /><br />
              <xsl:value-of
                select="cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cbc:CityName" />, <xsl:value-of
                select="cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cbc:PostalZone" /><br />
              OIB: <xsl:value-of
                select="cac:AccountingSupplierParty/cac:Party/cac:PartyTaxScheme/cbc:CompanyID" /><br />
              <xsl:if
                test="cac:AccountingSupplierParty/cac:Party/cac:PartyIdentification"> Poslovna
              jedinica: <xsl:value-of
                  select="cac:AccountingSupplierParty/cac:Party/cac:PartyIdentification/cbc:ID" />
              </xsl:if>
              <xsl:if
                test="cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cbc:CompanyLegalForm">
                <div class="company-legalform">
                  <em>
                    <xsl:value-of
                      select="cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cbc:CompanyLegalForm" />
                  </em>
                </div>
              </xsl:if>
              <xsl:if
                test="cac:AccountingSupplierParty/cac:SellerContact">
                <div class="seller-contact">
                  <strong>Operater: </strong>
                  <xsl:value-of
                    select="cac:AccountingSupplierParty/cac:SellerContact/cbc:Name" /> (<xsl:value-of
                    select="cac:AccountingSupplierParty/cac:SellerContact/cbc:ID" />) </div>
              </xsl:if>
            </div>

            <div>
              <h2>Kupac</h2>
              <xsl:value-of
                select="cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity/cbc:RegistrationName" /><br />
              <xsl:value-of
                select="cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cbc:StreetName" /><br />
              <xsl:value-of
                select="cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cbc:CityName" />, <xsl:value-of
                select="cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cbc:PostalZone" /><br />
              OIB: <xsl:value-of
                select="cac:AccountingCustomerParty/cac:Party/cac:PartyTaxScheme/cbc:CompanyID" /><br />
              <xsl:if
                test="cac:AccountingCustomerParty/cac:Party/cac:PartyIdentification"> Poslovna
              jedinica: <xsl:value-of
                  select="cac:AccountingCustomerParty/cac:Party/cac:PartyIdentification/cbc:ID" />
              </xsl:if>
            </div>
          </div>

          <!-- ========== DOSTAVA ========== -->
          <xsl:if test="cac:Delivery">
            <div class="delivery section">
              <h2>Podaci o dostavi</h2>
              <xsl:for-each select="cac:Delivery">
                <xsl:if test="cac:DeliveryLocation/cac:Address">
                  <div>
                    <strong>Adresa dostave: </strong>
                    <xsl:value-of
                      select="cac:DeliveryLocation/cac:Address/cbc:StreetName" />, <xsl:value-of
                      select="cac:DeliveryLocation/cac:Address/cbc:CityName" /> (<xsl:value-of
                      select="cac:DeliveryLocation/cac:Address/cbc:PostalZone" />) </div>
                </xsl:if>
                <xsl:if test="cac:ActualDeliveryDate">
                  <div>
                    <strong>Datum dostave: </strong>
                    <xsl:value-of select="cac:ActualDeliveryDate" />
                  </div>
                </xsl:if>
                <xsl:if test="cac:DeliveryParty/cac:PartyName/cbc:Name">
                  <div>
                    <strong>Isporučitelj: </strong>
                    <xsl:value-of select="cac:DeliveryParty/cac:PartyName/cbc:Name" />
                  </div>
                </xsl:if>
              </xsl:for-each>
            </div>
          </xsl:if>

          <!-- ========== STAVKE ========== -->
          <div class="invoice-lines section">
            <h2>Stavke računa</h2>
            <table>
              <thead>
                <tr>
                  <th>R.br.</th>
                  <th>Opis</th>
                  <th>Količina</th>
                  <th>Jedinična cijena</th>
                  <th>Iznos</th>
                </tr>
              </thead>
              <tbody>
                <xsl:for-each select="*[name()=$lineElement]">
                  <tr>
                    <td>
                      <xsl:value-of select="cbc:ID" />
                    </td>
                    <td>
                      <xsl:value-of select="cac:Item/cbc:Name" />
                      <xsl:if test="cac:Item/cac:CommodityClassification/cbc:ItemClassificationCode">
                        <br />
                        <span class="small">Šifra: <xsl:value-of
                            select="cac:Item/cac:CommodityClassification/cbc:ItemClassificationCode" /></span>
                      </xsl:if>
                    </td>
                    <td>
                      <xsl:value-of
                        select="format-number(number(*[name()=$quantityElement]), '#,##0.###')" />
                      <xsl:text> </xsl:text>
                      <xsl:call-template name="unit-label">
                        <xsl:with-param name="code" select="*[name()=$quantityElement]/@unitCode" />
                      </xsl:call-template>
                    </td>
                    <td>
                      <xsl:value-of
                        select="format-number(number(cac:Price/cbc:PriceAmount), '#,##0.00')" />
                      <xsl:text> </xsl:text>
                      <xsl:call-template name="currency-symbol">
                        <xsl:with-param name="code" select="cac:Price/cbc:PriceAmount/@currencyID" />
                      </xsl:call-template>
                    </td>
                    <td>
                      <xsl:value-of
                        select="format-number(number(cbc:LineExtensionAmount), '#,##0.00')" />
                      <xsl:text> </xsl:text>
                      <xsl:call-template name="currency-symbol">
                        <xsl:with-param name="code" select="cbc:LineExtensionAmount/@currencyID" />
                      </xsl:call-template>
                    </td>
                  </tr>
                </xsl:for-each>
              </tbody>
            </table>
          </div>
          <div class="invoice-reference">
            <xsl:if test="cac:BillingReference">
              <div>
                <h2>Reference na povezane dokumente</h2>
              </div>
              <xsl:for-each select="cac:BillingReference/cac:InvoiceDocumentReference">
                <div class="billing-ref">
                  <div>
                    <strong>Broj dokumenta: </strong>
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="cbc:ID" />
                  </div>
                  <xsl:if test="cbc:IssueDate">
                    <div>
                      <strong>Datum izdavanja: </strong>
                      <xsl:text> </xsl:text>
                      <xsl:value-of select="cbc:IssueDate" />
                    </div>
                  </xsl:if>
                  <xsl:if test="cbc:DocumentDescription">
                    <div>
                      <strong>Opis: </strong>
                      <div class="document-description">
                        <xsl:value-of select="cbc:DocumentDescription" disable-output-escaping="yes" />
                      </div>
                    </div>
                  </xsl:if>
                </div>
              </xsl:for-each>
            </xsl:if>
          </div>

          <!-- ========== UKUPNO, POREZI, PLAĆANJE ========== -->
          <div class="taxes section">
            <h2>Porezi</h2>

            <xsl:choose>
              <!-- HRFISK taxes if present -->
              <xsl:when
                test="ext:UBLExtensions/ext:UBLExtension/ext:ExtensionContent/hrextac:HRFISK20Data/hrextac:HRTaxTotal">
                <table border="1" cellpadding="5" cellspacing="0">
                  <thead>
                    <tr>
                      <th>Osnovica</th>
                      <th>Porez</th>
                      <th>Kategorija (ID)</th>
                      <th>Stopa (%)</th>
                      <th>Valuta</th>
                    </tr>
                  </thead>
                  <tbody>
                    <xsl:for-each
                      select="ext:UBLExtensions/ext:UBLExtension/ext:ExtensionContent/hrextac:HRFISK20Data/hrextac:HRTaxTotal/hrextac:HRTaxSubtotal">
                      <xsl:for-each select="hrextac:HRTaxCategory">
                        <tr>
                          <td>
                            <xsl:value-of select="format-number(../cbc:TaxableAmount, '#,##0.00')" />
                          </td>
                          <td>
                            <xsl:value-of select="format-number(../cbc:TaxAmount, '#,##0.00')" />
                          </td>
                          <td>
                            <xsl:value-of select="cbc:Name" /> (<xsl:value-of select="cbc:ID" />) </td>
                          <td>
                            <xsl:value-of select="format-number(cbc:Percent, '#,##0.##')" />
                          </td>
                          <td>
                            <xsl:value-of select="../cbc:TaxableAmount/@currencyID" />
                          </td>
                        </tr>
                      </xsl:for-each>
                    </xsl:for-each>
                  </tbody>
                  <tfoot>
                    <tr>
                      <td colspan="1">
                        <strong>Ukupno poreza:</strong>
                      </td>
                      <td colspan="4">
                        <xsl:value-of
                          select="format-number(ext:UBLExtensions/ext:UBLExtension/ext:ExtensionContent/hrextac:HRFISK20Data/hrextac:HRTaxTotal/cbc:TaxAmount, '#,##0.00')" />
                        <xsl:text> </xsl:text>
                        <xsl:value-of
                          select="ext:UBLExtensions/ext:UBLExtension/ext:ExtensionContent/hrextac:HRFISK20Data/hrextac:HRTaxTotal/cbc:TaxAmount/@currencyID" />
                      </td>
                    </tr>
                  </tfoot>
                </table>
              </xsl:when>

              <!-- Fallback to standard UBL taxes -->
              <xsl:otherwise>
                <table border="1" cellpadding="5" cellspacing="0">
                  <thead>
                    <tr>
                      <th>Osnovica</th>
                      <th>Porez</th>
                      <th>Kategorija (ID)</th>
                      <th>Stopa (%)</th>
                      <th>Valuta</th>
                    </tr>
                  </thead>
                  <tbody>
                    <xsl:for-each select="cac:TaxTotal/cac:TaxSubtotal">
                      <xsl:for-each select="cac:TaxCategory">
                        <tr>
                          <td>
                            <xsl:value-of select="format-number(../cbc:TaxableAmount, '#,##0.00')" />
                          </td>
                          <td>
                            <xsl:value-of select="format-number(../cbc:TaxAmount, '#,##0.00')" />
                          </td>
                          <td>
                            <xsl:value-of select="cbc:Name" /> (<xsl:value-of select="cbc:ID" />) </td>
                          <td>
                            <xsl:value-of select="format-number(cbc:Percent, '#,##0.##')" />
                          </td>
                          <td>
                            <xsl:value-of select="../cbc:TaxableAmount/@currencyID" />
                          </td>
                        </tr>
                      </xsl:for-each>
                    </xsl:for-each>
                  </tbody>
                  <tfoot>
                    <tr>
                      <td colspan="1">
                        <strong>Ukupno poreza:</strong>
                      </td>
                      <td colspan="4">
                        <xsl:value-of select="format-number(cac:TaxTotal/cbc:TaxAmount, '#,##0.00')" />
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="cac:TaxTotal/cbc:TaxAmount/@currencyID" />
                      </td>
                    </tr>
                  </tfoot>
                </table>
              </xsl:otherwise>
            </xsl:choose>
          </div>


          <div class="totals section">
            <h2>Ukupni iznosi</h2>

            <xsl:choose>
              <!-- Use HRFISK totals if present -->
              <xsl:when
                test="ext:UBLExtensions/ext:UBLExtension/ext:ExtensionContent/hrextac:HRFISK20Data/hrextac:HRLegalMonetaryTotal">
                <div>
                  <strong>Bez PDV-a: </strong>
                  <xsl:value-of
                    select="format-number(number(ext:UBLExtensions/ext:UBLExtension/ext:ExtensionContent/hrextac:HRFISK20Data/hrextac:HRLegalMonetaryTotal/cbc:TaxExclusiveAmount), '#,##0.00')" />
                  <xsl:text> </xsl:text>
                  <xsl:call-template name="currency-symbol">
                    <xsl:with-param name="code"
                      select="ext:UBLExtensions/ext:UBLExtension/ext:ExtensionContent/hrextac:HRFISK20Data/hrextac:HRLegalMonetaryTotal/cbc:TaxExclusiveAmount/@currencyID" />
                  </xsl:call-template>
                </div>

                <xsl:if
                  test="ext:UBLExtensions/ext:UBLExtension/ext:ExtensionContent/hrextac:HRFISK20Data/hrextac:HRLegalMonetaryTotal/hrextac:OutOfScopeOfVATAmount">
                  <div>
                    <strong>Iznos izvan opsega PDV-a: </strong>
                    <xsl:value-of
                      select="format-number(number(ext:UBLExtensions/ext:UBLExtension/ext:ExtensionContent/hrextac:HRFISK20Data/hrextac:HRLegalMonetaryTotal/hrextac:OutOfScopeOfVATAmount), '#,##0.00')" />
                    <xsl:text> </xsl:text>
                    <xsl:call-template name="currency-symbol">
                      <xsl:with-param name="code"
                        select="ext:UBLExtensions/ext:UBLExtension/ext:ExtensionContent/hrextac:HRFISK20Data/hrextac:HRLegalMonetaryTotal/hrextac:OutOfScopeOfVATAmount/@currencyID" />
                    </xsl:call-template>
                  </div>
                </xsl:if>

                <div>
                  <strong>
                    <xsl:value-of select="$totalLabel" />
                  </strong>
                  <!-- Sum of TaxExclusiveAmount + OutOfScopeOfVATAmount if both exist -->
                  <xsl:variable name="taxExcl"
                    select="number(ext:UBLExtensions/ext:UBLExtension/ext:ExtensionContent/hrextac:HRFISK20Data/hrextac:HRLegalMonetaryTotal/cbc:TaxExclusiveAmount)" />
                  <xsl:variable name="outOfScope"
                    select="number(ext:UBLExtensions/ext:UBLExtension/ext:ExtensionContent/hrextac:HRFISK20Data/hrextac:HRLegalMonetaryTotal/hrextac:OutOfScopeOfVATAmount)" />
                  <xsl:value-of select="format-number($taxExcl + $outOfScope, '#,##0.00')" />
                  <xsl:text> </xsl:text>
                  <xsl:call-template name="currency-symbol">
                    <xsl:with-param name="code"
                      select="ext:UBLExtensions/ext:UBLExtension/ext:ExtensionContent/hrextac:HRFISK20Data/hrextac:HRLegalMonetaryTotal/cbc:TaxExclusiveAmount/@currencyID" />
                  </xsl:call-template>
                </div>

              </xsl:when>

              <xsl:otherwise>
                <!-- Fallback to standard UBL totals -->
                <div>
                  <strong>Bez PDV-a: </strong>
                  <xsl:value-of
                    select="format-number(number(cac:LegalMonetaryTotal/cbc:TaxExclusiveAmount), '#,##0.00')" />
                  <xsl:text> </xsl:text>
                  <xsl:call-template name="currency-symbol">
                    <xsl:with-param name="code"
                      select="cac:LegalMonetaryTotal/cbc:TaxExclusiveAmount/@currencyID" />
                  </xsl:call-template>
                </div>

                <div>
                  <strong>S PDV-om: </strong>
                  <xsl:value-of
                    select="format-number(number(cac:LegalMonetaryTotal/cbc:TaxInclusiveAmount), '#,##0.00')" />
                  <xsl:text> </xsl:text>
                  <xsl:call-template name="currency-symbol">
                    <xsl:with-param name="code"
                      select="cac:LegalMonetaryTotal/cbc:TaxInclusiveAmount/@currencyID" />
                  </xsl:call-template>
                </div>

                <xsl:if test="cac:LegalMonetaryTotal/cbc:PrepaidAmount">
                  <div>
                    <strong>Unaprijed plaćen iznos: </strong>
                    <xsl:value-of
                      select="format-number(number(cac:LegalMonetaryTotal/cbc:PrepaidAmount), '#,##0.00')" />
                    <xsl:text> </xsl:text>
                    <xsl:call-template name="currency-symbol">
                      <xsl:with-param name="code"
                        select="cac:LegalMonetaryTotal/cbc:PrepaidAmount/@currencyID" />
                    </xsl:call-template>
                  </div>
                </xsl:if>

                <div>
                  <strong>
                    <xsl:value-of select="$totalLabel" />
                  </strong>
                  <xsl:value-of
                    select="format-number(number(cac:LegalMonetaryTotal/cbc:PayableAmount), '#,##0.00')" />
                  <xsl:text> </xsl:text>
                  <xsl:call-template name="currency-symbol">
                    <xsl:with-param name="code"
                      select="cac:LegalMonetaryTotal/cbc:PayableAmount/@currencyID" />
                  </xsl:call-template>
                </div>
              </xsl:otherwise>
            </xsl:choose>
          </div>


          <div class="payment-means section">
            <h2>Podaci o plaćanju</h2>
            <table>
              <tr>
                <th>Način plaćanja</th>
                <td>
                  <xsl:value-of select="cac:PaymentMeans/cbc:PaymentMeansCode" />
                </td>
              </tr>
              <tr>
                <th>Napomena</th>
                <td>
                  <xsl:value-of select="cac:PaymentMeans/cbc:InstructionNote" />
                </td>
              </tr>
              <xsl:for-each select="ext:UBLExtensions/ext:UBLExtension">
                <xsl:if
                  test="ext:ExtensionContent/hrextac:HRFISK20Data/hrextac:HRObracunPDVPoNaplati">
                  <tr>
                    <th>Obračun PDV-a po naplati:</th>
                    <td>
                      <xsl:value-of
                        select="ext:ExtensionContent/hrextac:HRFISK20Data/hrextac:HRObracunPDVPoNaplati" />
                    </td>
                  </tr>
                </xsl:if>
              </xsl:for-each>
              <tr>
                <th>Poziv na broj</th>
                <td>
                  <xsl:value-of select="cac:PaymentMeans/cbc:PaymentID" />
                </td>
              </tr>
              <tr>
                <th>IBAN primatelja</th>
                <td>
                  <xsl:value-of select="cac:PaymentMeans/cac:PayeeFinancialAccount/cbc:ID" />
                </td>
              </tr>
            </table>
          </div>

        </div>
        <div class="general-data section">
          <h2>Opći podaci</h2>
          <table>
            <tr>
              <th>Prilagodba (CustomizationID)</th>
              <td>
                <xsl:value-of select="cbc:CustomizationID" />
              </td>
            </tr>
            <tr>
              <th>Profil (ProfileID)</th>
              <td>
                <xsl:value-of select="cbc:ProfileID" />
              </td>
            </tr>
            <xsl:if test="cbc:UUID">
              <tr>
                <th>UUID</th>
                <td>
                  <xsl:value-of select="cbc:UUID" />
                </td>
              </tr>
            </xsl:if>
            <xsl:if test="ext:UBLExtensions">
              <tr>
                <th>Digitalni potpis</th>
                <td>Prisutna UBL ekstenzija potpisa</td>
              </tr>
            </xsl:if>
          </table>
        </div>
      </body>
    </html>
  </xsl:template>

</xsl:stylesheet>