<?xml version="1.0" encoding="UTF-8"?>
<schema 
  xmlns="http://purl.oclc.org/dsdl/schematron"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  queryBinding="xslt2"
  see="readme.txt"
  defaultPhase="test"
  >

  <xsl:include href="../xsl/module.xsl"/>
  
  <!--see https://www.oxygenxml.com/forum/topic6804.html-->
  <extends href="folder/mod-1.sch"/>
  
  <phase id="test">
    <active pattern="test-1"/>
  </phase>
  
  <include href="folder/mod-2.sch"/>
  
  <pattern id="test-1">
    <rule context="/*">
      <assert test="true()">Root element</assert>
    </rule>
  </pattern>

</schema>