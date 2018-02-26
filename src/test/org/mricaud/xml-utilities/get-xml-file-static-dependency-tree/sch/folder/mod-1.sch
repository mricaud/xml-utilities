<?xml version="1.0" encoding="UTF-8"?>
<schema 
  xmlns="http://purl.oclc.org/dsdl/schematron" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  
  <xsl:include href="../../xsl/module.xsl"/>
  
  <pattern>
    <rule context="/*">
      <assert test="true()">Root element</assert>
    </rule>
  </pattern>
  
</schema>
