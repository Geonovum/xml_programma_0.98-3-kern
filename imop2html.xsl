<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:eigen="https://www.eigen.nl/" xmlns:vt="http://www.geostandaarden.nl/imow/vrijetekst/v20190901" xmlns:vt-ref="http://www.geostandaarden.nl/imow/vrijetekst-ref/v20190901" xmlns:ga="http://www.geostandaarden.nl/imow/gebiedsaanwijzing/v20190709" xmlns:ga-ref="http://www.geostandaarden.nl/imow/gebiedsaanwijzing-ref/v20190709" xmlns:l="http://www.geostandaarden.nl/imow/locatie/v20190901" xmlns:l-ref="http://www.geostandaarden.nl/imow/locatie-ref/v20190901" xmlns:xlink="http://www.w3.org/1999/xlink" exclude-result-prefixes="#all">
    <xsl:output method="xhtml" encoding="UTF-8" indent="no" omit-xml-declaration="yes" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"/>

    <xsl:param name="title" select="(.//RegelingOpschrift/Al/node(),.//officieleTitel/Al/node(),string('Aan de slag met de omgevingswet'))[1]"/>

    <!-- imow-objecten -->
    <xsl:param name="ow" select="('../imow/owVrijetekst.xml','../imow/owHoofdlijn.xml','../imow/owGebiedsaanwijzing.xml','../imow/owLocatie.xml')"/>
    <xsl:param name="owObject">
        <xsl:sequence select="document($ow,.)//(vt:FormeleDivisie|vt:Tekstdeel|vt:Hoofdlijn|ga:Gebiedsaanwijzing|l:Gebied)"/>
    </xsl:param>

    <!-- Koppenstructuur wordt vastgelegd in TOC -->

    <xsl:variable name="TOC">
        <xsl:for-each select=".//FormeleDivisie/Kop">
            <xsl:element name="heading">
                <xsl:attribute name="id" select="generate-id(.)"/>
                <xsl:attribute name="level" select="count(ancestor::FormeleDivisie)"/>
                <xsl:attribute name="number" select="count(.|../preceding-sibling::FormeleDivisie/Kop)"/>
                <xsl:copy-of select="./node()"/>
            </xsl:element>
        </xsl:for-each>
    </xsl:variable>

    <!-- document -->

    <xsl:template match="/">
        <!-- maak de index -->
        <xsl:call-template name="index"/>
        <!-- maak de pagina's -->
        <xsl:call-template name="pages"/>
    </xsl:template>

    <!-- index -->

    <xsl:template name="index">
        <html>
            <head>
                <meta http-equiv="content-type" content="text/html; charset=UTF-8"/>
                <meta name="viewport" id="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, minimal-ui"/>
                <link rel="stylesheet" type="text/css" href="index.css"/>
                <title>
                    <xsl:apply-templates select="$title"/>
                </title>
            </head>
            <body>
                <div class="page">
                    <div class="sidebar">
                        <div class="logo">
                            <img src="media/logo.svg" alt="logo" height="44"/>
                        </div>
                        <div class="menu">
                            <xsl:for-each-group select="$TOC/*" group-starting-with="heading[number(@level) eq 1]|appendix[1]">
                                <ul class="mainmenu">
                                    <li>
                                        <xsl:choose>
                                            <xsl:when test="self::heading">
                                                <xsl:variable name="filename" select="concat('pages/page_',fn:format-number(./@number,'00'),'.html')"/>
                                                <p><a href="{$filename}" target="content"><xsl:apply-templates select="./Opschrift/node()"/></a></p>
                                                <xsl:if test="current-group()/self::heading[number(@level) eq 2]">
                                                    <ul class="submenu">
                                                        <xsl:for-each select="current-group()/self::heading[number(@level) eq 2]">
                                                            <li><p><a href="{concat($filename,'#',@id)}" target="content"><xsl:apply-templates select="./Opschrift/node()"/></a></p></li>
                                                        </xsl:for-each>
                                                    </ul>
                                                </xsl:if>
                                            </xsl:when>
                                        </xsl:choose>
                                    </li>
                                </ul>
                            </xsl:for-each-group>
                        </div>
                        <div class="metadata">
                            <xsl:apply-templates select="OfficielePublicatie/Metadata/Uitspraak" mode="metadata"/>
                        </div>
                    </div>
                    <div class="content">
                        <div class="title"><p class="title"><xsl:apply-templates select="$title"/></p></div>
                        <div class="target"><iframe name="content" src="pages/page_01.html"/></div>
                    </div>
                </div>
            </body>
        </html>
    </xsl:template>

    <!-- pages -->

    <xsl:template name="pages">
        <!-- maak de hoofdstukken in de omschrijving -->
        <xsl:for-each select=".//Lichaam/FormeleDivisie">
            <xsl:variable name="filename" select="concat('pages/page_',fn:format-number(position(),'00'),'.html')"/>
            <xsl:result-document href="{$filename}" method="xhtml">
                <html>
                    <head>
                        <meta http-equiv="content-type" content="text/html; charset=UTF-8"/>
                        <link rel="stylesheet" type="text/css" href="custom.css"/>
                        <title>
                            <xsl:apply-templates select="./Kop[1]/Opschrift/node()"/>
                        </title>
                    </head>
                    <body>
                        <xsl:apply-templates select="."/>
                    </body>
                </html>
            </xsl:result-document>
        </xsl:for-each>
    </xsl:template>

    <!-- algemeen -->

    <xsl:template match="*">
        <xsl:element name="{name()}">
            <xsl:apply-templates select="./node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="Al">
        <p><xsl:if test="@eigen:class"><xsl:attribute name="class" select="fn:lower-case(@eigen:class)"/></xsl:if><xsl:apply-templates select="./node()"/></p>
    </xsl:template>

    <xsl:template match="Tussenkop">
        <p class="tussenkop"><xsl:apply-templates select="./node()"/></p>
    </xsl:template>

    <xsl:template match="FormeleInhoud">
        <xsl:apply-templates select="*"/>
    </xsl:template>

    <!-- formeleDivisie -->

    <xsl:template match="FormeleDivisie">
        <xsl:variable name="class">
            <xsl:choose>
                <xsl:when test="@eigen:class">
                    <xsl:value-of select="fn:lower-case(@eigen:class)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="string('geen')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <section class="{$class}">
            <xsl:apply-templates select="*"/>
        </section>
    </xsl:template>

    <xsl:template match="FormeleDivisie/Kop">
        <!-- TOC bevat de koppenstructuur -->
        <xsl:variable name="id" select="generate-id(.)"/>
        <p class="{concat('heading_',$TOC/heading[@id=$id]/@level)}" id="{$id}"><xsl:if test="./Label|./Nummer"><span class="nummer"><xsl:value-of select="fn:string-join((./Label,./Nummer),' ')"/></span></xsl:if><xsl:apply-templates select="./Opschrift/node()"/></p>
        <!-- plaats de metadata -->
        <xsl:variable name="wId" select="parent::FormeleDivisie/@wId"/>
        <xsl:apply-templates select="$owObject/vt:FormeleDivisie[@wId=$wId]"/>
    </xsl:template>

    <!-- groep -->

    <xsl:template match="Groep">
        <xsl:variable name="class">
            <xsl:choose>
                <xsl:when test="@eigen:class">
                    <xsl:value-of select="fn:lower-case(@eigen:class)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="string('geen')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <div class="{$class}">
            <xsl:apply-templates select="*">
                <xsl:with-param name="class" select="$class"/>
            </xsl:apply-templates>
        </div>
    </xsl:template>

    <xsl:template match="Groep/Tussenkop" priority="1">
        <xsl:param name="class"/>
        <p class="{fn:string-join(($class,'kop'),'_')}">
            <xsl:apply-templates select="./node()"/></p>
    </xsl:template>

    <xsl:template match="Groep/al" priority="1">
        <xsl:param name="class"/>
        <p class="{$class}">
            <xsl:apply-templates select="./node()"/></p>
    </xsl:template>

    <!-- opsomming -->

    <xsl:template match="Lijst">
        <xsl:variable name="class" select="concat('nummering_',count(.|ancestor::Lijst))"/>
        <xsl:choose>
            <xsl:when test="@type='expliciet'">
                <div class="{$class}">
                    <xsl:apply-templates/>
                </div>
            </xsl:when>
            <xsl:when test="@eigen:class='Nummers'">
                <xsl:apply-templates select="Lijstaanhef"/>
                <ol class="{$class}">
                    <xsl:apply-templates select="Li"/>
                </ol>
            </xsl:when>
            <xsl:when test="@eigen:class='Tekens'">
                <xsl:apply-templates select="Lijstaanhef"/>
                <ul class="{$class}">
                    <xsl:apply-templates select="Li"/>
                </ul>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="Lijstaanhef">
        <p><xsl:if test="@eigen:class"><xsl:attribute name="class" select="fn:lower-case(@eigen:class)"/></xsl:if><xsl:apply-templates/></p>
    </xsl:template>
    
    <xsl:template match="Li">
        <xsl:variable name="id" select="@id"/>
        <xsl:choose>
            <xsl:when test="parent::Lijst/@type='expliciet'">
                <div class="item">
                    <div class="nummer">
                        <xsl:apply-templates select="LiNummer"/>
                    </div>
                    <div class="inhoud">
                        <xsl:apply-templates select="* except LiNummer"/>
                    </div>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <li>
                    <xsl:apply-templates select="*"/>
                </li>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="LiNummer">
        <p><xsl:if test="@eigen:class"><xsl:attribute name="class" select="fn:lower-case(@eigen:class)"/></xsl:if><xsl:apply-templates/></p>
    </xsl:template>
    
    <!-- inline -->

    <xsl:template match="b">
        <span class="vet"><xsl:apply-templates select="./node()"/></span>
    </xsl:template>

    <xsl:template match="i">
        <span class="cursief"><xsl:apply-templates select="./node()"/></span>
    </xsl:template>

    <xsl:template match="u">
        <span class="onderstreept"><xsl:apply-templates select="./node()"/></span>
    </xsl:template>

    <xsl:template match="sup">
        <span class="superscript"><xsl:apply-templates select="./node()"/></span>
    </xsl:template>

    <xsl:template match="sub">
        <span class="subscript"><xsl:apply-templates select="./node()"/></span>
    </xsl:template>

    <xsl:template match="ExtRef">
        <a href="{@doc}" target="_blank">
            <xsl:apply-templates/>
        </a>
    </xsl:template>

    <!-- tabel -->

    <xsl:template match="table">
        <table class="{./@type}">
            <xsl:apply-templates select="*"/>
        </table>
    </xsl:template>

    <xsl:template match="table/title">
        <caption class="{ancestor::table[1]/@type}">
            <xsl:apply-templates select="./node()"/>
        </caption>
    </xsl:template>

    <xsl:template match="tgroup">
        <xsl:variable name="tablewidth" select="sum(./colspec/@colwidth)"/>
        <colgroup>
            <xsl:for-each select="./colspec">
                <col id="{./@colname}" style="{concat('width: ',./@colwidth div $tablewidth * 100,'%')}"/>
            </xsl:for-each>
        </colgroup>
        <xsl:apply-templates select="./thead"/>
        <xsl:apply-templates select="./tbody"/>
    </xsl:template>

    <xsl:template match="thead">
        <thead class="{ancestor::table[1]/@type}">
            <xsl:apply-templates select="*"/>
        </thead>
    </xsl:template>
    
    <xsl:template match="tbody">
        <tbody class="{ancestor::table[1]/@type}">
            <xsl:apply-templates select="*"/>
        </tbody>
    </xsl:template>
    
    <xsl:template match="row">
        <tr class="{ancestor::table[1]/@type}">
            <xsl:apply-templates select="*"/>
        </tr>
    </xsl:template>
    
    <xsl:template match="entry">
        <xsl:variable name="colspan" select="number(substring(./@nameend,4))-number(substring(./@namest,4))+1"/>
        <xsl:variable name="rowspan" select="number(./@morerows)+1"/>
        <xsl:choose>
            <xsl:when test="ancestor::thead">
                <th class="{ancestor::table[1]/@type}" colspan="{$colspan}" rowspan="{$rowspan}" style="{concat('text-align:',./@align)}">
                    <xsl:apply-templates select="*"/>
                </th>
            </xsl:when>
            <xsl:when test="ancestor::tbody">
                <td class="{ancestor::table[1]/@type}" colspan="{$colspan}" rowspan="{$rowspan}" style="{concat('text-align:',./@align)}">
                    <xsl:apply-templates select="*"/>
                </td>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <!-- figuur -->

    <xsl:template match="Figuur">
        <xsl:variable name="width">
            <!-- voor het geval er meer illustraties in een kader mogen, wordt de breedte berekend met sum -->
            <xsl:variable name="sum" select="fn:sum(Illustratie/number(@breedte))"/>
            <xsl:choose>
                <xsl:when test="$sum lt 75">
                    <xsl:value-of select="$sum"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="100"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="float">
            <xsl:choose>
                <xsl:when test="(./@tekstomloop='ja')">
                    <xsl:choose>
                        <xsl:when test="./@uitlijning=('links','rechts')">
                            <xsl:value-of select="string(./@uitlijning)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="string('geen')"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="string('geen')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <div class="{fn:string-join(('figuur',$float),' ')}" style="{concat('width: ',$width,'%')}">
            <xsl:apply-templates select="*"/>
        </div>
    </xsl:template>

    <xsl:template match="Figuur/Illustratie">
        <img class="figuur" src="{concat('../media/',./@naam)}" width="{(./@schaal,'100%')[1]}" alt="{./@alt}"/>
    </xsl:template>

    <xsl:template match="Figuur/Bijschrift">
        <p class="bijschrift"><xsl:apply-templates select="./node()"/></p>
    </xsl:template>

    <!-- voetnoot -->

    <xsl:template match="Noot">
        <!-- doe niets -->
    </xsl:template>

    <!-- metadata -->

    <xsl:template match="vt:FormeleDivisie">
        <xsl:variable name="id" select="vt:identificatie"/>
        <xsl:apply-templates select="$owObject/vt:Tekstdeel[./vt:formeleDivisie/vt-ref:FormeleDivisieRef/@xlink:href=$id]"/>
    </xsl:template>

    <xsl:template match="vt:Tekstdeel">
        <xsl:if test="./vt:thema">
            <div class="imow_object"><p class="imow_object"><xsl:value-of select="string('Thema')"/></p><xsl:apply-templates select="./vt:thema"/></div>
        </xsl:if>
        <xsl:if test="./vt:hoofdlijnaanduiding">
            <xsl:variable name="id" select="./vt:hoofdlijnaanduiding/vt-ref:HoofdlijnRef/@xlink:href"/>
            <div class="imow_object"><p class="imow_object"><xsl:value-of select="string('Hoofdlijn')"/></p><xsl:apply-templates select="$owObject/vt:Hoofdlijn[./vt:identificatie=$id]"/></div>
        </xsl:if>
        <xsl:if test="./vt:gebiedsaanwijzing">
            <xsl:variable name="id" select="./vt:gebiedsaanwijzing/ga-ref:GebiedsaanwijzingRef/@xlink:href"/>
            <div class="imow_object"><p class="imow_object"><xsl:value-of select="string('Gebiedsaanwijzing')"/></p><xsl:apply-templates select="$owObject/ga:Gebiedsaanwijzing[./ga:identificatie=$id]"/></div>
        </xsl:if>
    </xsl:template>

    <xsl:template match="vt:thema">
        <p class="imow_waarde"><xsl:apply-templates/></p>
    </xsl:template>

    <xsl:template match="vt:Hoofdlijn">
        <p class="imow_naam"><xsl:apply-templates select="./vt:naam"/></p><p class="imow_waarde"><xsl:apply-templates select="./vt:soort"/></p>
    </xsl:template>

    <xsl:template match="ga:Gebiedsaanwijzing">
        <xsl:variable name="id" select="./ga:locatieaanduiding/l-ref:LocatieRef/@xlink:href"/>
        <p class="imow_naam"><xsl:apply-templates select="./ga:naam"/></p><p class="imow_waarde"><span class="imow_waarde"><xsl:value-of select="string('Type:')"/></span><xsl:apply-templates select="./ga:type"/></p><p class="imow_waarde"><span class="imow_waarde"><xsl:value-of select="string('Groep:')"/></span><xsl:apply-templates select="./ga:groep"/></p><p class="imow_waarde"><span class="imow_waarde"><xsl:value-of select="string('Noemer:')"/></span><xsl:value-of select="$owObject/l:Gebied[./l:identificatie=$id]/l:noemer/text()"/></p><div class="locatie"><p class="locatie"><a class="locatie" href="url" target="_blank"><img src="../media/icon.svg" alt="" width="40" height="40"/></a></p></div>
    </xsl:template>

</xsl:stylesheet>