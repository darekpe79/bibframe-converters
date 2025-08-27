<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:bf="http://id.loc.gov/ontologies/bibframe/"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    exclude-result-prefixes="xsl dc">

	<xsl:output method="xml" indent="yes" encoding="UTF-8"/>

	<!-- Klucze -->
	<xsl:key name="journalByISSN" match="article" use="normalize-space(dc:source_issn)"/>
	<xsl:key name="creatorKey" match="dc:creator" use="normalize-space(.)"/>
	<xsl:key name="contributorKey" match="dc:contributor" use="normalize-space(.)"/>
	<xsl:key name="issueKey" match="article" use="concat(normalize-space(dc:source_issn), '|', normalize-space(dc:source_number))"/>

	<xsl:template match="/">
		<rdf:RDF>

			<!-- Czasopisma -->
			<xsl:for-each select="articles/article[generate-id() = generate-id(key('journalByISSN', normalize-space(dc:source_issn))[1])]">
				<bf:Work>
					<xsl:attribute name="rdf:about">
						<xsl:text>http://example.org/journal/issn/</xsl:text>
						<xsl:value-of select="normalize-space(dc:source_issn)"/>
					</xsl:attribute>
					<bf:title>
						<bf:Title>
							<bf:mainTitle>
								<xsl:value-of select="normalize-space(dc:source)"/>
							</bf:mainTitle>
						</bf:Title>
					</bf:title>
					<bf:identifiedBy>
						<bf:Issn>
							<rdf:value>
								<xsl:value-of select="normalize-space(dc:source_issn)"/>
							</rdf:value>
						</bf:Issn>
					</bf:identifiedBy>

					<!-- Instancje czasopisma -->
					<xsl:for-each select="/articles/article[dc:source_issn = current()/dc:source_issn]">
						<xsl:if test="generate-id() = generate-id(key('issueKey', concat(normalize-space(dc:source_issn), '|', normalize-space(dc:source_number)))[1])">
							<bf:hasInstance>
								<bf:Instance>
									<xsl:attribute name="rdf:about">
										<xsl:text>http://example.org/journal-instance/</xsl:text>
										<xsl:value-of select="normalize-space(dc:source_issn)"/>
										<xsl:text>/num/</xsl:text>
										<xsl:value-of select="normalize-space(dc:source_number)"/>
									</xsl:attribute>

									<xsl:if test="normalize-space(dc:date) or normalize-space(dc:source_place)">
										<bf:provisionActivity>
											<bf:ProvisionActivity>
												<xsl:if test="normalize-space(dc:date)">
													<bf:date>
														<xsl:value-of select="normalize-space(dc:date)"/>
													</bf:date>
												</xsl:if>
												<xsl:if test="normalize-space(dc:source_place)">
													<bf:place>
														<bf:Place>
															<rdfs:label>
																<xsl:value-of select="normalize-space(dc:source_place)"/>
															</rdfs:label>
														</bf:Place>
													</bf:place>
												</xsl:if>
											</bf:ProvisionActivity>
										</bf:provisionActivity>
									</xsl:if>

									<bf:enumerationAndChronology>
										<bf:EnumerationAndChronology>
											<xsl:if test="normalize-space(dc:source_number)">
												<bf:enumeration>
													<xsl:value-of select="normalize-space(dc:source_number)"/>
												</bf:enumeration>
											</xsl:if>
											<xsl:if test="normalize-space(dc:source_date)">
												<bf:chronology>
													<xsl:value-of select="normalize-space(dc:source_date)"/>
												</bf:chronology>
											</xsl:if>
										</bf:EnumerationAndChronology>
									</bf:enumerationAndChronology>

									<xsl:if test="normalize-space(dc:open_access)">
										<bf:usageAndAccessPolicy>
											<xsl:value-of select="normalize-space(dc:open_access)"/>
										</bf:usageAndAccessPolicy>
									</xsl:if>

									<bf:instanceOf rdf:resource="http://example.org/journal/issn/{normalize-space(dc:source_issn)}"/>
								</bf:Instance>
							</bf:hasInstance>
						</xsl:if>
					</xsl:for-each>
				</bf:Work>
			</xsl:for-each>

			<!-- Agenci -->
			<xsl:for-each select="//dc:creator[generate-id() = generate-id(key('creatorKey', normalize-space(.))[1])]">
				<bf:Agent>
					<xsl:attribute name="rdf:about">
						<xsl:text>http://example.org/agent/</xsl:text>
						<xsl:value-of select="translate(normalize-space(.), ' ', '_')"/>
					</xsl:attribute>
					<rdfs:label>
						<xsl:value-of select="normalize-space(.)"/>
					</rdfs:label>
				</bf:Agent>
			</xsl:for-each>

			<xsl:for-each select="//dc:contributor[generate-id() = generate-id(key('contributorKey', normalize-space(.))[1])]">
				<bf:Agent>
					<xsl:attribute name="rdf:about">
						<xsl:text>http://example.org/agent/</xsl:text>
						<xsl:value-of select="translate(normalize-space(.), ' ', '_')"/>
					</xsl:attribute>
					<rdfs:label>
						<xsl:value-of select="normalize-space(.)"/>
					</rdfs:label>
				</bf:Agent>
			</xsl:for-each>

			<!-- Artykuły -->
			<xsl:apply-templates select="articles/article"/>

		</rdf:RDF>
	</xsl:template>

	<xsl:template match="article">
		<!-- Artykuł jako Work -->
		<bf:Work>
			<xsl:attribute name="rdf:about">
				<xsl:text>http://example.org/article/</xsl:text>
				<xsl:value-of select="normalize-space(dc:identifier)"/>
			</xsl:attribute>

			<bf:title>
				<bf:Title>
					<bf:mainTitle>
						<xsl:value-of select="normalize-space(dc:title)"/>
					</bf:mainTitle>
				</bf:Title>
			</bf:title>

			<!-- Autorzy -->
			<xsl:for-each select="dc:creator">
				<bf:contribution>
					<bf:Contribution>
						<bf:agent rdf:resource="http://example.org/agent/{translate(normalize-space(.), ' ', '_')}"/>
						<bf:role>
							<bf:Role rdf:about="http://id.loc.gov/vocabulary/relators/aut"/>
						</bf:role>
					</bf:Contribution>
				</bf:contribution>
			</xsl:for-each>

			<!-- Współtwórcy -->
			<xsl:for-each select="dc:contributor">
				<bf:contribution>
					<bf:Contribution>
						<bf:agent rdf:resource="http://example.org/agent/{translate(normalize-space(.), ' ', '_')}"/>
						<bf:role>
							<bf:Role rdf:about="http://id.loc.gov/vocabulary/relators/ctb"/>
						</bf:role>
					</bf:Contribution>
				</bf:contribution>
			</xsl:for-each>

			<!-- Typ -->
			<xsl:if test="normalize-space(dc:type)">
				<bf:genreForm>
					<bf:GenreForm>
						<rdfs:label>
							<xsl:value-of select="normalize-space(dc:type)"/>
						</rdfs:label>
					</bf:GenreForm>
				</bf:genreForm>
			</xsl:if>

			<!-- Instancja artykułu -->
			<bf:hasInstance>
				<bf:Instance>
					<xsl:attribute name="rdf:about">
						<xsl:text>http://example.org/instance/article/</xsl:text>
						<xsl:value-of select="normalize-space(dc:identifier)"/>
					</xsl:attribute>

					<bf:instanceOf rdf:resource="http://example.org/article/{normalize-space(dc:identifier)}"/>
					<bf:partOf rdf:resource="http://example.org/journal-instance/{normalize-space(dc:source_issn)}/num/{normalize-space(dc:source_number)}"/>

					<xsl:if test="normalize-space(dc:pages)">
						<bf:extent>
							<bf:Extent>
								<rdf:value>
									<xsl:value-of select="normalize-space(dc:pages)"/>
								</rdf:value>
							</bf:Extent>
						</bf:extent>
					</xsl:if>

					<xsl:if test="normalize-space(dc:relation)">
						<bf:electronicLocator>
							<xsl:value-of select="normalize-space(dc:relation)"/>
						</bf:electronicLocator>
					</xsl:if>

					<xsl:if test="normalize-space(dc:open_access)">
						<bf:usageAndAccessPolicy>
							<xsl:value-of select="normalize-space(dc:open_access)"/>
						</bf:usageAndAccessPolicy>
					</xsl:if>

				</bf:Instance>
			</bf:hasInstance>
		</bf:Work>
	</xsl:template>
</xsl:stylesheet>
