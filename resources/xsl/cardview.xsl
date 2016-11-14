<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:local="http://mep.princeton.edu" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="2.0" exclude-result-prefixes="xs xd">
    <xsl:output method="html" doctype-system="about:legacy-compat"/>
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> November 9, 2015</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> cwulfman</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="scheme">http://</xsl:variable>
    <xsl:variable name="server" as="xs:string">libimages.princeton.edu</xsl:variable>
    <xsl:variable name="prefix">loris2</xsl:variable>
    <xsl:variable name="region">full</xsl:variable>
    <xsl:variable name="size">360,</xsl:variable>
    <xsl:variable name="rotation">0</xsl:variable>
    <xsl:variable name="quality">default</xsl:variable>
    <xsl:variable name="format">png</xsl:variable>
    <xsl:key name="surfaces" match="//tei:TEI/tei:facsimile/tei:surface" use="@xml:id"/>
    <xsl:variable name="base" select="replace(//tei:TEI/tei:facsimile/@xml:base, '/', '%2F')"/>
    <xsl:template match="/">
        <xsl:apply-templates select="tei:TEI/tei:text/tei:body/tei:div[@type = 'card']"/>
    </xsl:template>
    <xsl:template match="tei:div[@type = 'card']">
        <hr/>
        <div class="section">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="tei:div[@type = 'recto'] | tei:div[@type = 'verso']">
        <hr/>
        <div class="row">
            <div class="col-sm-6">
                <xsl:apply-templates select="tei:pb"/>
            </div>
            <div class="col-sm-6">
                <xsl:apply-templates select="tei:pb/following-sibling::*"/>
            </div>
        </div>
    </xsl:template>
    <xsl:template match="tei:pb">
        <xsl:apply-templates select="key('surfaces', substring-after(@facs, '#'))"/>
    </xsl:template>
    <xsl:template match="tei:lb">
        <br/>
    </xsl:template>
    <xsl:template match="tei:surface">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:graphic">
        <img>
            <xsl:attribute name="src">
                <xsl:value-of select="string-join((string-join(($scheme, $server, $prefix, $base, ./@url, $region, $size, $rotation, $quality), '/'), $format), '.')"/>
            </xsl:attribute>
        </img>
    </xsl:template>
    <xsl:template match="tei:div">
        <div>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="tei:table/tei:head">
        <caption>
            <xsl:apply-templates/>
        </caption>
    </xsl:template>
    <xsl:template match="tei:head">
        <header>
            <xsl:apply-templates/>
        </header>
    </xsl:template>
    <xsl:template match="tei:table">
        <table>
            <xsl:apply-templates/>
        </table>
    </xsl:template>
    <xsl:template match="tei:row">
        <tr>
            <xsl:apply-templates/>
        </tr>
    </xsl:template>
    <xsl:template match="tei:cell">
        <td>
            <xsl:apply-templates/>
        </td>
    </xsl:template>
    <xsl:template match="tei:p|tei:ab">
        <p>
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    <xsl:template match="tei:address">
        <address>
            <xsl:apply-templates/>
        </address>
    </xsl:template>
    <xsl:template match="tei:addrLine">
        <span class="addrLine">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="tei:note">
        <span class="note">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="tei:bibl">
        <td>
            <span class="bibl">
                <xsl:apply-templates/>
            </span>
        </td>
    </xsl:template>
    <xsl:template match="tei:title">
        <a href="book.html?id={ancestor::tei:bibl/@corresp}">
            <span class="title">
                <xsl:apply-templates/>
            </span>
        </a>
    </xsl:template>
    <xsl:template match="tei:date">
        <span class="date">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="tei:del">
        <del>
            <xsl:apply-templates/>
        </del>
    </xsl:template>
    <xsl:template match="tei:persName">
        <span class="persName">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="tei:ab[@ana='#borrowingEvent']">
        <table class="table">
            <tr>
                <xsl:apply-templates/>
            </tr>
        </table>
    </xsl:template>
    <xsl:template match="tei:date[@ana='#checkedOut']">
        <td>
            <xsl:apply-templates/>
        </td>
    </xsl:template>
    <xsl:template match="tei:date[@ana='#returned']">
        <td>
            <xsl:apply-templates/>
        </td>
    </xsl:template>
</xsl:stylesheet>