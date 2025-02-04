
    
# -*- coding: utf-8 -*-
"""
Created on Tue Feb  4 12:54:52 2025

@author: darek
"""

import os
import pandas as pd
import json
from lxml import etree

def df_to_dublin_core_json(df, mapping_file, output_xml):
    """
    Z DataFrame tworzony jest XML Dublin Core
    wykorzystując mapowanie z pliku JSON.
    """
    # 1) Wczytujemy mapowanie
    with open(mapping_file, 'r', encoding='utf-8') as f:
        mapping = json.load(f)

    # 2) Tworzymy główny element <articles> z namespace DC
    nsmap = {"dc": "http://purl.org/dc/elements/1.1/"}
    root = etree.Element("articles", nsmap=nsmap)

    # 3) Iterujemy po każdym wierszu DataFrame
    for _, row in df.iterrows():
        article = etree.SubElement(root, "article")

        # 4) Sprawdzamy wszystkie kolumny DF
        for col in df.columns:
            value = row[col]
            # pomijamy None, NaN, puste stringi
            if pd.notna(value) and str(value).strip():
                # sprawdzamy, czy jest w mapowaniu
                if col in mapping:
                    # np. "dc:creator"
                    dc_field = mapping[col]  
                    prefix, localname = dc_field.split(":")
                    etree.SubElement(article, "{http://purl.org/dc/elements/1.1/}" + localname).text = str(value)

    # 5) Zapis do XML
    tree = etree.ElementTree(root)
    tree.write(output_xml, pretty_print=True, xml_declaration=True, encoding="UTF-8")
    print(f"Dublin Core XML saved to {output_xml}")


def transform_to_bibframe(input_xml, xslt_file, output_rdf):
    """
    Transformuje DC XML na BIBFRAME RDF za pomocą pliku XSLT.
    """
    dom = etree.parse(input_xml)       # wczytujemy plik DC
    xslt = etree.parse(xslt_file)      # wczytujemy plik XSLT
    transform = etree.XSLT(xslt)       # tworzymy obiekt transformacji

    bibframe = transform(dom)          # wykonujemy transformację

    with open(output_rdf, "wb") as f:
        f.write(etree.tostring(bibframe, pretty_print=True, 
                               xml_declaration=True, encoding="UTF-8"))
    print(f"BIBFRAME RDF saved to {output_rdf}")


# ============ PRZYKŁADOWE UŻYCIE ============
if __name__ == "__main__":
    # Jeśli uruchamiasz z pliku .py w konsoli, możesz zrobić:
    # script_dir = os.path.dirname(__file__)

    # Jeśli jesteś w Jupyter / Interaktywnie, __file__ nie istnieje, użyj os.getcwd():
    script_dir = os.getcwd()
    print("Current directory:", script_dir)

    # Przykładowy DataFrame
    data = {
        "identifier": ["1_1_1867_Wislicki_Groch"],
        "link": ["https://drive.google.com/file/d/1QlZE1BY3S8EkMBV9VtxNiuSljzdvXQ8B"],
        "type": ["chapter"],
        "title": ["Groch na ścianę. Parę słów do całej plejady zapoznanych wieszczów naszych"],
        "creator": ["Adam Wyślicki"],
        "author_gender": ["mężczyzna"],
        "journal_title": ["Programy i dyskusje literackie pozytywizmu"],
        "source_number": ["32"],
        "source_place": [""],
        "source_date": [""],
        "date": ["1867"],
        "publication_place": [""],
        "pages": ["44638"],
        "open_access": ["FAŁSZ"]
    }
    df = pd.DataFrame(data)

    # Ścieżki relatywne
    mapping_file = os.path.join(script_dir, 'map_config', 'mapowanie_DC_Bib.json')
    input_xml = os.path.join(script_dir, 'data', 'dublin_core_example.xml')
    xslt_file = os.path.join(script_dir, 'xsl', 'DC_to_bibframe.xsl')
    output_rdf = os.path.join(script_dir, 'data', 'output_bibframe.rdf')

    # 1) Wygenerowanie pliku DC XML
    df_to_dublin_core_json(df, mapping_file, input_xml)

    # 2) Transformacja do BIBFRAME
    transform_to_bibframe(input_xml, xslt_file, output_rdf)


