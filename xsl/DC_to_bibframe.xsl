<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    xmlns:bf="http://id.loc.gov/ontologies/bibframe/"
    xmlns:bflc="http://id.loc.gov/ontologies/bflc/"
    xmlns:madsrdf="http://www.loc.gov/mads/rdf/v1#"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    exclude-result-prefixes="xsl">

  <!-- Parametr z przykładową datą przetworzenia (np. 2025-01-20).
       Możesz nadpisać go z Python (etree.XSLT) lub ustawić "na sztywno". -->
  <xsl:param name="currentDate" select="'2025-01-20'"/>

  <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
  <xsl:strip-space elements="*"/>

  <!-- ===================================================================
       GŁÓWNY SZABLON: generujemy <rdf:RDF> i przetwarzamy <article>.
     =================================================================== -->
  <xsl:template match="/">
    <rdf:RDF
      xmlns:bf="http://id.loc.gov/ontologies/bibframe/"
      xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
      xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
      xmlns:bflc="http://id.loc.gov/ontologies/bflc/"
      xmlns:madsrdf="http://www.loc.gov/mads/rdf/v1#">
      
      <!-- Przetwarzaj każdy <article> osobno -->
      <xsl:apply-templates select="articles/article"/>
      
    </rdf:RDF>
  </xsl:template>

  <!-- ===================================================================
       SZABLON DLA POJEDYNCZEGO <article> -> tworzymy bf:Work
     =================================================================== -->
  <xsl:template match="article">
    
    <bf:Work rdf:about="http://example.org/{dc:identifier}">
      
      <!-- Przykład bf:adminMetadata (opcjonalnie) -->
      <bf:adminMetadata>
        <bf:AdminMetadata>
          <bf:status>
            <bf:Status rdf:about="http://id.loc.gov/vocabulary/mstatus/n">
              <rdfs:label>new</rdfs:label>
            </bf:Status>
          </bf:status>
          <!-- Wstawiamy datę z parametru $currentDate -->
          <bf:date rdf:datatype="http://www.w3.org/2001/XMLSchema#date">
            <xsl:value-of select="$currentDate"/>
          </bf:date>
        </bf:AdminMetadata>
      </bf:adminMetadata>

      <!-- Tytuł (dc:title) -->
      <bf:title>
        <bf:Title>
          <bf:mainTitle>
            <xsl:value-of select="dc:title"/>
          </bf:mainTitle>
        </bf:Title>
      </bf:title>

      <!-- Autor (dc:creator) z rolą aut -->
      <bf:contribution>
        <bf:Contribution>
          <bf:agent>
            <bf:Agent>
              <rdfs:label>
                <xsl:value-of select="dc:creator"/>
              </rdfs:label>
            </bf:Agent>
          </bf:agent>
          <bf:role rdf:resource="http://id.loc.gov/vocabulary/relators/aut"/>
        </bf:Contribution>
      </bf:contribution>

      <!-- Typ (dc:type) -> bf:genreForm -->
      <xsl:if test="normalize-space(dc:type)">
        <bf:genreForm>
          <bf:GenreForm>
            <rdfs:label>
              <xsl:value-of select="dc:type"/>
            </rdfs:label>
          </bf:GenreForm>
        </bf:genreForm>
      </xsl:if>

      <!-- Link (dc:relation) -> bf:identifiedBy/bf:Identifier -->
      <xsl:if test="normalize-space(dc:relation)">
        <bf:identifiedBy>
          <bf:Identifier>
            <rdf:value>
              <xsl:value-of select="dc:relation"/>
            </rdf:value>
          </bf:Identifier>
        </bf:identifiedBy>
      </xsl:if>

      <!-- Data artykułu (dc:date) -> bf:provisionActivity/bf:date -->
      <xsl:if test="normalize-space(dc:date)">
        <bf:provisionActivity>
          <bf:ProvisionActivity>
            <bf:date>
              <xsl:value-of select="dc:date"/>
            </bf:date>
          </bf:ProvisionActivity>
        </bf:provisionActivity>
      </xsl:if>

      <!-- Miejsce publikacji (dc:publication_place) -->
      <xsl:if test="normalize-space(dc:publication_place)">
        <bf:provisionActivity>
          <bf:ProvisionActivity>
            <bf:place>
              <bf:Place>
                <rdfs:label>
                  <xsl:value-of select="dc:publication_place"/>
                </rdfs:label>
              </bf:Place>
            </bf:place>
          </bf:ProvisionActivity>
        </bf:provisionActivity>
      </xsl:if>

      <!-- OPCJONALNY JĘZYK (dc:language) -> bf:language/bf:Language -->
      <xsl:if test="normalize-space(dc:language)">
        <bf:language>
          <bf:Language rdf:about="http://id.loc.gov/vocabulary/languages/{normalize-space(dc:language)}">
            <rdfs:label>
              <xsl:value-of select="normalize-space(dc:language)"/>
            </rdfs:label>
          </bf:Language>
        </bf:language>
      </xsl:if>

      <!-- open_access (dc:open_access) -> bflc:accessPolicy,
           ALE TYLKO JEŚLI != 'FAŁSZ' I != puste  -->
      <xsl:if test="normalize-space(dc:open_access) != 'FAŁSZ' 
                    and normalize-space(dc:open_access) != ''">
        <bflc:accessPolicy>
          <rdfs:label>
            <xsl:value-of select="dc:open_access"/>
          </rdfs:label>
        </bflc:accessPolicy>
      </xsl:if>

      <!-- Example notatki: source_number (dc:source_number) -->
      <xsl:if test="normalize-space(dc:source_number)">
        <bf:note>
          <bf:Note>
            <rdfs:label>
              <xsl:text>Source number: </xsl:text>
              <xsl:value-of select="dc:source_number"/>
            </rdfs:label>
          </bf:Note>
        </bf:note>
      </xsl:if>

      <!-- OPCJONALNIE: subject -> bf:subject/bf:Topic -->
      <xsl:for-each select="dc:subject">
        <xsl:if test="normalize-space(.)">
          <bf:subject>
            <bf:Topic>
              <rdfs:label>
                <xsl:value-of select="normalize-space(.)"/>
              </rdfs:label>
              <!-- Jeżeli chcesz, możesz dopisać:
                   <madsrdf:authoritativeLabel> ... </madsrdf:authoritativeLabel> -->
            </bf:Topic>
          </bf:subject>
        </xsl:if>
      </xsl:for-each>

      <!-- RELACJA: artykuł jest częścią czasopisma (dc:source) -->
      <xsl:if test="normalize-space(dc:source)">
        <bf:relation>
          <bf:Relation>
            <bf:relationship rdf:resource="http://id.loc.gov/vocabulary/relationship/partof"/>
            <bf:associatedResource>
              <!-- Poziom Work dla czasopisma -->
              <bf:Work rdf:about="http://example.org/journal-{dc:source}">
                <bf:title>
                  <bf:Title>
                    <bf:mainTitle>
                      <xsl:value-of select="dc:source"/>
                    </bf:mainTitle>
                  </bf:Title>
                </bf:title>

                <!-- Na poziomie Work tworzymy Instance -->
                <bf:hasInstance>
                  <bf:Instance rdf:about="http://example.org/journal-instance-{dc:source}">
                    <bf:title>
                      <bf:Title>
                        <bf:mainTitle>
                          <xsl:value-of select="dc:source"/>
                        </bf:mainTitle>
                      </bf:Title>
                    </bf:title>
                    <bf:instanceOf rdf:resource="http://example.org/journal-{dc:source}"/>

                    <!-- Można dodać source_date, source_place, jeśli w DC -->
                    <xsl:if test="normalize-space(dc:source_date) or normalize-space(dc:source_place)">
                      <bf:provisionActivity>
                        <bf:ProvisionActivity>
                          <xsl:if test="normalize-space(dc:source_date)">
                            <bf:date>
                              <xsl:value-of select="dc:source_date"/>
                            </bf:date>
                          </xsl:if>
                          <xsl:if test="normalize-space(dc:source_place)">
                            <bf:place>
                              <bf:Place>
                                <rdfs:label>
                                  <xsl:value-of select="dc:source_place"/>
                                </rdfs:label>
                              </bf:Place>
                            </bf:place>
                          </xsl:if>
                        </bf:ProvisionActivity>
                      </bf:provisionActivity>
                    </xsl:if>

                    <!-- Tom, numer, strony (volume, issue, pages) -->
                    <bf:part>
                      <xsl:choose>
                        <xsl:when test="normalize-space(dc:volume) 
                                        or normalize-space(dc:issue) 
                                        or normalize-space(dc:pages)">
                          <!-- volume -->
                          <xsl:if test="normalize-space(dc:volume)">
                            <xsl:text>Vol. </xsl:text>
                            <xsl:value-of select="normalize-space(dc:volume)"/>
                          </xsl:if>

                          <!-- issue -->
                          <xsl:if test="normalize-space(dc:issue)">
                            <!-- przecinek, jeśli volume niepuste -->
                            <xsl:if test="normalize-space(dc:volume)">
                              <xsl:text>, </xsl:text>
                            </xsl:if>
                            <xsl:text>Issue </xsl:text>
                            <xsl:value-of select="normalize-space(dc:issue)"/>
                          </xsl:if>

                          <!-- pages -->
                          <xsl:if test="normalize-space(dc:pages)">
                            <!-- przecinek, jeśli volume lub issue niepuste -->
                            <xsl:if test="normalize-space(dc:volume) or normalize-space(dc:issue)">
                              <xsl:text>, </xsl:text>
                            </xsl:if>
                            <xsl:text>Pages </xsl:text>
                            <xsl:value-of select="normalize-space(dc:pages)"/>
                          </xsl:if>
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:text>No volume, issue, or pages provided.</xsl:text>
                        </xsl:otherwise>
                      </xsl:choose>
                    </bf:part>

                    <!-- Item w bibliotece -->
                    <bf:hasItem>
                      <bf:Item rdf:about="http://example.org/journal-item-{dc:source}">
                        <bf:heldBy>
                          <bf:Agent>
                            <rdfs:label>Local Library</rdfs:label>
                          </bf:Agent>
                        </bf:heldBy>
                      </bf:Item>
                    </bf:hasItem>

                  </bf:Instance>
                </bf:hasInstance>

              </bf:Work>
            </bf:associatedResource>
          </bf:Relation>
        </bf:relation>
      </xsl:if>

    </bf:Work>
  </xsl:template>

</xsl:stylesheet>
