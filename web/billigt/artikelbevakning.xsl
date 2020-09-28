<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet id="stylesheet" version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:template match="/">
  <html>
  <body>
  <h2>Artikelbevakning</h2>
    <table border="1">
      <tr bgcolor="#9acd32">
        <th>handelsedatum</th>
        <th>artnr</th>
        <th>namn</th>
        <th>nettopris</th>
        <th>enhet</th>
        <th>inprisdatum</th>
        <th>utgattdatum</th>
        <th>rsk</th>
        <th>lagersaldo</th>
        <th>maxlager</th>
        
      </tr>
      <xsl:for-each select="data/artikel">
      <tr>
        <td><xsl:value-of select="handelsedatum"/></td>
        <td><xsl:value-of select="artnr"/></td>
        <td><xsl:value-of select="namn"/></td>
        <td><xsl:value-of select="nettopris"/></td>
        <td><xsl:value-of select="enhet"/></td>
        <td><xsl:value-of select="inprisdatum"/></td>
        <td><xsl:value-of select="utgattdatum"/></td>
        <td><xsl:value-of select="rsk"/></td>
        <td><xsl:value-of select="ilager"/></td>
        <td><xsl:value-of select="maxlager"/></td>
      </tr>
      </xsl:for-each>
    </table>
  </body>
  </html>
</xsl:template>
</xsl:stylesheet>
