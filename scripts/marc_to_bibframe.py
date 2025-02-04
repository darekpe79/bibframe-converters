# -*- coding: utf-8 -*-
"""
Created on Thu Jan 16 10:18:30 2025

@author: darek
"""

# scripts/marc_to_bibframe.py
import os
from pymarc import MARCReader, XMLWriter
from lxml import etree

def convert_marc_to_marcxml(input_file, output_file):
    """
    Converts a MARC file (.mrc or .mrk) to MARCXML format.
    """
    try:
        with open(input_file, 'rb') as marc_file, open(output_file, 'wb') as xml_file:
            reader = MARCReader(marc_file)
            writer = XMLWriter(xml_file)
            for record in reader:
                writer.write(record)
            writer.close()
            print(f"Conversion complete. MARCXML saved to {output_file}.")
    except Exception as e:
        print(f"Error during conversion: {e}")


def marcxml_to_bibframe(input_marcxml, xslt_main, output_bibframe, baseuri=None, idsource=None):
    """
    Converts MARCXML to BIBFRAME using LoC's XSLT (marc2bibframe2.xsl).
    Possibly references multiple .xsl files in the same dir.
    """
    try:
        # Wczytanie MARCXML
        xml_tree = etree.parse(input_marcxml)
        # Wczytanie głównego pliku XSL
        xslt_tree = etree.parse(xslt_main)
        transform = etree.XSLT(xslt_tree)

        # Parametry do transformacji
        params = {}
        if baseuri:
            params['baseuri'] = f"'{baseuri}'"
        if idsource:
            params['idsource'] = f"'{idsource}'"

        # Wykonanie transformacji
        result_tree = transform(xml_tree, **params)

        # Zapis wyniku
        with open(output_bibframe, 'wb') as output_file:
            output_file.write(etree.tostring(result_tree, 
                                             pretty_print=True, 
                                             xml_declaration=True, 
                                             encoding='UTF-8'))
        print(f"Conversion complete. Output saved to {output_bibframe}.")
    except Exception as e:
        print(f"Error: {e}")


if __name__ == "__main__":
    import sys
    
    # Przykładowe użycie
    # 1) Konwersja MARC -> MARCXML
    #script_dir = os.path.dirname(__file__)   # ścieżka do folderu z tym skryptem
    script_dir = os.getcwd()
    print("Current directory:", script_dir)
    input_marc_file = os.path.join(script_dir, 'data', 'es_articles__08-02-2024.mrc')
    output_marcxml_file = os.path.join(script_dir, 'data', 'sample_marcxml.xml')
    convert_marc_to_marcxml(input_marc_file, output_marcxml_file)

    # 2) Konwersja MARCXML -> BIBFRAME
    xslt_main = os.path.join(script_dir, 'xsl', 'marc2bibframe2.xsl')
    output_bibframe_file = os.path.join(script_dir, 'data', 'bibframe_output.xml')
    marcxml_to_bibframe(output_marcxml_file, xslt_main, output_bibframe_file,
                        baseuri='http://mylibrary.org/',
                        idsource='http://id.loc.gov/vocabulary/organizations/dlc')