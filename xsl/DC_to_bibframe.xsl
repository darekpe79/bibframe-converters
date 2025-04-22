<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    xmlns:bf="http://id.loc.gov/ontologies/bibframe/"
    xmlns:bflc="http://id.loc.gov/ontologies/bflc/"
    xmlns:madsrdf="http://www.loc.gov/mads/rdf/v1#"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    exclude-result-prefixes="xsl">

	<xsl:param name="currentDate" select="'2025-03-30'"/>
	<xsl:output method="xml" indent="yes" encoding="UTF-8"/>
	<xsl:strip-space elements="*"/>

	<!-- ===== KLUCZE ===== -->
	<xsl:key name="authorsByName" match="dc:creator" use="normalize-space(.)"/>
	<xsl:key name="journalByISSN" match="article" use="normalize-space(dc:source_issn)"/>
	<xsl:key name="articlesByID" match="article" use="normalize-space(dc:identifier)"/>
	<xsl:key name="journalIssueByNumber" match="article"
			 use="concat(normalize-space(dc:source_issn), '|', normalize-space(dc:source_number))"/>

	<!-- ===== GŁÓWNY SZABLON ===== -->
	<xsl:template match="/">
		<rdf:RDF>

			<!-- A) Autorzy -->
			<xsl:apply-templates select="articles/article/dc:creator[normalize-space(.) and generate-id() = generate-id(key('authorsByName', normalize-space(.))[1])]"/>

			<!-- B) Czasopismo -->
			<xsl:apply-templates select="articles/article[normalize-space(dc:source_issn) and generate-id() = generate-id(key('journalByISSN', normalize-space(dc:source_issn))[1])]">
				<xsl:with-param name="mode" select="'journal'"/>
			</xsl:apply-templates>

			<!-- C) Artykuły -->
			<xsl:apply-templates select="articles/article[generate-id() = generate-id(key('articlesByID', normalize-space(dc:identifier))[1])]">
				<xsl:with-param name="mode" select="'article'"/>
			</xsl:apply-templates>

		</rdf:RDF>
	</xsl:template>

	<!-- ===== AUTOR ===== -->
	<xsl:template match="dc:creator">
		<bf:Agent rdf:about="http://example.org/agent/{translate(normalize-space(.), ' ', '_')}">
			<rdfs:label>
				<xsl:value-of select="normalize-space(.)"/>
			</rdfs:label>
		</bf:Agent>
	</xsl:template>

	<!-- ===== SZABLON ARTYKUŁU LUB CZASOPISMA ===== -->
	<xsl:template match="article">
		<xsl:param name="mode" select="''"/>

		<!-- CZASOPISMO -->
		<xsl:if test="$mode='journal'">
			<bf:Work rdf:about="http://example.org/journal/issn/{normalize-space(dc:source_issn)}">
				<bf:adminMetadata>
					<bf:AdminMetadata>
						<bf:date rdf:datatype="http://www.w3.org/2001/XMLSchema#date">
							<xsl:value-of select="$currentDate"/>
						</bf:date>
					</bf:AdminMetadata>
				</bf:adminMetadata>

				<bf:title>
					<bf:Title>
						<bf:mainTitle>
							<xsl:value-of select="key('journalByISSN', normalize-space(dc:source_issn))[1]/dc:source"/>
						</bf:mainTitle>
					</bf:Title>
				</bf:title>

				<bf:identifiedBy>
					<bf:Identifier>
						<rdf:value>
							<xsl:value-of select="normalize-space(dc:source_issn)"/>
						</rdf:value>
						<bf:identifierScheme>issn</bf:identifierScheme>
					</bf:Identifier>
				</bf:identifiedBy>

				<!-- Numery czasopisma -->
				<xsl:for-each select="key('journalByISSN', normalize-space(dc:source_issn))">
					<xsl:variable name="currentNumber" select="normalize-space(dc:source_number)" />
					<xsl:if test="position() = 1 or not(preceding-sibling::article[normalize-space(dc:source_number) = $currentNumber])">
						<xsl:if test="normalize-space(dc:source_number) != ''">
							<bf:hasInstance>
								<bf:Instance rdf:about="http://example.org/journal-instance/issn/{normalize-space(dc:source_issn)}/num/{$currentNumber}">
									<bf:identifiedBy>
										<bf:Identifier>
											<rdf:value>
												<xsl:value-of select="$currentNumber"/>
											</rdf:value>
											<bf:identifierScheme>issue number</bf:identifierScheme>
										</bf:Identifier>
									</bf:identifiedBy>
								</bf:Instance>
							</bf:hasInstance>
						</xsl:if>
					</xsl:if>
				</xsl:for-each>
			</bf:Work>
		</xsl:if>

		<!-- ARTYKUŁ -->
		<xsl:if test="$mode='article'">
			<bf:Work rdf:about="http://example.org/article/{normalize-space(dc:identifier)}">
				<bf:adminMetadata>
					<bf:AdminMetadata>
						<bf:status>
							<bf:Status rdf:about="http://id.loc.gov/vocabulary/mstatus/n">
								<rdfs:label>new</rdfs:label>
							</bf:Status>
						</bf:status>
						<bf:date rdf:datatype="http://www.w3.org/2001/XMLSchema#date">
							<xsl:value-of select="$currentDate"/>
						</bf:date>
					</bf:AdminMetadata>
				</bf:adminMetadata>

				<bf:title>
					<bf:Title>
						<bf:mainTitle>
							<xsl:value-of select="dc:title"/>
						</bf:mainTitle>
					</bf:Title>
				</bf:title>

				<xsl:for-each select="dc:creator[normalize-space(.)]">
					<bf:contribution>
						<bf:Contribution>
							<bf:agent rdf:resource="http://example.org/agent/{translate(normalize-space(.), ' ', '_')}"/>
							<bf:role rdf:resource="http://id.loc.gov/vocabulary/relators/aut"/>
						</bf:Contribution>
					</bf:contribution>
				</xsl:for-each>

				<xsl:if test="normalize-space(dc:type)">
					<bf:genreForm>
						<bf:GenreForm>
							<rdfs:label>
								<xsl:value-of select="dc:type"/>
							</rdfs:label>
						</bf:GenreForm>
					</bf:genreForm>
				</xsl:if>

				<xsl:if test="normalize-space(dc:relation)">
					<bf:identifiedBy>
						<bf:Identifier>
							<rdf:value>
								<xsl:value-of select="dc:relation"/>
							</rdf:value>
						</bf:Identifier>
					</bf:identifiedBy>
				</xsl:if>

				<xsl:if test="normalize-space(dc:date)">
					<bf:provisionActivity>
						<bf:ProvisionActivity>
							<bf:date>
								<xsl:value-of select="dc:date"/>
							</bf:date>
						</bf:ProvisionActivity>
					</bf:provisionActivity>
				</xsl:if>

				<xsl:if test="normalize-space(dc:open_access) != 'FAŁSZ' and normalize-space(dc:open_access) != ''">
					<bflc:accessPolicy>
						<rdfs:label>
							<xsl:value-of select="dc:open_access"/>
						</rdfs:label>
					</bflc:accessPolicy>
				</xsl:if>

				<xsl:if test="normalize-space(dc:pages)">
					<bf:note>
						<bf:Note>
							<rdfs:label>
								<xsl:text>Pages: </xsl:text>
								<xsl:value-of select="dc:pages"/>
							</rdfs:label>
						</bf:Note>
					</bf:note>
				</xsl:if>

				<xsl:if test="normalize-space(dc:source_issn)">
					<bf:relation>
						<bf:Relation>
							<bf:relationship rdf:resource="http://id.loc.gov/vocabulary/relationship/partOf"/>
							<bf:associatedResource>
								<bf:Work rdf:about="http://example.org/journal/issn/{normalize-space(dc:source_issn)}"/>
							</bf:associatedResource>
						</bf:Relation>
					</bf:relation>
				</xsl:if>
			</bf:Work>
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>
