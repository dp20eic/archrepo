#!/bin/bash

# Pfad zur Repository-Datenbank
DB_FILE="archrepo.db.tar.gz"
# Name der Ausgabedatei
OUTPUT_FILE="package_list.txt"

echo "Generating package list from $DB_FILE..." >&2

# Überprüfen, ob die Datenbank existiert
if [ ! -f "$DB_FILE" ]; then
  echo "Error: Database file <span class="math-inline">DB\_FILE not found\!" \>&2
exit 1
fi
# Entpacken der Datenbank und Extrahieren der Paketnamen
# pacman -Sl kann die Datenbank direkt lesen.
# Wir filtern nach unserem Repo-Namen und extrahieren nur den Paketnamen.
pacman -Sl "(basename "$DB_FILE" .db.tar.gz)" -r . | awk '{print $2}' | sort > "$OUTPUT_FILE"

echo "Package list generated successfully: $OUTPUT_FILE" >&2
```
  * **Hinweis zu `pacman -Sl "$(basename "$DB_FILE" .db.tar.gz)" -r .`**:
      * `pacman -Sl <repo_name>` listet Pakete eines Repos auf.
      * `$(basename "$DB_FILE" .db.tar.gz)` extrahiert den Repo-Namen (`archrepo`) aus dem Datenbank-Dateinamen.
      * `-r .` sagt Pacman, es soll die Datenbank im aktuellen Verzeichnis (`.`) suchen, was wichtig ist, da das Skript später im `packages/` Ordner ausgeführt wird.
