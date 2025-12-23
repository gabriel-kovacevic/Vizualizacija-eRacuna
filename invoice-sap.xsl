<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
    xmlns:n0="http://www.sap.com/eDocument/Croatia/FINA/InvoiceCreditNote/v2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:prx="urn:sap.com:proxy:QEO:/1SAI/TASA6314546397EAD185D03:758"
    xmlns:hrextac="urn:mfin.gov.hr:schema:xsd:HRExtensionAggregateComponents-1"
    xmlns:cac="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2"
    xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2"
    xmlns:ext="urn:oasis:names:specification:ubl:schema:xsd:CommonExtensionComponents-2"
    xmlns:sig="urn:oasis:names:specification:ubl:schema:xsd:CommonSignatureComponents-2"
    xmlns:ubl-inv="urn:oasis:names:specification:ubl:schema:xsd:Invoice-2"
    xmlns:sac="urn:oasis:names:specification:ubl:schema:xsd:SignatureAggregateComponents-2"
    exclude-result-prefixes="n0 xsl prx hrextac cac cbc ext sig ubl-inv sac">

    <xsl:output method="html" indent="yes" encoding="UTF-8"/>

    <!-- =========================
         Templates for labels
    ========================= -->

    <xsl:template name="currency-label">
        <xsl:param name="code"/>
        <xsl:choose>
            <xsl:when test="$code='EUR'">€</xsl:when>
            <xsl:when test="$code='USD'">$</xsl:when>
            <xsl:when test="$code='GBP'">£</xsl:when>
            <xsl:when test="$code='JPY'">¥</xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$code"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="unit-label">
        <xsl:param name="code"/>
        <xsl:choose>
            <xsl:when test="$code='H87'">kom</xsl:when>
            <xsl:when test="$code='KGM'">kg</xsl:when>
            <xsl:when test="$code='LTR'">L</xsl:when>
            <xsl:when test="$code='MTR'">m</xsl:when>
            <xsl:when test="$code='NAR'">stavka</xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$code"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="process-type-label">
        <xsl:param name="code"/>
        <xsl:choose>
            <xsl:when test="$code='P1'">Izdavanje računa za isporuke robe i usluga prema narudžbenicama, na temelju ugovora</xsl:when>
            <xsl:when test="$code='P2'">Periodično izdavanje računa za isporuke robe i usluga na temelju ugovora</xsl:when>
            <xsl:when test="$code='P3'">Izdavanje računa za isporuku prema samostalnoj narudžbenici</xsl:when>
            <xsl:when test="$code='P4'">Plaćanje unaprijed (avansno plaćanje)</xsl:when>
            <xsl:when test="$code='P5'">Plaćanje na licu mjesta (engl. Sport payment)</xsl:when>
            <xsl:when test="$code='P6'">Plaćanje prije isporuke, na temelju narudžbenice</xsl:when>
            <xsl:when test="$code='P7'">Izdavanje računa s referencama na otpremnicu</xsl:when>
            <xsl:when test="$code='P8'">Izdavanje računa s referencama na otpremnicu i primku</xsl:when>
            <xsl:when test="$code='P9'">Odobrenja ili računi s negativnim iznosima, izdani zbog raznih razloga, uključujući i povrat prazne ambalaže</xsl:when>
            <xsl:when test="$code='P10'">Izdavanje korektivnog računa (storniranje/ispravak računa)</xsl:when>
            <xsl:when test="$code='P11'">Izdavanje djelomičnoga i konačnog računa</xsl:when>
            <xsl:when test="$code='P12'">Samoizdavanje računa</xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$code"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="invoice-type-label">
        <xsl:param name="code"/>
        <xsl:choose>
            <xsl:when test="$code='82'">Račun za mjerene usluge</xsl:when>
            <xsl:when test="$code='326'">Parcijalni račun</xsl:when>
            <xsl:when test="$code='380'">Komercijalni račun</xsl:when>
            <xsl:when test="$code='383'">Terećenje</xsl:when>
            <xsl:when test="$code='384'">Korektivni račun</xsl:when>
            <xsl:when test="$code='386'">Račun za predujam</xsl:when>
            <xsl:when test="$code='394'">Račun za leasing</xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$code"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="country-label">
        <xsl:param name="code"/>
        <xsl:choose>
            <xsl:when test="$code='HR'">Hrvatska</xsl:when>
            <xsl:when test="$code='SI'">Slovenija</xsl:when>
            <xsl:when test="$code='DE'">Njemačka</xsl:when>
            <xsl:when test="$code='AT'">Austrija</xsl:when>
            <xsl:when test="$code='HU'">Mađarska</xsl:when>
            <xsl:when test="$code='RO'">Rumunjska</xsl:when>
            <xsl:when test="$code='BG'">Bugarska</xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$code"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="strip-oib-letters">
        <xsl:param name="oib"/>
        <xsl:value-of select="substring($oib, 3)"/>
    </xsl:template>

    <xsl:template name="format-date">
        <xsl:param name="date"/>
        <xsl:value-of select="concat(substring($date,9,2), '.', substring($date,6,2), '.', substring($date,1,4))"/>
    </xsl:template>

    <xsl:template name="format-number-2dec">
        <xsl:param name="number"/>
        <xsl:value-of select="format-number($number,'0.00')"/>
    </xsl:template>

    <!-- =========================
         Main Template
    ========================= -->

    <xsl:template match="/ubl-inv:Invoice">
        <html>
            <head>
                <meta charset="UTF-8"/>
                <title>Račun_<xsl:value-of select="cbc:ID"/></title>
                <link rel="stylesheet" href="invoice.css"/>
            </head>
            <body>
                <div class="invoice-header">
                    <h1>Račun <xsl:value-of select="cbc:ID"/></h1>
                    <strong>Identifikator specifikacije: </strong><xsl:value-of select="cbc:CustomizationID"/><br/>
                    <strong>Datum izdavanja računa: </strong>
                    <xsl:call-template name="format-date"><xsl:with-param name="date" select="cbc:IssueDate"/></xsl:call-template><br/>
                    <strong>Tip računa: </strong>
                    <xsl:call-template name="invoice-type-label"><xsl:with-param name="code" select="cbc:InvoiceTypeCode"/></xsl:call-template><br/>
                </div>

                <!-- =========================
                     Parties
                ========================= -->
                <div class="parties">
                    <div class="AccountingSupplierParty">
                        <h2>Prodavatelj</h2>
                        <xsl:value-of select="cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cbc:RegistrationName"/><br/>
                        <strong>OIB: </strong>
                        <xsl:call-template name="strip-oib-letters">
                            <xsl:with-param name="oib" select="cac:AccountingSupplierParty/cac:Party/cac:PartyTaxScheme/cbc:CompanyID"/>
                        </xsl:call-template>
                    </div>
                    <div class="AccountingCustomerParty">
                        <h2>Kupac</h2>
                        <xsl:value-of select="cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity/cbc:RegistrationName"/><br/>
                        <strong>OIB: </strong>
                        <xsl:call-template name="strip-oib-letters">
                            <xsl:with-param name="oib" select="cac:AccountingCustomerParty/cac:Party/cac:PartyTaxScheme/cbc:CompanyID"/>
                        </xsl:call-template>
                    </div>
                </div>

                <!-- =========================
                     Invoice Lines
                ========================= -->
                <div class="InvoiceLine">
                    <h2>Stavke računa</h2>
                    <table class="InvoiceLines">
                        <thead>
                            <tr>
                                <th>ID stavke</th>
                                <th>Šifra</th>
                                <th>Naziv stavke</th>
                                <th>Količina</th>
                                <th>Cijena/j.m.</th>
                                <th>Iznos bez PDV</th>
                                <th>% PDV</th>
                                <th>Kod kategorije PDV</th>
                            </tr>
                        </thead>
                        <tbody>
                            <xsl:for-each select="cac:InvoiceLine">
                                <tr>
                                    <td><xsl:value-of select="cbc:ID"/></td>
                                    <td><xsl:value-of select="cac:Item/cac:SellersItemIdentification/cbc:ID"/></td>
                                    <td><xsl:value-of select="cac:Item/cbc:Name"/></td>
                                    <td>
                                        <xsl:call-template name="format-number-2dec">
                                            <xsl:with-param name="number" select="cbc:InvoicedQuantity"/>
                                        </xsl:call-template>
                                        <xsl:text> </xsl:text>
                                        <xsl:call-template name="unit-label">
                                            <xsl:with-param name="code" select="cbc:InvoicedQuantity/@unitCode"/>
                                        </xsl:call-template>
                                    </td>
                                    <td>
                                        <xsl:call-template name="format-number-2dec">
                                            <xsl:with-param name="number" select="cac:Price/cbc:PriceAmount"/>
                                        </xsl:call-template>
                                        <xsl:text> </xsl:text>
                                        <xsl:call-template name="currency-label">
                                            <xsl:with-param name="code" select="../cbc:DocumentCurrencyCode"/>
                                        </xsl:call-template>
                                    </td>
                                    <td>
                                        <xsl:call-template name="format-number-2dec">
                                            <xsl:with-param name="number" select="cbc:LineExtensionAmount"/>
                                        </xsl:call-template>
                                        <xsl:text> </xsl:text>
                                        <xsl:call-template name="currency-label">
                                            <xsl:with-param name="code" select="../cbc:DocumentCurrencyCode"/>
                                        </xsl:call-template>
                                    </td>
                                    <td><xsl:value-of select="cac:Item/cac:ClassifiedTaxCategory/cbc:Percent"/><xsl:text>%</xsl:text></td>
                                    <td><xsl:value-of select="cac:Item/cac:ClassifiedTaxCategory/cbc:ID"/></td>
                                </tr>
                            </xsl:for-each>
                        </tbody>
                    </table>
                </div>

                <!-- =========================
                     Payment Terms
                ========================= -->
                <xsl:if test="cac:PaymentTerms">
                    <div class="PaymentTerms">
                        <h2>Uvjeti plaćanja</h2>
                        <xsl:for-each select="cac:PaymentTerms">
                            <strong>Opis: </strong><xsl:value-of select="cbc:Note"/><br/>
                        </xsl:for-each>
                    </div>
                </xsl:if>

                <!-- =========================
                     Tax / PDV Section
                ========================= -->
                <div class="TaxTotal">
                    <h2>PDV</h2>
                    <strong>Ukupno neto stavke računa: </strong>
                    <xsl:call-template name="format-number-2dec">
                        <xsl:with-param name="number" select="cac:LegalMonetaryTotal/cbc:LineExtensionAmount"/>
                    </xsl:call-template>
                    <xsl:call-template name="currency-label"><xsl:with-param name="code" select="cbc:DocumentCurrencyCode"/></xsl:call-template><br/>

                    <strong>Ukupno bez PDV: </strong>
                    <xsl:call-template name="format-number-2dec">
                        <xsl:with-param name="number" select="cac:LegalMonetaryTotal/cbc:TaxExclusiveAmount"/>
                    </xsl:call-template>
                    <xsl:call-template name="currency-label"><xsl:with-param name="code" select="cbc:DocumentCurrencyCode"/></xsl:call-template><br/>

                    <strong>Ukupno PDV: </strong>
                    <xsl:call-template name="format-number-2dec">
                        <xsl:with-param name="number" select="cac:TaxTotal/cbc:TaxAmount"/>
                    </xsl:call-template>
                    <xsl:call-template name="currency-label"><xsl:with-param name="code" select="cbc:DocumentCurrencyCode"/></xsl:call-template><br/>

                    <strong>Ukupno s PDV: </strong>
                    <xsl:call-template name="format-number-2dec">
                        <xsl:with-param name="number" select="cac:LegalMonetaryTotal/cbc:PayableAmount"/>
                    </xsl:call-template>
                    <xsl:call-template name="currency-label"><xsl:with-param name="code" select="cbc:DocumentCurrencyCode"/></xsl:call-template><br/>

                    <xsl:if test="cac:InvoiceLine/cac:Item/cac:ClassifiedTaxCategory/cbc:TaxExemptionReason">
                        <strong>Razlog prijenosa porezne obveze: </strong>
                        <xsl:value-of select="cac:InvoiceLine/cac:Item/cac:ClassifiedTaxCategory/cbc:TaxExemptionReason"/>
                    </xsl:if>
                </div>

                <!-- =========================
                     Additional Documents
                ========================= -->
                <xsl:if test="cac:AdditionalDocumentReference">
                    <div class="AdditionalDocumentReference">
                        <h2>Dodatni dokumenti</h2>
                        <xsl:for-each select="cac:AdditionalDocumentReference">
                            <xsl:variable name="base64" select="cbc:EmbeddedDocumentBinaryObject"/>
                            <xsl:variable name="mime" select="cbc:EmbeddedDocumentBinaryObject/@mimeCode"/>
                            <xsl:variable name="name" select="cbc:ID"/>   
                            <button>
                              <xsl:attribute name="onclick">
                                <xsl:text>parent.postMessage({type: "ATTACHMENT", base64: "</xsl:text>
                                <xsl:value-of select="normalize-space(cbc:EmbeddedDocumentBinaryObject)"/>
                                <xsl:text>", mime: "</xsl:text>
                                <xsl:value-of select="cbc:EmbeddedDocumentBinaryObject/@mimeCode"/>
                                <xsl:text>", name: "</xsl:text>
                                <xsl:value-of select="cbc:ID"/>
                                <xsl:text>"}, "*");</xsl:text>
                              </xsl:attribute>
                              Preuzmi privitak
                            </button>
                        </xsl:for-each>
                    </div>
                </xsl:if>

            </body>
        </html>
    </xsl:template>

</xsl:stylesheet>
