#!/bin/bash

# Pfad zur Repository-Datenbank
DB_FILE="archrepo.db.tar.gz"
# Name der Ausgabedatei
OUTPUT_FILE="package_list.txt"

echo "Generating package list from $DB_FILE..." >&2

# Überprüfen, ob die Datenbank existiert
if [ ! -f "$DB_FILE" ]; then
  echo "Error: Database file $DB_FILE not found!" >&2
  exit 1
fi

# Entpacken der Datenbank und Extrahieren der Paketnamen
# pacman -Sl kann die Datenbank direkt lesen.
# Wir filtern nach unserem Repo-Namen und extrahieren nur den Paketnamen.
# Hier wurde das fehlende '$' vor der Klammer '(' hinzugefügt!
pacman -Sl "$(basename "$DB_FILE" .db.tar.gz)" -r . | awk '{print $2}' | sort > "$OUTPUT_FILE"

echo "Package list generated successfully: $OUTPUT_FILE" >&2

