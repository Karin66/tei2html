<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" 
  xmlns:eg="http://www.tei-c.org/ns/Examples"
  xmlns:xdoc="http://www.pnp-software.com/XSLTdoc" exclude-result-prefixes="#all"
  xmlns:fn="http://www.w3.org/2005/xpath-functions"
  xmlns="http://www.w3.org/1999/xhtml">
  
  <xdoc:doc type="stylesheet">
    <xdoc:author>John A. Walsh</xdoc:author>
    <xdoc:copyright>Copyright 2006 John A. Walsh</xdoc:copyright>
    <xdoc:short>XSLT stylesheet to transform TEI P5 documents to XHTML.</xdoc:short>
  </xdoc:doc>

<!-- lists -->


<xsl:template match="list">
<xsl:if test="contains(@rend, 'inline')">
	<xsl:attribute name="class">inline</xsl:attribute>
</xsl:if>
<xsl:if test="head">
  <xsl:apply-templates select="head" />
</xsl:if>
<xsl:choose>
 <xsl:when test="@type='catalogue'">
<!-- jawalsh removed <p> for xhtml -->
  <!-- <p>--><dl> 
    <xsl:for-each select="item">
<!--       <p /> -->
       <xsl:apply-templates select="."  mode="gloss" />
    </xsl:for-each>
  </dl><!-- </p> -->
 </xsl:when>
  <xsl:when test="@type='gloss' and @rend='multicol'">
    <xsl:variable name="nitems">
      <xsl:value-of select="count(item)div 2" />
    </xsl:variable>
    <!-- jawalsh: <p>-->
		<table>
    <tr>
      <td valign="top">
      <dl>
         <xsl:apply-templates mode="gloss" select="item[position()&lt;=$nitems ]" />
      </dl>
      </td>
      <td  valign="top">
      <dl>
         <xsl:apply-templates mode="gloss" select="item[position() &gt;$nitems]" />
      </dl>
      </td>
     </tr>
    </table>
    <!-- </p> -->
  </xsl:when>

 <xsl:when test="@type='gloss'">
		 <dl>
		   <xsl:call-template name="atts"/>
		   <xsl:apply-templates mode="gloss" select="item" />
		 </dl>
 </xsl:when>
 <xsl:when test="@type='glosstable'">
  <table><xsl:apply-templates mode="glosstable" select="item" /></table>
 </xsl:when>
 <xsl:when test="@type='vallist'">
  <table><xsl:apply-templates mode="glosstable" select="item" /></table>
 </xsl:when>
 <xsl:when test="@type='inline'">
   <xsl:if test="not(item)">None</xsl:if>
  <xsl:apply-templates select="item" mode="inline" />
 </xsl:when>
 <xsl:when test="@type='runin'">
  <p><xsl:apply-templates select="item" mode="runin" /></p>
 </xsl:when>
 <xsl:when test="@type='unordered' or @type = 'bulleted'">
  <ul>
<xsl:call-template name="atts"/>
  <xsl:apply-templates select="item" /></ul>
 </xsl:when>
  <xsl:when test="@type = 'simple'">
    <ul style="list-style-type: none;">
      <xsl:call-template name="rendition">
        <xsl:with-param name="defaultRend" select="'simple'"/>
      </xsl:call-template>
      <xsl:call-template name="rend"/>
      <xsl:call-template name="id"/>
      <xsl:apply-templates/>
    </ul>
  </xsl:when>
 <xsl:when test="@type='bibl'">
  <xsl:apply-templates select="item" mode="bibl" />
 </xsl:when>
 <xsl:when test="@type = 'ordered'">
  <ol>
    <xsl:call-template name="atts"/>
    <xsl:if test="child::item[1]/@n">
      <xsl:attribute name="start">
        <xsl:value-of select="child::item[1]/@n"/>
      </xsl:attribute>
    </xsl:if>
  <xsl:apply-templates select="item" />
  </ol>
 </xsl:when>
 <xsl:otherwise>
  <ul>
    <xsl:call-template name="rendition"/>
  <xsl:apply-templates select="item" /></ul>
 </xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template mode="bibl" match="item">
 <p>
   <xsl:apply-templates />
 </p>
