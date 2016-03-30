<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" exclude-result-prefixes="xs xd" version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Mar 8, 2016</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> cwulfman</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>
    <xsl:output encoding="UTF-8" indent="yes" method="text" media-type="text/csv"/>
    <xsl:variable name="sep">,</xsl:variable>
    <xsl:variable name="cr">
        <xsl:value-of select="codepoints-to-string(10)"/>
    </xsl:variable>
    <xsl:variable name="headers">date,type,persid,persName,duration,frequency,price,deposit</xsl:variable>
    <xsl:template match="/">
        <xsl:value-of select="$headers"/>
        <xsl:value-of select="$cr"/>
        <xsl:apply-templates select="//tei:event"/>
    </xsl:template>
    <xsl:template match="tei:event">
        <xsl:variable name="date">
            <xsl:apply-templates select="./ancestor::tei:div[@type='day']/tei:head/tei:date"/>
        </xsl:variable>
        <xsl:variable name="persName">
            <xsl:choose>
                <xsl:when test="tei:p/tei:persName">
                    <xsl:apply-templates select="tei:p/tei:persName"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>unknown</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="persid">
            <xsl:choose>
                <xsl:when test="tei:p/tei:persName/@ref">
                    <xsl:apply-templates select="tei:p/tei:persName/@ref"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>unknown</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="duration">
            <xsl:choose>
                <xsl:when test="tei:p/tei:measure[@type='duration']/@quantity">
                    <xsl:apply-templates select="tei:p/tei:measure[@type='duration']/@quantity"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>0</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="frequency">
            <xsl:choose>
                <xsl:when test="tei:p/tei:measure[@type='frequency']/@quantity">
                    <xsl:apply-templates select="tei:p/tei:measure[@type='frequency']/@quantity"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>0</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="price">
            <xsl:choose>
                <xsl:when test="tei:p/tei:measure[@type='price']/@quantity">
                    <xsl:apply-templates select="tei:p/tei:measure[@type='price']/@quantity"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>0</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="deposit">
            <xsl:choose>
                <xsl:when test="tei:p/tei:measure[@type='deposit']/@quantity">
                    <xsl:apply-templates select="tei:p/tei:measure[@type='deposit']/@quantity"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>0</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="string-join(($date,             @type,                          $persid,                          $persName,                          $duration,                          $frequency,             $price,                         $deposit), ',')"/>
        <xsl:value-of select="$cr"/>
    </xsl:template>
    <xsl:template match="tei:measure">
        <xsl:choose>
            <xsl:when test="@quantity">
                <xsl:value-of select="@quantity"/>
            </xsl:when>
            <xsl:otherwise>0</xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:date">
        <xsl:choose>
            <xsl:when test="@when-iso">
                <xsl:value-of select="@when-iso"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="normalize-space(current())"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:persName">
        <xsl:choose>
            <xsl:when test="current()/text()">
                <xsl:value-of select="normalize-space(current())"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>unknown</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>