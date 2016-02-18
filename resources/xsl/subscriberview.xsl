<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
    <xsl:template match="/">
        <table class="table">
            <thead>
                <tr>
                    <th>date</th>
                    <th>type</th>
                    <th>length of subscription</th>
                    <th>number of volumes in subscription</th>
                    <th>price of subscription</th>
                    <th>deposit</th>
                </tr>
            </thead>
            <tbody>
                <xsl:apply-templates/>
            </tbody>
        </table>
    </xsl:template>
    <xsl:template match="eventrec">
        <tr>
            <td>
                <xsl:apply-templates select="tei:date"/>
            </td>
            <td>
                <xsl:value-of select="@type"/>
            </td>
            <td>
                <xsl:apply-templates select="tei:measure[@type='duration']"/>
            </td>
            <td>
                <xsl:apply-templates select="tei:measure[@type='frequency']"/>
            </td>
            <td>
                <xsl:apply-templates select="tei:measure[@type='price']"/>
            </td>
            <td>
                <xsl:apply-templates select="tei:measure[@type='deposit']"/>
            </td>
        </tr>
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