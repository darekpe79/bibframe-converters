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

	<xsl:param name="currentDate" select="'2025-01-20'"/>
	<xsl:output method="xml" indent="yes" encoding="UTF-8"/>
	<xsl:strip-space elements="*"/>

	<xsl:template match="/">
		<rdf:RDF>
			<xsl:apply-templates select="articles/article"/>
		</rdf:RDF>
	</xsl:template>

	<xsl:template match="article">
		<bf:Work rdf:about="http://example.org/{dc:identifier}">

			<!-- admin metadata -->
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

			<!-- title -->
			<bf:title>
				<bf:Title>
					<bf:mainTitle>
						<xsl:value-of select="dc:title"/>
					</bf:mainTitle>
				</bf:Title>
			</bf:title>

			<!-- creators -->
			<xsl:for-each select="dc:creator">
				<xsl:if test="normalize-space(.)">
					<bf:contribution>
						<bf:Contribution>
							<bf:agent>
								<bf:Agent>
									<rdfs:label>
										<xsl:value-of select="normalize-space(.)"/>
									</rdfs:label>
								</bf:Agent>
							</bf:agent>
							<bf:role rdf:resource="http://id.loc.gov/vocabulary/relators/aut"/>
						</bf:Contribution>
					</bf:contribution>
				</xsl:if>
			</xsl:for-each>

			<!-- contributors -->
			<xsl:for-each select="dc:contributor">
				<xsl:if test="normalize-space(.)">
					<bf:contribution>
						<bf:Contribution>
							<bf:agent>
								<bf:Agent>
									<rdfs:label>
										<xsl:value-of select="normalize-space(.)"/>
									</rdfs:label>
								</bf:Agent>
							</bf:agent>
							<bf:role rdf:resource="http://id.loc.gov/vocabulary/relators/ctb"/>
						</bf:Contribution>
					</bf:contribution>
				</xsl:if>
			</xsl:for-each>

			<!-- genreForm -->
			<xsl:if test="normalize-space(dc:type)">
				<bf:genreForm>
					<bf:GenreForm>
						<rdfs:label>
							<xsl:value-of select="dc:type"/>
						</rdfs:label>
					</bf:GenreForm>
				</bf:genreForm>
			</xsl:if>

			<!-- relation/link -->
			<xsl:if test="normalize-space(dc:relation)">
				<bf:identifiedBy>
					<bf:Identifier>
						<rdf:value>
							<xsl:value-of select="dc:relation"/>
						</rdf:value>
					</bf:Identifier>
				</bf:identifiedBy>
			</xsl:if>

			<!-- date -->
			<xsl:if test="normalize-space(dc:date)">
				<bf:provisionActivity>
					<bf:ProvisionActivity>
						<bf:date>
							<xsl:value-of select="dc:date"/>
						</bf:date>
					</bf:ProvisionActivity>
				</bf:provisionActivity>
			</xsl:if>

			<!-- publication place -->
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

			<!-- access policy -->
			<xsl:if test="normalize-space(dc:open_access) != 'FAŁSZ' and normalize-space(dc:open_access) != ''">
				<bflc:accessPolicy>
					<rdfs:label>
						<xsl:value-of select="dc:open_access"/>
					</rdfs:label>
				</bflc:accessPolicy>
			</xsl:if>

			<!-- note -->
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

			<!-- subject -->
			<xsl:for-each select="dc:subject">
				<xsl:if test="normalize-space(.)">
					<bf:subject>
						<bf:Topic>
							<rdfs:label>
								<xsl:value-of select="normalize-space(.)"/>
							</rdfs:label>
						</bf:Topic>
					</bf:subject>
				</xsl:if>
			</xsl:for-each>

			<!-- journal relation -->
			<xsl:if test="normalize-space(dc:source)">
				<bf:relation>
					<bf:Relation>
						<bf:relationship rdf:resource="http://id.loc.gov/vocabulary/relationship/partof"/>
						<bf:associatedResource>
							<bf:Work rdf:about="http://example.org/journal-{dc:source}">
								<bf:title>
									<bf:Title>
										<bf:mainTitle>
											<xsl:value-of select="dc:source"/>
										</bf:mainTitle>
									</bf:Title>
								</bf:title>

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

										<bf:part>
											<xsl:choose>
												<xsl:when test="normalize-space(dc:volume) or normalize-space(dc:issue) or normalize-space(dc:pages)">
													<xsl:if test="normalize-space(dc:volume)">
														<xsl:text>Vol. </xsl:text>
														<xsl:value-of select="normalize-space(dc:volume)"/>
													</xsl:if>
													<xsl:if test="normalize-space(dc:issue)">
														<xsl:if test="normalize-space(dc:volume)">
															<xsl:text>, </xsl:text>
														</xsl:if>
														<xsl:text>Issue </xsl:text>
														<xsl:value-of select="normalize-space(dc:issue)"/>
													</xsl:if>
													<xsl:if test="normalize-space(dc:pages)">
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
