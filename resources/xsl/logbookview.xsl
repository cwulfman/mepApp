<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" exclude-result-prefixes="xs xd" version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Nov 18, 2015</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> cwulfman</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>
    <xsl:template match="/">
        <table class="table">
            <thead>
                <tr>
                    <th>date subscribed</th>
                    <th>name of subscriber</th>
                    <th>length of subscription</th>
                    <th>number of volumes in subscription</th>
                    <th>price of subscription</th>
                    <th>deposit</th>
                </tr>
            </thead>
            <tbody>
                <xsl:apply-templates select=".//tei:event[@type = 'subscription']"/>
            </tbody>
        </table>
    </xsl:template>
    <xsl:template match="tei:event[@type='subscription']">
        <tr>
            <td>
                <xsl:value-of select="ancestor::tei:div[@type='day']/tei:head/tei:date"/>
            </td>
            <td>
                <xsl:apply-templates select="tei:p/tei:persName"/>
            </td>
            <td>
                <xsl:apply-templates select="tei:p/tei:measure[@type='duration']"/>
            </td>
            <td>
                <xsl:apply-templates select="tei:p/tei:measure[@type='frequency']"/>
            </td>
            <td>
                <xsl:apply-templates select="tei:p/tei:measure[@type='price']"/>
            </td>
            <td>
                <xsl:apply-templates select="tei:p/tei:measure[@type='deposit']"/>
            </td>
        </tr>
    </xsl:template>
    <xsl:template match="tei:measure-old[@type='duration']">
        <dl class="dl-horizontal">
            <dt>unit</dt>
            <dd>
                <xsl:value-of select="@unit"/>
            </dd>
            <dt>quantity</dt>
            <dd>
                <xsl:value-of select="@quantity"/>
            </dd>
            <dt>written</dt>
            <dd>
                <xsl:apply-templates/>
            </dd>
        </dl>
    </xsl:template>
    <xsl:template match="tei:measure[@type='duration']">
        <table>
            <tr>
                <td>
                    <xsl:value-of select="@quantity"/>
                </td>
                <td>
                    <xsl:value-of select="@unit"/>
                    <xsl:if test="@quantity &gt; 1">s</xsl:if>
                </td>
            </tr>
        </table>
    </xsl:template>
</xsl:stylesheet>