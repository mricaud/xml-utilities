<?xml version= "1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:xut="https://github.com/mricaud/xml-utilities"
  xmlns:xslt="http://www.w3.org/1999/XSL/Transform"
  version="3.0"
  exclude-result-prefixes="#all">
  <!--xmlns="http://www.w3.org/1999/xhtml" : 
    https://markmail.org/message/3gjcl5iptxgaeokk : 
    DON'T use HTML Namespace so script and css a properly escaped (cdata section wouldn't work)-->

  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p><xd:b>Author:</xd:b> Matthieu Ricaud-Dussarget</xd:p>
      <xd:p>Generate an HTML view of an XSLT which shows the global modes calling (for multi-step XSLT especially)</xd:p>
      <xd:p>Getting XML dependencies for an XSLT is often usefull but it does't always allow to understand how XSLT modules are binded together.</xd:p>
      <xd:p>Assuming a good practice is to use different modes for each modules, one can use get-xml-file-static-dependency-tree.xsl to show how modes are called from one XSLT to another.</xd:p>
    </xd:desc>
  </xd:doc>
  
  <xsl:import href="get-xml-file-static-dependency-tree.xsl"/>
  
  <xsl:output name="xut:xhtml" method="html" indent="no"/>
  
  <xsl:param name="xut:get-xml-file-static-dependency-tree.getContent" select="true()" as="xs:boolean"/>
  <xsl:param name="xut:get-xml-file-static-dependency-tree.display-messages" select="false()" as="xs:boolean"/>
  
  <xsl:key name="xut:getXslTemplateByMode" match="xsl:template" use="tokenize(@mode, '\s+')"/>
  
  <!--================================================================================================================-->
  <!--INIT-->
  <!--================================================================================================================-->
  
  <xd:p>Calling this xsl with no specific mode should work, as long as with mode="xut:get-xslt-modes-architecture.main"</xd:p>
  <xsl:template match="/">
    <xsl:apply-templates select="." mode="xut:get-xslt-modes-architecture.main"/>
  </xsl:template>
  
  <!--================================================================================================================-->
  <!--MAIN DRIVER-->
  <!--================================================================================================================-->
  
  <xsl:template match="/" mode="xut:get-xslt-modes-architecture.main">
    <xsl:variable name="step" as="document-node()">
      <xsl:document>
        <xsl:apply-templates select="." mode="xut:get-xml-dependency-tree.main"/>
      </xsl:document>
    </xsl:variable>
    <xsl:variable name="step" as="document-node()">
      <xsl:document>
        <xsl:apply-templates select="$step/file/content/xsl:*" mode="xut:get-xslt-modes-architecture.main-template"/>
      </xsl:document>
    </xsl:variable>
    <xslt:result-document format="xut:xhtml">
      <html>
        <head>
          <title><xsl:value-of select="tokenize(base-uri(.), '/')[last()]"/> modes architecture</title>
          <style type="text/css">
            body{
              font-family:sans-serif;
              margin:1em 5em;
            }
            li{list-style-type:none;}
            li > p{cursor:pointer;}
            ul{
              margin-top:1em;
              border-radius:12px;
              padding:0 1em 0 1em;
              border:1px solid grey;
              margin-bottom:1em;
            }
            ul.collapse{background-color:silver;}
            ul.collapse > li > ul,
            ul.collapse > li > ul > li{
              display:none;
            }
            a.content-link{padding-left:0.5em;font-size:0.8em;}
            pre.collapse{
              display:none;
            }
          </style>
          <script type="text/javascript" src="https://code.jquery.com/jquery-3.3.1.min.js"/>
          <script type="text/javascript">
             try {
              $(function(){
                $(document).ready(function() {
                  $( "p.mode > span" ).click(function() {
                    $(this).parent().parent().parent().toggleClass( "collapse" );
                  });
                  $( "a.content-link" ).click(function() {
                    $(this).parent().parent().children("pre").toggleClass( "collapse" );
                    <!--$(this).parent().parent().children("pre").find(">:first-child").toggleClass( "collapse" );-->
                  });
                });
              });
              } catch(err){}
          </script>
        </head>
        <body>
          <h1><xsl:value-of select="tokenize(base-uri(.), '/')[last()]"/></h1>
          <xsl:apply-templates select="$step" mode="xut:get-xslt-modes-architecture.filter-result"/>
        </body>
      </html>
    </xslt:result-document>
  </xsl:template>
  
  <!--================================================================================================================-->
  <!--MAIN-TEMPLATE-->
  <!--================================================================================================================-->
  
  <xsl:template match="/file/content/xsl:stylesheet | /file/content/xsl:transform" mode="xut:get-xslt-modes-architecture.main-template">
    <xsl:apply-templates select="xsl:template[@match = '/'][(@mode, '#default')[1] = '#default']" mode="#current"/>
  </xsl:template>
  
  <xsl:template match="xsl:template[@match = '/'][(@mode, '#default')[1] = '#default']" mode="xut:get-xslt-modes-architecture.main-template">
    <xsl:variable name="main-mode" select="tokenize(xsl:apply-templates/@mode, '\s+')" as="xs:string*"/>
    <xsl:choose>
      <xsl:when test="count($main-mode) = 1">
        <ul class="xsl_template main">
          <li>
            <p class="mode">Mode <xsl:value-of select="$main-mode"/></p>
            <xsl:apply-templates select="key('xut:getXslTemplateByMode', $main-mode, root(.))" mode="xut:get-xslt-modes-architecture.steps-template">
              <xsl:with-param name="processed-modes" select="$main-mode" as="xs:string*" tunnel="yes"/>
            </xsl:apply-templates>
            <!--[@match = ('/', '/*')]-->
          </li>
        </ul>
      </xsl:when>
      <xsl:otherwise>
        <p>Unable to get the main mode</p>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!--================================================================================================================-->
  <!--STEPS-TEMPLATE-->
  <!--================================================================================================================-->
  
  <xsl:template match="xsl:template" mode="xut:get-xslt-modes-architecture.steps-template">
    <!--<xsl:if test="xsl:apply-templates[not((@mode, '#current')[1] = '#current')]">
      <pre class="content collapse">
        <xsl:value-of select="serialize(.)"/>
      </pre>
    </xsl:if>-->
    <xsl:apply-templates select="descendant::xsl:apply-templates" mode="#current"/>
  </xsl:template>
  
  <xsl:template match="xsl:apply-templates[not((@mode, '#current')[1] = '#current')]" mode="xut:get-xslt-modes-architecture.steps-template">
    <xsl:param name="processed-modes" as="xs:string*" tunnel="yes"/>
    <xsl:message>LOC at xsl:apply-template <xsl:value-of select="@mode"/> (while matching <xsl:value-of select="ancestor::xsl:template/@match"/>)</xsl:message>
    <xsl:variable name="mode" select="tokenize(@mode, '\s+')" as="xs:string*"/>
    <xsl:choose>
      <xsl:when test="$mode = $processed-modes">
        <!--<p>mode <xsl:value-of select="$mode"/> has already been processed</p>-->
      </xsl:when>
      <xsl:when test="count($mode) = 1">
        <pre class="content collapse">
          <xsl:value-of select="serialize(ancestor::xsl:template[1])"/>
        </pre>
        <ul class="xsl_apply-templates">
          <li>
            <p class="mode">Mode <xsl:value-of select="$mode"/></p>
            <xsl:message>GOTO template mode="<xsl:value-of select="$mode"/>"</xsl:message>
            <xsl:apply-templates select="key('xut:getXslTemplateByMode', $mode, root(.))" mode="#current">
              <xsl:with-param name="processed-modes" select="($processed-modes, $mode)" as="xs:string*" tunnel="yes"/>
            </xsl:apply-templates>
          </li>
        </ul>
      </xsl:when>
      <xsl:otherwise>
        <p>Unable to get the main mode for this apply-templates</p>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="xsl:apply-templates" mode="xut:get-xslt-modes-architecture.steps-template" priority="-1"/>
  
  <!--================================================================================================================-->
  <!--STEPS-TEMPLATE-->
  <!--================================================================================================================-->
  
  <!--<xsl:template match="ul" mode="xut:get-xslt-modes-architecture.filter-result">
    <xsl:if test="not(preceding-sibling::*[deep-equal(., current())])">
      <xsl:next-match/>
    </xsl:if>
  </xsl:template>-->

  <xsl:template match="p[@class = 'mode']" mode="xut:get-xslt-modes-architecture.filter-result">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="#current"/>
      <span>
        <xsl:apply-templates mode="#current"/>
      </span>
      <xsl:if test="following-sibling::pre">
        <a href="javascript::void()" class="content-link">[content]</a>
      </xsl:if>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="pre/text()" mode="xut:get-xslt-modes-architecture.filter-result">
    <xsl:sequence select="replace(., 'xmlns(:.*?)?=.*?\s', '')"/>
  </xsl:template>
  
  <xsl:template match="node() | @*" mode="xut:get-xslt-modes-architecture.filter-result">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>