<?xml version="1.0" encoding="UTF-8"?>
<schema 
  xmlns="http://purl.oclc.org/dsdl/schematron"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  queryBinding="xslt2"
  >
  <ns prefix="xsl" uri="http://www.w3.org/1999/XSL/Transform"/>
  
  <xsl:key name="getScenarioByName" match="scenario" use="field[@name = 'name']/String"/>
  <xsl:key name="getScenarioAssociationByScenarioId" match="scenarioAssociation" use="field[@name = 'scenarioIds']/list/String"/>
  
  <pattern>
    <rule context="field[@name = ('url', 'uri', 'inputXSLURL')]/String[not(matches(., '\$\{')) or starts-with(., '${pdu}')]">
      <let name="url" value="resolve-uri(replace(., '^\$\{pdu\}/',''), base-uri(.))"/>
      <assert test="doc-available($url)">
        Document <value-of select="tokenize($url, '/')[last()]"/> is not available at url <value-of select="$url"/>
      </assert>
    </rule>
    <!--fallback-->
    <rule context="field[@name = ('url', 'uri', 'inputXSLURL')]/String[matches(., '\$\{') and not(starts-with(., '${pdu}'))]">
      <report test="true()" role="warning">
        This url will not be verified
      </report>
    </rule>
    <rule context="scenarioAssociation">
      <assert test="count(preceding::scenarioAssociation[field[@name = 'url']/String = current()/field[@name = 'url']/String]) = 0">
        There already exist a <value-of select="name()"/> for <value-of select="field[@name = 'url']/String"/>
      </assert>
    </rule>
    <rule context="field[@name = 'scenarioIds']/list/String">
      <assert test="exists(key('getScenarioByName', .))">
        Scenario "<value-of select="."/>" doesn't exist
      </assert>
    </rule>
    <rule context="scenario">
      <assert test="exists(key('getScenarioAssociationByScenarioId', field[@name = 'name']/String))" 
        role="warning">
        Scenario "<value-of select="field[@name = 'name']"/>" is never called
      </assert>
    </rule>
  </pattern>
</schema>