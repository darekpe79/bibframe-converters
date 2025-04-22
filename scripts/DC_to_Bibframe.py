
    
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
    Obsługuje też pola wielokrotne: np. wielu autorów (creator).
    """
    import json
    from lxml import etree

    # Pola, które mogą mieć wiele wartości
    MULTI_VALUED_FIELDS = {"creator", "contributor", "subject", "relation"}

    # 1) Wczytujemy mapowanie
    with open(mapping_file, 'r', encoding='utf-8') as f:
        mapping = json.load(f)

    # 2) Namespace
    nsmap = {"dc": "http://purl.org/dc/elements/1.1/"}
    root = etree.Element("articles", nsmap=nsmap)

    # 3) Iteracja po wierszach DF
    for _, row in df.iterrows():
        article = etree.SubElement(root, "article")

        for col in df.columns:
            value = row[col]

            if pd.notna(value) and str(value).strip() and col in mapping:
                dc_field = mapping[col]
                prefix, localname = dc_field.split(":")

                # Obsługa pól wielokrotnych — rozdzielone przecinkiem lub średnikiem
                if col in MULTI_VALUED_FIELDS:
                    # Dzielimy np. "Anna Nowak; Jan Kowalski"
                    for item in str(value).replace(";", ",").split(","):
                        clean = item.strip()
                        if clean:
                            etree.SubElement(article, "{http://purl.org/dc/elements/1.1/}" + localname).text = clean
                else:
                    etree.SubElement(article, "{http://purl.org/dc/elements/1.1/}" + localname).text = str(value)

    # 4) Zapis
    tree = etree.ElementTree(root)
    tree.write(output_xml, pretty_print=True, xml_declaration=True, encoding="UTF-8")
    print(f"Dublin Core XML saved to {output_xml}")


def transform_to_bibframe(input_xml, xslt_file, output_rdf):
    """
    Transformuje DC XML na BIBFRAME RDF za pomocą pliku XSLT.
    """
    dom = etree.parse(input_xml)  # wczytujemy plik DC
    print("=== DC INPUT XML ===")
    print(etree.tostring(dom, pretty_print=True, encoding="unicode"))
    
    xslt_tree = etree.parse(xslt_file)  # wczytujemy plik XSLT
    print("=== XSLT ===")
    print(etree.tostring(xslt_tree, pretty_print=True, encoding="unicode"))
    
    transform = etree.XSLT(xslt_tree)  # tworzymy obiekt transformacji
    
    bibframe = transform(dom)  # wykonujemy transformację
    
    print("=== WYNIK TRANSFORMACJI ===")
    print(etree.tostring(bibframe, pretty_print=True, encoding="unicode"))

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
        "identifier": [
            "1_1_1867_Wislicki_Groch",
            "1_1_1867_Wislicki_Groch_2"
        ],
        "link": [
            "https://drive.google.com/file/d/1QlZE1BY3S8EkMBV9VtxNiuSljzdvXQ8B",
            "https://drive.google.com/file/d/1QlZE1BY3S8EkMBV9VtxNiuSljzdvXQ8B"
        ],
        "type": ["chapter", "article"],
        "title": [
            "Groch na ścianę. Parę słów do całej plejady zapoznanych wieszczów naszych",
            "Groch na ścianę. Parę słów do całej plejady zapoznanych wieszczów naszych"
        ],
        "creator": ["Adam Wyślicki", "Adam Wyślicki"],
        "author_gender": ["mężczyzna", "mężczyzna"],
        "journal_title": [
            "Programy i dyskusje literackie pozytywizmu",
            "Programy i dyskusje literackie pozytywizmu"
        ],
        "journal_issn": ["1234-5678", "1234-5678"],  # <-- NOWE POLE!
        "source_number": ["32", "32"],
        "source_place": ["", ""],
        "source_date": ["1867", "2090"],
        "date": ["1867", "2090"],
        "publication_place": ["", ""],
        "pages": ["44638", ""],
        "open_access": ["FAŁSZ", ""]
    }

    data = {
        "identifier": [
            "2_1_1878_Kowalski_Artykul",
            "2_2_1880_Nowak_Esej",
            "2_3_1890_Wislicki_Szkic"
        ],
        "link": [
            "https://example.com/doc1.pdf",
            "https://example.com/doc2.pdf",
            "https://example.com/doc3.pdf"
        ],
        "type": ["article", "essay", "chapter"],
        "title": [
            "Wpływ pozytywizmu na literaturę",
            "Dlaczego realizm jest ważny",
            "O trudnych losach poezji"
        ],
        "creator": [
            "Jan Kowalski; Maria Skłodowska",
            "Anna Nowak",
            "Adam Wyślicki, Jan Kowalski"
        ],
        "author_gender": [
            "mężczyzna; kobieta",
            "kobieta",
            "mężczyzna, mężczyzna"
        ],
        "journal_title": [
            "Rocznik Literatury Polskiej",
            "Rocznik Literatury Polskiej",
            "Kwartalnik Humanistyczny"
        ],
        "journal_issn": ["2222-3333", "2222-3333", "4444-5555"],
        "source_number": ["1", "2", "5"],
        "source_place": ["Warszawa", "Warszawa", "Kraków"],
        "source_date": ["1878", "1880", "1890"],
        "date": ["1878", "1880", "1890"],
        "publication_place": ["Warszawa", "Warszawa", "Kraków"],
        "pages": ["101-110", "210-220", "305-312"],
        "open_access": ["PRAWDA", "FAŁSZ", "PRAWDA"]
    }

    df = pd.DataFrame(data)
    data = {
    "identifier": ["3_1_1900_Nowak_Sklodowska_Artykul"],
    "title": ["Współautorstwo w literaturze"],
    "creator": ["Anna Nowak; Maria Skłodowska"],
    "journal_title": ["Zeszyty Literackie"],
    "journal_issn": ["6666-7777"],
    "source_number": ["10"],
    "date": ["1900"]
}
    df = pd.DataFrame(data)

    # Ścieżki relatywne
    mapping_file = os.path.join(script_dir, 'map_config', 'mapowanie_DC_Bib.json')
    input_xml = os.path.join(script_dir, 'data', 'dublin_core_example.xml')
    xslt_file = os.path.join(script_dir, 'xsl', 'DC_to_bibframe2.xsl')
    output_rdf = os.path.join(script_dir, 'data', 'output_bibframe.rdf')

    # 1) Wygenerowanie pliku DC XML
    df_to_dublin_core_json(df, mapping_file, input_xml)

    # 2) Transformacja do BIBFRAME
    transform_to_bibframe(input_xml, xslt_file, output_rdf)


