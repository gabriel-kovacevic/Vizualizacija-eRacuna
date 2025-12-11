<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
    xmlns:n0="http://www.sap.com/eDocument/Croatia/FINA/InvoiceCreditNote/v2.0"
    xmlns:prx="urn:sap.com:proxy:QEO:/1SAI/TASA6314546397EAD185D03:758"
    xmlns:n1="urn:mfin.gov.hr:schema:xsd:HRExtensionAggregateComponents-1"
    xmlns:n2="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2"
    xmlns:n3="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2"
    xmlns:n4="urn:oasis:names:specification:ubl:schema:xsd:CommonExtensionComponents-2"
    xmlns:n5="urn:oasis:names:specification:ubl:schema:xsd:CommonSignatureComponents-2"
    xmlns:n6="urn:oasis:names:specification:ubl:schema:xsd:Invoice-2"
    xmlns:n7="urn:oasis:names:specification:ubl:schema:xsd:SignatureAggregateComponents-2"
    exclude-result-prefixes="n0 prx n1 n2 n3 n4 n5 n6 n7">

    <xsl:output method="html" indent="yes" encoding="UTF-8" />

    <!-- Pretvaranje valutnih simbola -->
    <xsl:template name="currency-label">
        <xsl:param name="code" />
        <xsl:choose>
            <xsl:when test="$code='EUR'">€</xsl:when>
            <xsl:when test="$code='USD'">$</xsl:when>
            <xsl:when test="$code='GBP'">£</xsl:when>
            <xsl:when test="$code='JPY'">¥</xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$code" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Pretvaranje jedinica mjere (ISO standard) -->
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

    <!-- Pretvaranje tipa poslovnog procesa (prema specifikaciji) -->
    <xsl:template name="process-type-label">
        <xsl:param name="code" />
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
                <xsl:value-of select="$code" />
            </xsl:otherwise>
        </xsl:choose>


    <!-- Pretvaranje tipa računa (prema specifikaciji) -->
     <xsl:template name="invoice-type-label">
        <xsl:param name="code" />
        <xsl:choose>
            <xsl:when test="$code='82'">Račun za mjerene usluge</xsl:when>
            <xsl:when test="$code='326'">Parcijalni račun</xsl:when>
            <xsl:when test="$code='380'">Komercijalni račun</xsl:when>
            <xsl:when test="$code='383'">Terećenje</xsl:when>
            <xsl:when test="$code='384'">Korektivni račun</xsl:when>
            <xsl:when test="$code='386'">Račun za predujam</xsl:when>
            <xsl:when test="$code='394'">Račun za leasing</xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$code" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Template za račun -->
     <xsl:template name="render-document">
        <html>
            <head>
                <meta charset="UTF-8"/>
                <title>
                    Račun_
                    <xsl:value-of select="n3:ID"/>
                </title>
                <link rel="stylesheet" href="invoice.css"/>
            </head>
            <body>
                <div class="invoice-header">
                    <h1>
                        Račun
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="n3:ID"/>
                    </h1>
                    <p>Identifikator specifikacije: </p><xsl:value-of select="n3:CustomizationID"/>
                    <div>
                        <strong>Datum izdavanja računa: </strong><xsl:value-of select="n3:IssueDate"/>
                        <strong>Vrijeme izdavanja računa: </strong><xsl:value-of select="n3:IssueTime"/>
                        <strong>Datum dospijeća plaćanja: </strong><xsl:value-of select="n3:DueDate"/>
                        <strong>Tip računa: </strong><xsl:call-template name="invoice-type-label"><xsl:with-param name="code" select="n3:InvoiceTypeCode"/></xsl:call-template>
                        <strong>Valuta: </strong><xsl:call-template name="currency-label"><xsl:with-param name="code" select="n3:DocumentCurrencyCode"/></xsl:call-template>
                        <strong>Tip poslovnog procesa: </strong><xsl:call-template name="process-type-label"><xsl:with-param name="code" select="n3:ProfileID"/></xsl:call-template>
                    </div>
                    <div class="OrderReference">
                        <strong>Referenca narudžbenice: </strong><xsl:value-of select="n2:OrderReference/n3:ID"/>
                        <strong>Referenca naloga za isporuku: </strong><xsl:value-of select="n2:OrderReference/n3:SalesOrderID"/>
                    </div>
                </div>

                <div class="parties">
                    <div class="AccountingSupplierParty">
                        <h2>Prodavatelj</h2>
                        <xsl:value-of select="n2:AccountingSupplierParty/n2:Party/n2:PartyName/n3:Name"/><br/>
                        <xsl:value-of select="n2:AccountingSupplierParty/n2:Party/n2:PostalAddress/n3:StreetName"/><br/>
                        <xsl:value-of select="n2:AccountingSupplierParty/n2:Party/n2:PostalAddress/n3:CityName"/><br/>
                        <xsl:value-of select="n2:AccountingSupplierParty/n2:Party/n2:PostalAddress/n3:PostalZone"/><br/>
                    </div>
                </div>
            </body>
        </html>
     </xsl:template>