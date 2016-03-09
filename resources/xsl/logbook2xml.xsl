<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" exclude-result-prefixes="xs xd tei" version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Mar 8, 2016</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> cwulfman</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>
    <xsl:output encoding="UTF-8" indent="no" method="xml"/>
    <xsl:template match="/">
        <events>
            <xsl:apply-templates select="//tei:event"/>
        </events>
    </xsl:template>
    <xsl:template match="tei:event">
        <event>
            <date>
                <xsl:apply-templates select="./ancestor::tei:div[@type = 'day']/tei:head/tei:date"/>
            </date>
            <type>
                <xsl:value-of select="@type"/>
            </type>
            <persid>
                <xsl:value-of select="tei:p/tei:persName/@ref"/>
            </persid>
            <persName>
                <xsl:apply-templates select="tei:p/tei:persName"/>
            </persName>
            <duration>
                <xsl:value-of select="tei:p/tei:measure[@type = 'duration']/@quantity"/>
            </duration>
            <frequency>
                <xsl:value-of select="tei:p/tei:measure[@type = 'frequency']/@quantity"/>
            </frequency>
            <price>
                <xsl:value-of select="tei:p/tei:measure[@type = 'price']/@quantity"/>
            </price>
            <deposit>
                <xsl:value-of select="tei:p/tei:measure[@type = 'deposit']/@quantity"/>
            </deposit>
        </event>
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
        <xsl:value-of select="normalize-space(current())"/>
    </xsl:template>
</xsl:stylesheet>