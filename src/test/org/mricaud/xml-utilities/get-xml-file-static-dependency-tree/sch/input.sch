<?xml version="1.0" encoding="UTF-8"?>
<schema 
  xmlns="http://purl.oclc.org/dsdl/schematron"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  queryBinding="xslt2"
  see="readme.txt"
  defaultPhase="test"
  >
  
  <xsl:include href="../xsl/module.xsl"/>
  
  <xsl:key name="getElementById" match="*[@id]" use="@id"/>
  
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
  
  <pattern id="test-2">
    <rule context="*[@id]">
      <extends rule="check-unique-id"/>
    </rule>
  </pattern>
  
  <pattern id="abstract-patterns">
    <rule id="check-unique-id" abstract="true">
      <assert test="count(key('getElementById', current()/@id)) = 1">
        @id="<value-of select="@xf:id"/>" must be unique within the document
      </assert>
    </rule>
  </pattern>
  
</schema>