</xsl:template>

<xsl:template mode="glosstable" match="item">
 <tr>
   <td valign="top"><strong>
     <xsl:apply-templates mode="print" select="preceding-sibling::*[1]" /></strong></td>
   <td><xsl:apply-templates /></td>
 </tr>
</xsl:template>

<xsl:template mode="gloss" match="item">
   <dt>
     <xsl:apply-templates mode="print" select="preceding-sibling::label[1]" />
   
   </dt>
   <dd><xsl:apply-templates /></dd>
</xsl:template>



<xsl:template match="list/label" />

<xsl:template match="item">
 <li>
   <xsl:choose>
   <xsl:when test="position() = 1">
     <xsl:call-template name="rendition">
     <xsl:with-param name="defaultRend">
       <xsl:value-of select="'first'"/>
     </xsl:with-param>
     </xsl:call-template>
     <xsl:call-template name="rend"/>
     <xsl:call-template name="id"/>
     
   </xsl:when>
   <xsl:when test="position() = last()">
     <xsl:call-template name="rendition">
     <xsl:with-param name="defaultRend">
       <xsl:value-of select="'last'"/>
     </xsl:with-param>
     </xsl:call-template>
     <xsl:call-template name="rend"/>
     <xsl:call-template name="id"/>
     
   </xsl:when>
     <xsl:otherwise>
   <xsl:call-template name="atts"/>
     </xsl:otherwise>
   </xsl:choose>
   
   
 <xsl:attribute name="id">
     <xsl:choose>
     <xsl:when test="@xml:id">
       <xsl:value-of select="@xml:id" />
     </xsl:when>
     <xsl:otherwise>
      <xsl:value-of select="generate-id()" />
     </xsl:otherwise>
    </xsl:choose>
  </xsl:attribute>
  <!-- for inline lists; handled in CSS, see "li.last" -->
   <!--
	<xsl:if test="position() = 1">
		<xsl:attribute name="class">first</xsl:attribute>
	</xsl:if>
	<xsl:if test="position() = last()">
		<xsl:attribute name="class">last</xsl:attribute>
	</xsl:if>
	-->
<xsl:apply-templates /></li>
</xsl:template>

<xsl:template match="item" mode="runin">
  &#8226; <xsl:apply-templates />&#160;
</xsl:template>

<xsl:template match="item" mode="inline">
  <xsl:if test="preceding-sibling::item">,  </xsl:if>
  <xsl:if test="not(following-sibling::item) and preceding-sibling::item"> and  </xsl:if>   
  <xsl:apply-templates />
</xsl:template>

<xsl:template match="label" mode="print">
<span>
  <xsl:call-template name="rendition"/>
  <xsl:call-template name="id"/>
  <xsl:apply-templates/>
</span>
  
</xsl:template>

<!-- jawalsh: tabBox -->

<xsl:template match="head" mode="tabBox">
<table class="tabBoxHead"><tr>
<td class="tabBoxHead"><xsl:apply-templates/></td>
</tr>
</table>
</xsl:template>

<xsl:template match="label" mode="tabBox">
 <table cellpadding="0" cellspacing="0" class="tabBox">
	 <tr><td class="tabBoxLabel"><xsl:value-of select="."/></td><td class="tabBoxLabelEmpty"/></tr>
	 <tr><td colspan="2" class="tabBoxContent"><xsl:apply-templates select="following-sibling::item[1]" mode="tabBox"/></td></tr>
 </table>
</xsl:template>

<xsl:template match="item" mode="tabBox">
	<xsl:apply-templates/>
</xsl:template>
  <!--
  
  <xsl:template match="castList">
    <div>
      <xsl:call-template name="atts"/>
      <xsl:if test="head">
        <xsl:apply-templates select="head"/>
      </xsl:if>
    <ul>
      <xsl:call-template name="atts"/>
      <xsl:apply-templates/>
    </ul>
      </div>
  </xsl:template>
  
  <xsl:template match="castItem">
    
    <li>
      <xsl:call-template name="atts"/>
      <xsl:apply-templates/>
    </li>
   
  </xsl:template>
  
  
-->

  
</xsl:stylesheet>

