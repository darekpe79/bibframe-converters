# BIBFRAME Converters

Zestaw narzędzi do konwersji metadanych (MARC, Dublin Core) na format BIBFRAME przy użyciu XSLT (w tym oficjalnych styli Library of Congress).

## Struktura katalogów

- **`scripts/`**  
  - `marc_to_bibframe.py` – kod w Pythonie do konwersji MARC → MARCXML (przy pomocy [pymarc](https://github.com/edsu/pymarc)) oraz MARCXML → BIBFRAME (wykorzystuje XSLT LoC).
  - `dc_to_bibframe.py` – kod w Pythonie do konwersji metadanych z Pandas DataFrame → Dublin Core XML, a następnie DC XML → BIBFRAME (za pomocą własnego XSLT `DC_to_bibframe.xsl`).
  - `DF_to_Marc21.py` – Data Frame to marc21- faza wstępna
  
- **`xsl/`**  
  - `marc2bibframe2.xsl` oraz inne pliki w stylu `ConvSpec-...xsl` – oficjalne arkusze XSLT używane przez Library of Congress do przetwarzania MARCXML na BIBFRAME.  
  - `DC_to_bibframe.xsl` – własny arkusz XSLT do przekształcania Dublin Core XML w BIBFRAME RDF/XML.

- **`map_config/`**  
  - `mapowanie_DC_Bib.json` – plik JSON definiujący mapowanie kolumn DataFrame → elementy DC (np. `"title": "dc:title", "link": "dc:relation"`).

- **`data/`**  
  - Przykładowe pliki z danymi, np. `es_articles__08-02-2024.mrc`, `dublin_core_example.xml`, `output_bibframe.rdf` (rezultat konwersji), itp.

## Instalacja

1. **Pobierz repozytorium** (np. klonując je z GitHuba):
   ```bash
   git clone https://github.com/TwojUzytkownik/bibframe-converters.git
   cd bibframe-converters

    Zainstaluj wymagane pakiety:
        Python 3.9+ (lub nowszy)
        pymarc
        lxml
        pandas



Użycie
1. Konwersja MARC → MARCXML → BIBFRAME

Skrypt: scripts/marc_to_bibframe.py

    MARC → MARCXML
        Funkcja convert_marc_to_marcxml(input_file, output_file)
        Wykorzystuje pymarc.

    MARCXML → BIBFRAME
        Funkcja marcxml_to_bibframe(input_marcxml, xslt_main, output_bibframe, baseuri, idsource)
        Wykorzystuje XSLT marc2bibframe2.xsl (oraz ewentualnie inne pliki w xsl/), parametry baseuri i idsource można ustawiać dowolnie.

Przykład uruchomienia (w konsoli Python lub jako skrypt):

python scripts/marc_to_bibframe.py

Zobacz w pliku marc_to_bibframe.py sekcję if __name__ == "__main__": dla przykładowych ścieżek do plików.
2. Konwersja DataFrame (DC) → BIBFRAME

Skrypt: scripts/dc_to_bibframe.py

    Pandas DataFrame → Dublin Core XML
        Funkcja df_to_dublin_core_json(df, mapping_file, output_xml)
        Wczytuje plik JSON z mapowaniem (np. mapowanie_DC_Bib.json) i generuje dublin_core_example.xml.

    DC XML → BIBFRAME
        Funkcja transform_to_bibframe(input_xml, xslt_file, output_rdf)
        Wykorzystuje DC_to_bibframe.xsl do przetworzenia DC → BIBFRAME RDF/XML.

Przykład:

python scripts/dc_to_bibframe.py

Zobacz w pliku dc_to_bibframe.py sekcję if __name__ == "__main__": – tam znajdziesz przykładowe dane w Pythonie (DataFrame) oraz wskazane ścieżki do mapowanie_DC_Bib.json, DC_to_bibframe.xsl, pliku wyjściowego .rdf itp.
Ważne uwagi

    W plikach Python używamy relatywnych ścieżek z os.path.join(os.getcwd(), 'data', ...). Upewnij się, że uruchamiasz skrypty z poziomu katalogu repo lub dostosuj ścieżki.
    Jeśli potrzebujesz przechowywać bardzo duże pliki (powyżej 100 MB) w tym repo, rozważ Git LFS.
    Zobacz https://www.loc.gov/bibframe/ i https://github.com/lcnetdev/marc2bibframe2 dla informacji o oficjalnych narzędziach do konwersji MARC21 na BIBFRAME.

Kontakt i licencja

    Autor: darek .
    W razie pytań: proszę zgłaszać Issues w repozytorium GitHub.

Dzięki za korzystanie z BIBFRAME Converters! Zachęcam do forka, testowania i zgłaszania uwag/poprawek.