import json
import pandas as pd
from pymarc import Record, Field
import os
def add_subfields_or_merge(record, tag, indicators, subf_list):
    """
    Dokłada subfieldy z 'subf_list' (np. ['t','Journal Title','g','32'])
    do pola o danym 'tag' i 'indicators', jeśli ono istnieje w 'record'.
    Jeśli nie istnieje, tworzy nowe pole i dodaje subfieldy.

    Używa Field.add_subfield(code, value), co pozwala
    uniknąć usuwania i ponownego dodawania pola.
    """
    existing_field = None
    for f in record.get_fields(tag):
        if f.indicators == indicators:
            existing_field = f
            break

    if existing_field:
        # Doklejamy subfieldy do istniejącego pola
        for i in range(0, len(subf_list), 2):
            code = subf_list[i]
            val = subf_list[i+1]
            existing_field.add_subfield(code, val)
    else:
        # Tworzymy nowe pole i dodajemy subfieldy
        new_field = Field(tag=tag, indicators=indicators)
        for i in range(0, len(subf_list), 2):
            code = subf_list[i]
            val = subf_list[i+1]
            new_field.add_subfield(code, val)
        record.add_field(new_field)


def df_to_marc_advanced_merge(df, mapping_file, output_marc):
    """
    Konwertuje DataFrame -> plik MARC21 (.mrc) 
    z zaawansowanym mapowaniem w JSON + łączeniem subfieldów w tym samym polu.
    """

    # 1) Wczytujemy mapowanie
    with open(mapping_file, 'r', encoding='utf-8') as f:
        mapping = json.load(f)

    # 2) Otwieramy plik wynikowy
    with open(output_marc, 'wb') as fh:

        # 3) Iteracja po wierszach DataFrame
        for _, row in df.iterrows():
            record = Record(force_utf8=True)

            # 4) Iteracja po elementach mapowania
            # (klucz=kolumna w DF, wartość=definicja {tag, indicators, repeated, subfields})
            for col, map_info in mapping.items():
                # sprawdzamy czy ta kolumna istnieje w DF
                if col not in df.columns:
                    continue

                val = row[col]
                if pd.isna(val) or str(val).strip() == '':
                    continue

                tag = map_info["tag"]
                indicators = map_info.get("indicators", [" ", " "])
                repeated = map_info.get("repeated", False)
                subfields_info = map_info.get("subfields", None)

                # Obsługa wielokrotnych wartości
                if repeated:
                    # jeśli to string z przecinkami
                    if isinstance(val, str) and ',' in val:
                        all_values = [v.strip() for v in val.split(',')]
                    elif isinstance(val, list):
                        all_values = val
                    else:
                        all_values = [val]
                else:
                    all_values = [val]

                for single_val in all_values:
                    single_val_str = str(single_val).strip()
                    if not single_val_str:
                        continue

                    # Pola kontrolne 00X bez subfields
                    if tag.startswith('00') and not subfields_info:
                        # Tworzymy pole kontrolne
                        field = Field(tag=tag, data=single_val_str)
                        record.add_field(field)
                    else:
                        # Zwykłe pole, być może z subpolami
                        if not subfields_info:
                            # Domyślnie 1 subfield 'a'
                            subf_list = ['a', single_val_str]
                            add_subfields_or_merge(record, tag, indicators, subf_list)
                        else:
                            # Mamy definicję subfields
                            subf_list = []
                            for sf_def in subfields_info:
                                code = sf_def["code"]
                                sc = sf_def.get("sourceCol", "currentColumn")

                                if sc == "currentColumn":
                                    sub_val = single_val_str
                                else:
                                    # pobieramy z innej kolumny DF
                                    if sc in df.columns:
                                        sub_val = str(row[sc]).strip()
                                    else:
                                        sub_val = single_val_str

                                if sub_val:
                                    subf_list.append(code)
                                    subf_list.append(sub_val)

                            if subf_list:
                                add_subfields_or_merge(record, tag, indicators, subf_list)

            # Zapis rekordu do pliku
            fh.write(record.as_marc())

    print(f"Zapisano plik MARC: {output_marc}")


# ---------------- PRZYKŁADOWE UŻYCIE ----------------
if __name__ == "__main__":

    # Przykładowy DataFrame (możesz wczytać read_excel lub read_csv)
    df = pd.DataFrame({
        "identifier": ["1_1_1867_Wislicki_Groch"],
        "journal_title": ["Programy i dyskusje literackie pozytywizmu"],
        "source_number": ["32"],
        "subjects": [["Dramat polski", "Pozytywizm", "Groch"]],
        "genre": ["Comedy,Farce"],
        "type": ["chapter"],
        "link": ["https://drive.google.com/..."]
    })

    script_dir = os.getcwd()
    mapping_file = os.path.join(script_dir, 'map_config', 'mapping_marc.json')
    output_marc = "output_advanced.mrc"

    df_to_marc_advanced_merge(df, mapping_file, output_marc)
    print("Done.")
