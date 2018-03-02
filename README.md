# xml-utilities: "XUT"
A set of XML utilities, like XSLT common tools etc.

## Content
- [get-xml-file-static-dependency-tree.md](src/main/xsl/org/mricaud/xml-utilities/README_get-xml-file-static-dependency-tree.md): an XSLT that generate a dependency tree by checking inclusion within common XML files like: XSLT, XSD, RNG, Schematron, XSpec, etc. 

## Build

To build the project from the sources, follow this steps:

```
$ git clone https://github.com/mricaud/xml-utilities
$ cd xml-utilities
$ mvn clean install
```

A jar file will be generated in target (and in your .m2 directory).

## Current version: 0.1.0

Maven support

```xml
<dependency>
    <groupId>org.mricaud.xml</groupId>
    <artifactId>xut</artifactId>
    <version>0.1.0</version>
</dependency>
```

You may also download the jar directly from Maven Central.

## Usage

### XSLT

- XSLT version is 3.0, you need to use an XSLT 3.0 processor
- Each XSLT may be called directly: without initial mode or parameters.
- You can also call it from your XSLT using an inclusion (like `xsl:import`) and then use:

```xml
<xsl:apply-template select="[xpath]" mode="xut:[XSLT name].main">
```

#### Lauch XSLT from the jar 

You can directly call any of the XSLT within the jar using Saxon for instance:

```
java -jar saxon.jar -s:input.xxx -xsl:jar:file:/path/to/xut-X.X.X.jar!/org/mricaud/xml-utilities/xxx.xsl
```

#### Use a catalog file

You can refer to the jar using a catalog file, for instance:

catalog.xml
```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE catalog PUBLIC "-//OASIS//DTD Entity Resolution XML Catalog V1.0//EN" "http://www.oasis-open.org/committees/entity/release/1.0/catalog.dtd">
<catalog xmlns="urn:oasis:names:tc:entity:xmlns:xml:catalog">
  <rewriteURI uriStartString="xut:/" rewritePrefix="jar:file:/path/to/xut-X.X.X.jar!/"/>
  <rewriteSystem systemIdStartString="xslLib:/" rewritePrefix="jar:file:/path/to/xut-X.X.X.jar!/"/>
</catalog>
```
Then with Saxon:

```
java -jar saxon.jar -Dxml.catalog.files=/path/to/catalog.xml -s:input.xxx -xsl:xut:/org/mricaud/xml-utilities/xxx.xsl
```

#### Lauch XSLT With your XML IDE (like Oxygen)

Use a catalog.xml as described above and set your XML IDE to use this catalog. Use `${pdu}/catalog.xml` in Oxygen.

You can also use the `catalogBuilder-maven-plugin` that will create the catalog.xml for you, as describe later.

#### Using the cp protocol

You can add the jar to your classpath and then use the [cp protocol](https://github.com/cmarchand/cp-protocol):

```
java top.marchand.xml.protocols.ProtocolInstaller net.sf.saxon.Transform -s:input.xxx -xsl:cp:/org/mricaud/xml-utilities/xxx.xsl
```

This supposes saxon.jar is also in your classpath.

#### Lauch XSLT with your Maven project

##### catalogBuilder-maven-plugin

If your project is build with Maven too, you can add the dependency as described above.

Then you can add the `catalogBuilder-maven-plugin`:

```
<plugin>
  <groupId>top.marchand.xml.maven</groupId>
  <artifactId>catalogBuilder-maven-plugin</artifactId>
  <version>1.0.4</version>
  <executions>
    <execution>
      <id>preparation</id>
      <goals>
        <goal>catalog</goal>
      </goals>
    </execution>
    <execution>
      <id>packaging</id>
      <phase>package</phase>
      <goals>
        <goal>catalog</goal>
      </goals>
      <!--Alternativ catalog file generation-->
      <!--<configuration>
        <rewriteToProtocol>cp</rewriteToProtocol>
        <catalogFileName>target/generated-catalog/catalog.xml</catalogFileName>
      </configuration>-->
    </execution>
  </executions>
</plugin>
```

It will create the catalog.xml file automatically (base on maven dependencies) and include it to your jar.

Then, if your jar and xut-X.X.X.jar (and saxon) are in your classpath, you can use:

```
java  -Dxml.catalog.files=cp:/to/jar-path/catalog.xml top.marchand.xml.protocols.ProtocolInstaller net.sf.saxon.Transform -s:input.xxx -xsl:cp:/org/mricaud/xml-utilities/xxx.xsl
```

Depending on where the catalog.xml file is generated (within the jar or outside).

##### maven-assembly-plugin

The maven-assembly-plugin can be used to generate a "full jar", that means a jar that contains the current project and all its dependencies:

```
<plugin>
  <artifactId>maven-assembly-plugin</artifactId>
  <version>2.6</version>
  <configuration>
    <descriptorRefs>
      <descriptorRef>jar-with-dependencies</descriptorRef>
    </descriptorRefs>
  </configuration>
  <executions>
    <execution>
      <phase>package</phase>
      <goals>
        <goal>single</goal>
      </goals>
    </execution>
  </executions>
</plugin>
```
