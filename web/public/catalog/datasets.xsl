<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="html" encoding="UTF-8" indent="yes"/>
<xsl:template match="/">
<html lang="en"><head><title><xsl:value-of select="datasetCatalog/@title"/></title><meta name="viewport" content="width=device-width,initial-scale=1"/>
<style>body{font:15px Segoe UI,Arial,sans-serif;background:#f4f7fb;color:#19232e;margin:0;padding:36px}main{max-width:1000px;margin:auto}h1{letter-spacing:-.04em}p{color:#667684}table{width:100%;border-collapse:collapse;background:white;border:1px solid #e1e8ee}th,td{text-align:left;padding:13px;border-bottom:1px solid #e9eef2}th{font-size:11px;text-transform:uppercase;color:#60716f}.tag{background:#e3f2ef;color:#176e65;border-radius:20px;padding:4px 8px;font-size:12px}</style></head>
<body><main><h1><xsl:value-of select="datasetCatalog/@title"/></h1><p>XML catalog rendered with the attached DTD and XSLT.</p>
<table><thead><tr><th>Dataset</th><th>Project</th><th>Format</th><th>Size (MB)</th><th>Description</th></tr></thead><tbody>
<xsl:for-each select="datasetCatalog/dataset"><tr><td><strong><xsl:value-of select="name"/></strong></td><td><xsl:value-of select="@project"/></td><td><span class="tag"><xsl:value-of select="@format"/></span></td><td><xsl:value-of select="@sizeMb"/></td><td><xsl:value-of select="description"/></td></tr></xsl:for-each>
</tbody></table></main></body></html>
</xsl:template></xsl:stylesheet>

