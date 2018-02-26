<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0">
  
  <p:input port="source"/>
  <p:output port="result"/>
  
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
  <p:import href="folder/mod-1.xpl" xml:base="/my/absolute/path/"/>
  <p:import href="mod-1.xpl" xml:base="folder/"/>
  <p:import href="folder/mod-2.xpl"/>
  
  <p:load href="../xi-include/folder/elements.xml"/>
  
  <p:xslt>
    <p:input port="stylesheet">
      <p:document href="../xsl/folder/mod-1.xsl"/>
    </p:input>
  </p:xslt>
  
  <p:validate-with-xml-schema>
    <p:input port="schema">
      <p:document href="../xsd/folder/mod-2.xsd"/>
    </p:input>
  </p:validate-with-xml-schema>
  
</p:declare-step>