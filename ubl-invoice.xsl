<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:n0="http://www.sap.com/eDocument/Croatia/FINA/InvoiceCreditNote/v2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:n6="urn:oasis:names:specification:ubl:schema:xsd:Invoice-2"
  xmlns:ubl-cn="urn:oasis:names:specification:ubl:schema:xsd:CreditNote-2"
  xmlns:n2="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2"
  xmlns:n3="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2"
  xmlns:n4="urn:oasis:names:specification:ubl:schema:xsd:CommonnExtensionComponents-2"
  xmlns:n5="urn:oasis:names:specification:ubl:schema:xsd:CommonSignatureComponents-2"
  xmlns:n7="urn:oasis:names:specification:ubl:schema:xsd:SignatureAggregateComponents-2"
  xmlns:n1="urn:hzn.hr:schema:xsd:HRExtensionAggregateComponents-1"
  exclude-result-prefixes="n6 ubl-cn n2 n3 n4 n5 n7 n1">

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
      <xsl:when test="/n6:Invoice">
        <xsl:apply-templates select="/n6:Invoice" />
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
  <xsl:template match="/n6:Invoice">
    <xsl:call-template name="render-document">
      <xsl:with-param name="docType" select="'Račun'" />
      <xsl:with-param name="lineElement" select="'n2:InvoiceLine'" />
      <xsl:with-param name="typeCode" select="'n3:InvoiceTypeCode'" />
      <xsl:with-param name="quantityElement" select="'n3:InvoicedQuantity'" />
      <xsl:with-param name="totalLabel" select="'Ukupan iznos za plaćanje:'" />
    </xsl:call-template>
  </xsl:template>

  <!-- ================= CREDIT NOTE ================= -->
  <xsl:template match="/ubl-cn:CreditNote">
    <xsl:call-template name="render-document">
      <xsl:with-param name="docType" select="'Odobrenje računa'" />
      <xsl:with-param name="lineElement" select="'n2:CreditNoteLine'" />
      <xsl:with-param name="typeCode" select="'n3:CreditNoteTypeCode'" />
      <xsl:with-param name="quantityElement" select="'n3:CreditedQuantity'" />
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
          <xsl:value-of select="n3:ID" />
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
              <xsl:value-of select="n3:ID" />
            </h1>
            <div>
              <strong>Datum izdavanja: </strong><xsl:value-of select="n3:IssueDate" />
              <xsl:if
                test="n3:IssueTime">
                <xsl:text> </xsl:text>
                <xsl:value-of select="n3:IssueTime" />
              </xsl:if> | <strong>Valuta: </strong><xsl:value-of
                select="n3:DocumentCurrencyCode" />
            </div>
            <div>
              <strong>Vrsta dokumenta (kod): </strong>
              <xsl:value-of select="*[name()=$typeCode]" />
            </div>
            <!-- FISKALNI PODACI -->
            <xsl:if test="n3:DueDate">
              <div>
                <strong>Datum dospijeća: </strong>
                <xsl:value-of select="n3:DueDate" />
              </div>
            </xsl:if>
          </div>

          <!-- ========== OPĆI PODACI ========== -->

          <!-- ========== STRANE ========== -->
          <div class="parties">
            <div>
              <h2>Dobavljač</h2>
              <xsl:value-of
                select="n2:AccountingSupplierParty/n2:Party/n2:PartyLegalEntity/n3:RegistrationName" /><br />
              <xsl:value-of
                select="n2:AccountingSupplierParty/n2:Party/n2:PostalAddress/n3:StreetName" /><br />
              <xsl:value-of
                select="n2:AccountingSupplierParty/n2:Party/n2:PostalAddress/n3:CityName" />, <xsl:value-of
                select="n2:AccountingSupplierParty/n2:Party/n2:PostalAddress/n3:PostalZone" /><br />
              OIB: <xsl:value-of
                select="n2:AccountingSupplierParty/n2:Party/n2:PartyTaxScheme/n3:CompanyID" /><br />
              <xsl:if
                test="n2:AccountingSupplierParty/n2:Party/n2:PartyIdentification"> Poslovna
              jedinica: <xsl:value-of
                  select="n2:AccountingSupplierParty/n2:Party/n2:PartyIdentification/n3:ID" />
              </xsl:if>
              <xsl:if
                test="n2:AccountingSupplierParty/n2:Party/n2:PartyLegalEntity/n3:CompanyLegalForm">
                <div class="company-legalform">
                  <em>
                    <xsl:value-of
                      select="n2:AccountingSupplierParty/n2:Party/n2:PartyLegalEntity/n3:CompanyLegalForm" />
                  </em>
                </div>
              </xsl:if>
              <xsl:if
                test="n2:AccountingSupplierParty/n2:SellerContact">
                <div class="seller-contact">
                  <strong>Operater: </strong>
                  <xsl:value-of
                    select="n2:AccountingSupplierParty/n2:SellerContact/n3:Name" /> (<xsl:value-of
                    select="n2:AccountingSupplierParty/n2:SellerContact/n3:ID" />) </div>
              </xsl:if>
            </div>

            <div>
              <h2>Kupac</h2>
              <xsl:value-of
                select="n2:AccountingCustomerParty/n2:Party/n2:PartyLegalEntity/n3:RegistrationName" /><br />
              <xsl:value-of
                select="n2:AccountingCustomerParty/n2:Party/n2:PostalAddress/n3:StreetName" /><br />
              <xsl:value-of
                select="n2:AccountingCustomerParty/n2:Party/n2:PostalAddress/n3:CityName" />, <xsl:value-of
                select="n2:AccountingCustomerParty/n2:Party/n2:PostalAddress/n3:PostalZone" /><br />
              OIB: <xsl:value-of
                select="n2:AccountingCustomerParty/n2:Party/n2:PartyTaxScheme/n3:CompanyID" /><br />
              <xsl:if
                test="n2:AccountingCustomerParty/n2:Party/n2:PartyIdentification"> Poslovna
              jedinica: <xsl:value-of
                  select="n2:AccountingCustomerParty/n2:Party/n2:PartyIdentification/n3:ID" />
              </xsl:if>
            </div>
          </div>

          <!-- ========== DOSTAVA ========== -->
          <xsl:if test="n2:Delivery">
            <div class="delivery section">
              <h2>Podaci o dostavi</h2>
              <xsl:for-each select="n2:Delivery">
                <xsl:if test="n2:DeliveryLocation/n2:Address">
                  <div>
                    <strong>Adresa dostave: </strong>
                    <xsl:value-of
                      select="n2:DeliveryLocation/n2:Address/n3:StreetName" />, <xsl:value-of
                      select="n2:DeliveryLocation/n2:Address/n3:CityName" /> (<xsl:value-of
                      select="n2:DeliveryLocation/n2:Address/n3:PostalZone" />) </div>
                </xsl:if>
                <xsl:if test="n2:ActualDeliveryDate">
                  <div>
                    <strong>Datum dostave: </strong>
                    <xsl:value-of select="n2:ActualDeliveryDate" />
                  </div>
                </xsl:if>
                <xsl:if test="n2:DeliveryParty/n2:PartyName/n3:Name">
                  <div>
                    <strong>Isporučitelj: </strong>
                    <xsl:value-of select="n2:DeliveryParty/n2:PartyName/n3:Name" />
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
                      <xsl:value-of select="n3:ID" />
                    </td>
                    <td>
                      <xsl:value-of select="n2:Item/n3:Name" />
                      <xsl:if test="n2:Item/n2:CommodityClassification/n3:ItemClassificationCode">
                        <br />
                        <span class="small">Šifra: <xsl:value-of
                            select="n2:Item/n2:CommodityClassification/n3:ItemClassificationCode" /></span>
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
                        select="format-number(number(n2:Price/n3:PriceAmount), '#,##0.00')" />
                      <xsl:text> </xsl:text>
                      <xsl:call-template name="currency-symbol">
                        <xsl:with-param name="code" select="n2:Price/n3:PriceAmount/@currencyID" />
                      </xsl:call-template>
                    </td>
                    <td>
                      <xsl:value-of
                        select="format-number(number(n3:Linen4ensionAmount), '#,##0.00')" />
                      <xsl:text> </xsl:text>
                      <xsl:call-template name="currency-symbol">
                        <xsl:with-param name="code" select="n3:Linen4ensionAmount/@currencyID" />
                      </xsl:call-template>
                    </td>
                  </tr>
                </xsl:for-each>
              </tbody>
            </table>
          </div>
          <div class="invoice-reference">
            <xsl:if test="n2:BillingReference">
              <div>
                <h2>Reference na povezane dokumente</h2>
              </div>
              <xsl:for-each select="n2:BillingReference/n2:InvoiceDocumentReference">
                <div class="billing-ref">
                  <div>
                    <strong>Broj dokumenta: </strong>
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="n3:ID" />
                  </div>
                  <xsl:if test="n3:IssueDate">
                    <div>
                      <strong>Datum izdavanja: </strong>
                      <xsl:text> </xsl:text>
                      <xsl:value-of select="n3:IssueDate" />
                    </div>
                  </xsl:if>
                  <xsl:if test="n3:DocumentDescription">
                    <div>
                      <strong>Opis: </strong>
                      <div class="document-description">
                        <xsl:value-of select="n3:DocumentDescription" disable-output-escaping="yes" />
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
                test="n4:UBLn4ensions/n4:UBLn4ension/n4:n4ensionContent/n1:HRFISK20Data/n1:HRTaxTotal">
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
                      select="n4:UBLn4ensions/n4:UBLn4ension/n4:n4ensionContent/n1:HRFISK20Data/n1:HRTaxTotal/n1:HRTaxSubtotal">
                      <xsl:for-each select="n1:HRTaxCategory">
                        <tr>
                          <td>
                            <xsl:value-of select="format-number(../n3:TaxableAmount, '#,##0.00')" />
                          </td>
                          <td>
                            <xsl:value-of select="format-number(../n3:TaxAmount, '#,##0.00')" />
                          </td>
                          <td>
                            <xsl:value-of select="n3:Name" /> (<xsl:value-of select="n3:ID" />) </td>
                          <td>
                            <xsl:value-of select="format-number(n3:Percent, '#,##0.##')" />
                          </td>
                          <td>
                            <xsl:value-of select="../n3:TaxableAmount/@currencyID" />
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
                          select="format-number(n4:UBLn4ensions/n4:UBLn4ension/n4:n4ensionContent/n1:HRFISK20Data/n1:HRTaxTotal/n3:TaxAmount, '#,##0.00')" />
                        <xsl:text> </xsl:text>
                        <xsl:value-of
                          select="n4:UBLn4ensions/n4:UBLn4ension/n4:n4ensionContent/n1:HRFISK20Data/n1:HRTaxTotal/n3:TaxAmount/@currencyID" />
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
                    <xsl:for-each select="n2:TaxTotal/n2:TaxSubtotal">
                      <xsl:for-each select="n2:TaxCategory">
                        <tr>
                          <td>
                            <xsl:value-of select="format-number(../n3:TaxableAmount, '#,##0.00')" />
                          </td>
                          <td>
                            <xsl:value-of select="format-number(../n3:TaxAmount, '#,##0.00')" />
                          </td>
                          <td>
                            <xsl:value-of select="n3:Name" /> (<xsl:value-of select="n3:ID" />) </td>
                          <td>
                            <xsl:value-of select="format-number(n3:Percent, '#,##0.##')" />
                          </td>
                          <td>
                            <xsl:value-of select="../n3:TaxableAmount/@currencyID" />
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
                        <xsl:value-of select="format-number(n2:TaxTotal/n3:TaxAmount, '#,##0.00')" />
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="n2:TaxTotal/n3:TaxAmount/@currencyID" />
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
                test="n4:UBLn4ensions/n4:UBLn4ension/n4:n4ensionContent/n1:HRFISK20Data/n1:HRLegalMonetaryTotal">
                <div>
                  <strong>Bez PDV-a: </strong>
                  <xsl:value-of
                    select="format-number(number(n4:UBLn4ensions/n4:UBLn4ension/n4:n4ensionContent/n1:HRFISK20Data/n1:HRLegalMonetaryTotal/n3:TaxExclusiveAmount), '#,##0.00')" />
                  <xsl:text> </xsl:text>
                  <xsl:call-template name="currency-symbol">
                    <xsl:with-param name="code"
                      select="n4:UBLn4ensions/n4:UBLn4ension/n4:n4ensionContent/n1:HRFISK20Data/n1:HRLegalMonetaryTotal/n3:TaxExclusiveAmount/@currencyID" />
                  </xsl:call-template>
                </div>

                <xsl:if
                  test="n4:UBLn4ensions/n4:UBLn4ension/n4:n4ensionContent/n1:HRFISK20Data/n1:HRLegalMonetaryTotal/n1:OutOfScopeOfVATAmount">
                  <div>
                    <strong>Iznos izvan opsega PDV-a: </strong>
                    <xsl:value-of
                      select="format-number(number(n4:UBLn4ensions/n4:UBLn4ension/n4:n4ensionContent/n1:HRFISK20Data/n1:HRLegalMonetaryTotal/n1:OutOfScopeOfVATAmount), '#,##0.00')" />
                    <xsl:text> </xsl:text>
                    <xsl:call-template name="currency-symbol">
                      <xsl:with-param name="code"
                        select="n4:UBLn4ensions/n4:UBLn4ension/n4:n4ensionContent/n1:HRFISK20Data/n1:HRLegalMonetaryTotal/n1:OutOfScopeOfVATAmount/@currencyID" />
                    </xsl:call-template>
                  </div>
                </xsl:if>

                <div>
                  <strong>
                    <xsl:value-of select="$totalLabel" />
                  </strong>
                  <!-- Sum of TaxExclusiveAmount + OutOfScopeOfVATAmount if both exist -->
                  <xsl:variable name="taxExcl"
                    select="number(n4:UBLn4ensions/n4:UBLn4ension/n4:n4ensionContent/n1:HRFISK20Data/n1:HRLegalMonetaryTotal/n3:TaxExclusiveAmount)" />
                  <xsl:variable name="outOfScope"
                    select="number(n4:UBLn4ensions/n4:UBLn4ension/n4:n4ensionContent/n1:HRFISK20Data/n1:HRLegalMonetaryTotal/n1:OutOfScopeOfVATAmount)" />
                  <xsl:value-of select="format-number($taxExcl + $outOfScope, '#,##0.00')" />
                  <xsl:text> </xsl:text>
                  <xsl:call-template name="currency-symbol">
                    <xsl:with-param name="code"
                      select="n4:UBLn4ensions/n4:UBLn4ension/n4:n4ensionContent/n1:HRFISK20Data/n1:HRLegalMonetaryTotal/n3:TaxExclusiveAmount/@currencyID" />
                  </xsl:call-template>
                </div>

              </xsl:when>

              <xsl:otherwise>
                <!-- Fallback to standard UBL totals -->
                <div>
                  <strong>Bez PDV-a: </strong>
                  <xsl:value-of
                    select="format-number(number(n2:LegalMonetaryTotal/n3:TaxExclusiveAmount), '#,##0.00')" />
                  <xsl:text> </xsl:text>
                  <xsl:call-template name="currency-symbol">
                    <xsl:with-param name="code"
                      select="n2:LegalMonetaryTotal/n3:TaxExclusiveAmount/@currencyID" />
                  </xsl:call-template>
                </div>

                <div>
                  <strong>S PDV-om: </strong>
                  <xsl:value-of
                    select="format-number(number(n2:LegalMonetaryTotal/n3:TaxInclusiveAmount), '#,##0.00')" />
                  <xsl:text> </xsl:text>
                  <xsl:call-template name="currency-symbol">
                    <xsl:with-param name="code"
                      select="n2:LegalMonetaryTotal/n3:TaxInclusiveAmount/@currencyID" />
                  </xsl:call-template>
                </div>

                <xsl:if test="n2:LegalMonetaryTotal/n3:PrepaidAmount">
                  <div>
                    <strong>Unaprijed plaćen iznos: </strong>
                    <xsl:value-of
                      select="format-number(number(n2:LegalMonetaryTotal/n3:PrepaidAmount), '#,##0.00')" />
                    <xsl:text> </xsl:text>
                    <xsl:call-template name="currency-symbol">
                      <xsl:with-param name="code"
                        select="n2:LegalMonetaryTotal/n3:PrepaidAmount/@currencyID" />
                    </xsl:call-template>
                  </div>
                </xsl:if>

                <div>
                  <strong>
                    <xsl:value-of select="$totalLabel" />
                  </strong>
                  <xsl:value-of
                    select="format-number(number(n2:LegalMonetaryTotal/n3:PayableAmount), '#,##0.00')" />
                  <xsl:text> </xsl:text>
                  <xsl:call-template name="currency-symbol">
                    <xsl:with-param name="code"
                      select="n2:LegalMonetaryTotal/n3:PayableAmount/@currencyID" />
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
                  <xsl:value-of select="n2:PaymentMeans/n3:PaymentMeansCode" />
                </td>
              </tr>
              <tr>
                <th>Napomena</th>
                <td>
                  <xsl:value-of select="n2:PaymentMeans/n3:InstructionNote" />
                </td>
              </tr>
              <xsl:for-each select="n4:UBLn4ensions/n4:UBLn4ension">
                <xsl:if
                  test="n4:n4ensionContent/n1:HRFISK20Data/n1:HRObracunPDVPoNaplati">
                  <tr>
                    <th>Obračun PDV-a po naplati:</th>
                    <td>
                      <xsl:value-of
                        select="n4:n4ensionContent/n1:HRFISK20Data/n1:HRObracunPDVPoNaplati" />
                    </td>
                  </tr>
                </xsl:if>
              </xsl:for-each>
              <tr>
                <th>Poziv na broj</th>
                <td>
                  <xsl:value-of select="n2:PaymentMeans/n3:PaymentID" />
                </td>
              </tr>
              <tr>
                <th>IBAN primatelja</th>
                <td>
                  <xsl:value-of select="n2:PaymentMeans/n2:PayeeFinancialAccount/n3:ID" />
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
                <xsl:value-of select="n3:CustomizationID" />
              </td>
            </tr>
            <tr>
              <th>Profil (ProfileID)</th>
              <td>
                <xsl:value-of select="n3:ProfileID" />
              </td>
            </tr>
            <xsl:if test="n3:UUID">
              <tr>
                <th>UUID</th>
                <td>
                  <xsl:value-of select="n3:UUID" />
                </td>
              </tr>
            </xsl:if>
            <xsl:if test="n4:UBLn4ensions">
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