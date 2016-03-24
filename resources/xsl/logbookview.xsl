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
        <div>
            <ul class="nav nav-tabs">
                <xsl:for-each select=".//tei:div[@type = 'year']">
                    <xsl:sort select="tei:head/tei:date"/>
                    <xsl:variable name="tag">
                        <xsl:value-of select="current()/tei:head/tei:date"/>
                    </xsl:variable>
                    <li>
                        <a data-toggle="tab" href="#tab{$tag}">
                            <xsl:value-of select="$tag"/>
                        </a>
                    </li>
                </xsl:for-each>
            </ul>
            <div class="tab-content">
                <xsl:apply-templates/>
            </div>
        </div>
    </xsl:template>
    <xsl:template match="tei:div[@type = 'year']">
        <xsl:variable name="datestring" as="xs:string" select="tei:head/tei:date"/>
        <xsl:variable name="tabid">
            <xsl:value-of select="concat('tab', $datestring)"/>
        </xsl:variable>
        <div id="{$tabid}" class="tab-pane fade">
            <header>
                <h3>
                    <xsl:value-of select="tei:head/tei:date"/>
                </h3>
                <p>
                    <xsl:value-of select="count(.//tei:event)"/> entries </p>
            </header>
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
                    <xsl:apply-templates select=".//tei:event"/>
                </tbody>
            </table>
        </div>
    </xsl:template>
    <xsl:template match="tei:event">
        <tr>
            <td>
                <xsl:value-of select="ancestor::tei:div[@type = 'day']/tei:head/tei:date"/>
            </td>
            <td>
                <xsl:apply-templates select="tei:p/tei:persName"/>
            </td>
            <td>
                <xsl:apply-templates select="tei:p/tei:measure[@type = 'duration']"/>
            </td>
            <td>
                <xsl:apply-templates select="tei:p/tei:measure[@type = 'frequency']"/>
            </td>
            <td>
                <xsl:apply-templates select="tei:p/tei:measure[@type = 'price']"/>
            </td>
            <td>
                <xsl:apply-templates select="tei:p/tei:measure[@type = 'deposit']"/>
            </td>
        </tr>
    </xsl:template>
    <xsl:template match="tei:persName">
        <a href="subscribers.html?person={substring-after(@ref, '#')}">
            <xsl:apply-templates/>
        </a>
    </xsl:template>
    <xsl:template match="tei:measure[@type = 'duration']">
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