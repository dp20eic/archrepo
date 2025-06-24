-----

# EMQX Broker (Open Source) AUR Paket Dokumentation und Bereitstellung

Dieses Dokument beschreibt den vollständigen Prozess zum Paketieren und Bereitstellen von EMQX Broker (Open Source Edition) für Arch Linux. Es nutzt das offizielle Debian-Binary und hostet das resultierende Pacman-Paket in einem privaten Repository auf GitHub Pages. Dies ist eine effiziente Methode, um EMQX in Umgebungen wie Proxmox LXCs zu nutzen, ohne es selbst kompilieren zu müssen.

**Repository:** [https://github.com/dp20eic/archrepo](https://www.google.com/url?sa=E&source=gmail&q=https://github.com/dp20eic/archrepo)

## Inhaltsverzeichnis

1.  [Übersicht und Vorteile](https://www.google.com/search?q=%231-%C3%BCbersicht-und-vorteile)
2.  [Projektstruktur](https://www.google.com/search?q=%232-projektstruktur)
3.  [Das `PKGBUILD` – Die Paketbeschreibung](https://www.google.com/search?q=%233-das-pkgbuild--die-paketbeschreibung)
4.  [`emqx-broker-debian.install` – Post-Installations-Skript](https://www.google.com/search?q=%234-emqx-broker-debianinstall--post-installations-skript)
5.  [Vorbereitung: Installation und Paketbau](https://www.google.com/search?q=%235-vorbereitung-installation-und-paketbau)
6.  [Eigenes Pacman-Repository auf GitHub Pages](https://www.google.com/search?q=%236-eigenes-pacman-repository-auf-github-pages)
7.  [Pacman im Proxmox LXC konfigurieren](https://www.google.com/search?q=%237-pacman-im-proxmox-lxc-konfigurieren)
8.  [EMQX-Konfiguration und Cluster-Bildung](https://www.google.com/search?q=%238-emqx-konfiguration-und-cluster-bildung)
9.  [Monitoring mit Uptime Kuma und WebHooks](https://www.google.com/search?q=%239-monitoring-mit-uptime-kuma-und-webhooks)
10. [Automatisierte Paketliste mit GitHub Actions](https://www.google.com/search?q=%2310-automatisierte-paketliste-mit-github-actions)

-----

## 1\. Übersicht und Vorteile

  * **Paketname:** `emqx-broker-debian`
  * **Zweck:** Bereitstellung von EMQX Broker (Open Source Edition) auf Arch Linux mittels des offiziellen Debian-Binaries.
  * **Architektur:** `x86_64` (Anpassbar für `aarch64`).
  * **Vorteile:**
      * Umgeht Kompilierungsprobleme.
      * Nutzt stabile, vom EMQX-Team getestete Binaries.
      * Ermöglicht zentrale und einfache Bereitstellung über ein eigenes Pacman-Repository.
      * Unterstützt **Clustering ohne Lizenzbeschränkungen** für Standard-Funktionen.
      * Integration mit Systemd für einfache Verwaltung.
      * Konfiguration erfolgt gemäß Arch Linux Dateisystem-Hierarchie (FHS).

-----

## 2\. Projektstruktur

Dein lokales und das GitHub-Repository (`archrepo`) sollte die folgende Struktur aufweisen:

```
archrepo/
├── .github/              # GitHub Actions Workflows
│   └── workflows/
│       └── generate-package-list.yml
├── emqx-broker-debian/   # Ordner für das EMQX-Paket (PKGBUILD, etc.)
│   ├── PKGBUILD
│   └── emqx-broker-debian.install
├── packages/             # Ordner für das Pacman-Repository (Pakete und DB-Dateien)
│   ├── emqx-broker-debian-5.8.6-1-x86_64.pkg.tar.zst
│   ├── archrepo.db.tar.gz
│   ├── archrepo.files.tar.gz
│   └── package_list.txt  # Automatisch generierte Paketliste
└── README.md             # Dieses Dokument (falls im Root abgelegt)
```

-----

## 3\. Das `PKGBUILD` – Die Paketbeschreibung

Die `PKGBUILD` ist die Anleitung für `makepkg`, wie das EMQX-Paket gebaut wird.
Lege diese Datei im Ordner `emqx-broker-debian/` ab.

```makepkg
# Maintainer: Dein Name <deine@email.com>
pkgname=emqx-broker-debian
pkgver=5.8.6 # Die Version des Open Source Brokers
_deb_version=5.8.6 # Version des zugrunde liegenden Debian-Pakets
pkgrel=1
pkgdesc="A highly scalable, reliable, and performant MQTT broker (Open Source Edition) based on the official Debian package."
arch=('x86_64')
url="https://www.emqx.io/"
license=('Apache')
depends=('glibc' 'erlang')
provides=("emqx=${pkgver}" "emqx-broker=${pkgver}")
conflicts=("emqx" "emqx-enterprise" "emqx-git")
install=${pkgname}.install

# Source-URL des Debian-Pakets für EMQX Broker
source=("emqx-${_deb_version}-debian12-amd64.deb::https://www.emqx.com/en/downloads/broker/v${_deb_version}/emqx-broker-${_deb_version}-debian12-amd64.deb")

# SHA256-Checksumme des Debian-Pakets
# WICHTIG: Ersetze 'HIER_DIE_TATSÄCHLICHE_CHECKSUMME_EINFÜGEN' durch die korrekte Checksumme der .deb-Datei!
# Für 5.8.6:
sha256sums=('442e946a5b67b14d2325c270a41f6236b3f7f07e59b34a622a55928d2d6c6984')

noextract=("emqx-${_deb_version}-debian12-amd64.deb")

package() {
    # Vollständiges Debian-Paket in ein temporäres Verzeichnis entpacken, um an data.tar.xz zu kommen.
    mkdir -p "${srcdir}/deb_root"
    bsdtar -xf "${srcdir}/emqx-${_deb_version}-debian12-amd64.deb" -C "${srcdir}/deb_root"

    # Jetzt entpacken wir den gesamten Inhalt von data.tar.xz in das pkgdir.
    # Hierbei werden die EMQX-Binaries und Bibliotheken in ${pkgdir}/usr/lib/emqx/ abgelegt.
    # Die Konfigurationsdateien werden *innerhalb* von data.tar.xz unter ./etc/emqx/ abgelegt.
    bsdtar --exclude=./var/run --exclude=./var/lock -xf "${srcdir}/deb_root/data.tar.xz" -C "${pkgdir}"

    # Verschieben der Konfigurationsdateien:
    # Die Konfigurationsdateien liegen nach dem Entpacken von data.tar.xz unter ${pkgdir}/etc/emqx/
    # Dieses Verzeichnis ist der korrekte Zielort gemäß FHS, daher ist hier kein 'mv' nötig,
    # sondern nur eine Überprüfung der Existenz.
    if [[ -d "${pkgdir}/etc/emqx" ]]; then
        echo "EMQX configuration found at ${pkgdir}/etc/emqx."
    else
        echo "ERROR: EMQX configuration directory ${pkgdir}/etc/emqx not found after extracting data.tar.xz. Configuration might be missing."
        exit 1 # Fehler abbrechen, wenn Konfiguration nicht gefunden wird.
    fi

    # Temporäre Verzeichnisse bereinigen
    rm -rf "${srcdir}/deb_root"

    # Arch Linux spezifische Anpassungen

    # Systemd Service-Datei an Arch-Konvention anpassen
    # Verschiebt emqx.service von /lib/systemd/system nach /usr/lib/systemd/system
    if [[ -f "${pkgdir}/lib/systemd/system/emqx.service" ]]; then
        install -d "${pkgdir}/usr/lib/systemd/system"
        mv "${pkgdir}/lib/systemd/system/emqx.service" "${pkgdir}/usr/lib/systemd/system/emqx.service"
        # Leere Verzeichnisse aufräumen
        rmdir "${pkgdir}/lib/systemd/system" 2>/dev/null || true
        rmdir "${pkgdir}/lib/systemd" 2>/dev/null || true
        rmdir "${pkgdir}/lib" 2>/dev/null || true
    fi

    # Hier die entscheidende Anpassung:
    # Das Systemd-Unit-File anpassen, damit es die Konfigurationsdateien in /etc/emqx/ sucht.
    # Die Environment-Variable EMQX_HOME sollte auf /usr/lib/emqx gesetzt sein.
    # Die Environment-Variable EMQX_NODE__CONF sollte auf /etc/emqx gesetzt sein.
    sed -i \
        -e 's|Environment=EMQX_HOME=.*|Environment=EMQX_HOME=/usr/lib/emqx|g' \
        -e 's|Environment=EMQX_NODE__CONF=.*|Environment=EMQX_NODE__CONF=/etc/emqx|g' \
        "${pkgdir}/usr/lib/systemd/system/emqx.service"

    # Lizenzdatei kopieren
    if [[ -d "${pkgdir}/usr/share/doc/emqx" ]]; then
        install -d "${pkgdir}/usr/share/licenses/${pkgname}"
        cp -a "${pkgdir}/usr/share/doc/emqx/copyright" "${pkgdir}/usr/share/licenses/${pkgname}/"
    fi

    # Symlink für Binaries
    local real_emqx_binary_path="/usr/lib/emqx/bin/emqx"
    local symlink_location_in_pkgdir="${pkgdir}/usr/bin/emqx"

    if [[ -f "${pkgdir}/usr/lib/emqx/bin/emqx" ]]; then
        install -d "$(dirname "${symlink_location_in_pkgdir}")"
        ln -sf "${real_emqx_binary_path}" "${symlink_location_in_pkgdir}"
    else
        echo "WARNING: EMQX binary not found at ${pkgdir}/usr/lib/emqx/bin/emqx. Symlink to /usr/bin/emqx will not be created."
    fi
}
```

-----

## 4\. `emqx-broker-debian.install` – Post-Installations-Skript

Dieses Skript kümmert sich um Systembenutzer, Gruppen und Dateiberechtigungen.
Lege diese Datei im Ordner `emqx-broker-debian/` ab.

```bash
post_install() {
  echo ">>> Adding system user 'emqx' and group 'emqx' if they don't exist..."
  getent group emqx >/dev/null || groupadd -r emqx
  getent passwd emqx >/dev/null || useradd -r -g emqx -d /usr/lib/emqx -s /bin/false -c "EMQX Broker User" emqx

  echo ">>> Setting ownership for EMQX directories..."
  chown -R emqx:emqx /usr/lib/emqx || true
  mkdir -p /var/lib/emqx /var/log/emqx
  chown -R emqx:emqx /var/lib/emqx || true
  chown -R emqx:emqx /var/log/emqx || true

  chown -R emqx:emqx /etc/emqx || true
  chmod -R 755 /etc/emqx || true

  systemctl daemon-reload >/dev/null 2>&1 || true
}

post_upgrade() {
  post_install
}

post_remove() {
  echo ">>> Removing system user 'emqx' and group 'emqx' if they exist and are not in use..."
  userdel emqx >/dev/null 2>&1 || true
  groupdel emqx >/dev/null 2>&1 || true

  echo ">>> Cleaning up EMQX configuration and data directories..."
  # WARNUNG: Dies entfernt die Konfiguration und Daten bei Deinstallation!
  # Im Produktivsystem sollte dies VOR der Deinstallation gesichert werden.
  rm -rf /etc/emqx >/dev/null 2>&1 || true
  rm -rf /var/lib/emqx >/dev/null 2>&1 || true
  rm -rf /var/log/emqx >/dev/null 2>&1 || true
}
```

-----

## 5\. Vorbereitung: Installation und Paketbau

### 5.1. Build-Umgebung einrichten

1.  **Notwendige Build-Tools installieren:**
    ```bash
    sudo pacman -S --needed base-devel devtools
    ```
2.  **Laden Sie das Debian-Paket herunter:**
      * Beziehen Sie die `emqx-5.8.6-debian12-amd64.deb` Datei von der offiziellen EMQX-Website: [https://www.emqx.com/en/downloads/broker/v5.8.6/emqx-5.8.6-debian12-amd64.deb](https://www.emqx.com/en/downloads/broker/v5.8.6/emqx-5.8.6-debian12-amd64.deb)
      * Legen Sie diese Datei im selben Verzeichnis ab wie Ihre `PKGBUILD` (z.B. `~/my-packages/emqx-broker-debian/`).

### 5.2. EMQX-Paket bauen

1.  **Navigieren Sie in das Paket-Verzeichnis:**
    ```bash
    cd ~/my-packages/emqx-broker-debian/
    ```
2.  **Führen Sie `makepkg` aus:**
    ```bash
    makepkg -s
    ```
    Dies erstellt die `.pkg.tar.zst`-Datei (z.B. `emqx-broker-debian-5.8.6-1-x86_64.pkg.tar.zst`).

-----

## 6\. Eigenes Pacman-Repository auf GitHub Pages

### 6.1. GitHub Repository erstellen (Neu und Sauber)

1.  **Neues GitHub Repository erstellen:**

      * Gehe zu [GitHub](https://github.com/) und logge dich ein.
      * Erstelle ein **neues Repository**.
      * Name: **`archrepo`** (einfach, ohne Sonderzeichen oder Unterstriche).
      * Setze es auf **"Public"**.
      * **Wichtig:** **NICHT mit README, .gitignore oder Lizenz initialisieren.**

2.  **Lokal klonen:**

      * Kopier die HTTPS-URL des neuen Repos.
      * Klonen auf deinem lokalen System (wo du Pakete baust):
        ```bash
        git clone https://github.com/dp20eic/archrepo.git
        cd archrepo
        ```

3.  **Erstelle die benötigten Ordner:**

    ```bash
    mkdir -p packages .github/workflows
    ```

### 6.2. Pakete und Datenbank hinzufügen

1.  **Kopiere das gebaute EMQX-Paket:**
    Kopier die `emqx-broker-debian-5.8.6-1-x86_64.pkg.tar.zst` Datei in den **`packages/`** Ordner deines **lokalen `archrepo` Repositorys**:

    ```bash
    cp ~/my-packages/emqx-broker-debian/emqx-broker-debian-5.8.6-1-x86_64.pkg.tar.zst ~/my-packages/archrepo/packages/
    ```

2.  **Erstelle/Aktualisiere die Repository-Datenbank:**

      * Navigiere in den **`packages/`** Ordner deines **lokalen `archrepo`**:
        ```bash
        cd ~/my-packages/archrepo/packages/
        ```
      * Führe `repo-add` aus. **Der Name `archrepo` ist entscheidend\!**
        ```bash
        repo-add archrepo.db.tar.gz emqx-broker-debian-5.8.6-1-x86_64.pkg.tar.zst
        ```
        Dies erstellt die Dateien `archrepo.db.tar.gz` und `archrepo.files.tar.gz`.

3.  **Committen und Pushen zu GitHub:**

      * Gehe zurück ins Root-Verzeichnis deines lokalen `archrepo` (`cd ..`).
      * ```bash
          git add .
          git commit -m "Initial setup of archrepo with emqx-broker-debian package"
          git push origin main
        ```
      * Bei der Authentifizierung: Gib deinen **GitHub-Benutzernamen** (`dp20eic`) und deinen **Personal Access Token** (als Passwort) ein.

### 6.3. GitHub Pages aktivieren und konfigurieren

1.  **Gehe zu den Repository-Einstellungen auf GitHub:**
    Öffne `https://github.com/dp20eic/archrepo` in deinem Browser. Klick auf **"Settings"** und dann auf **"Pages"**.

2.  **Konfiguriere die "Build and deployment" Quelle:**

      * **Branch:** Wähle **`main`** aus.
      * **Folder:** Wähle **`/packages`** aus (Dieser Ordner sollte jetzt verfügbar sein).
      * Klicke auf **"Save"**.

3.  **Warte auf die Bereitstellung:**
    GitHub Pages beginnt mit dem Build. Warte, bis der Status "Your site is published at..." angezeigt wird.

4.  **Kopiere die generierte URL:**
    Die URL sollte jetzt **`https://dp20eic.github.io/archrepo/packages/`** sein. **Diese URL ist deine Server-URL für Pacman.**

-----

## 7\. Pacman im Proxmox LXC konfigurieren

Auf jedem deiner Arch Linux LXCs:

1.  **Bearbeite die Pacman-Konfiguration** `/etc/pacman.conf`:

    ```bash
    sudo nano /etc/pacman.conf
    ```

2.  **Füge am Anfang der Datei** (direkt unter den anderen `[core]`, `[extra]` etc.) diesen neuen Repository-Eintrag hinzu:

    ```
    [archrepo] # <--- DIESER NAME MUSS MIT DEM NAME DER DB-DATEI (archrepo.db.tar.gz) ÜBEREINSTIMMEN
    SigLevel = Optional TrustAll # Für private, unsignierte Repos. Für signierte Pakete 'Required'
    Server = https://dp20eic.github.io/archrepo/packages/ # <--- DIE VON GITHUB PAGES GENERIERTE URL UND MIT / ENDEN!
    ```

3.  **Speichere und schließe die Datei.**

4.  **Aktualisiere die Paketdatenbanken:**

    ```bash
    sudo pacman -Sy
    ```

    Du solltest sehen, wie `archrepo` synchronisiert wird.

5.  **Installiere das EMQX Broker-Paket:**

    ```bash
    sudo pacman -S emqx-broker-debian
    ```

-----

## 8\. EMQX-Konfiguration und Cluster-Bildung

### 8.1. GUI für Regel-Engine aktivieren (optional)

Für eine einfachere Verwaltung der Regel-Engine über das Dashboard:

1.  **Erstelle oder bearbeite** die Datei `/etc/emqx/plugins/emqx_rule_engine.conf` auf deinem LXC:
    ```bash
    sudo nano /etc/emqx/plugins/emqx_rule_engine.conf
    ```
2.  Füge diese Zeile hinzu:
    ```hocon
    rule_engine.enable_dashboard = true
    ```
3.  **Starte EMQX neu:** `sudo systemctl restart emqx`
4.  Gehe zum EMQX Dashboard (Port 18083). Du solltest nun den Menüpunkt **"Rule Engine"** sehen.

### 8.2. EMQX Broker konfigurieren (`/etc/emqx/emqx.conf`)

Diese Einstellungen müssen auf **jedem EMQX-Node** identisch sein (bis auf `node.name`):

```erlang
## /etc/emqx/emqx.conf (auf allen Nodes)

node {
  name = "emqx@${EMQX_NODE_NAME}" # Wird automatisch auf Hostnamen gesetzt
  cookie = "DEIN_SICHERER_CLUSTER_COOKIE_HIER" # WICHTIG: MUSS AUF ALLEN NODES IDENTISCH SEIN!
  data_dir = "/var/lib/emqx"
}

cluster {
  name = emqxcl
  discovery_strategy = manual
}

listeners {
  tcp.default = 1883
}

dashboard {
  listeners {
    http.bind = 18083
  }
}

management {
  listeners {
    http.bind = 18083
  }
}

auth.acl_file = "etc/acl.conf"
```

**Wichtige Schritte:**

1.  **`node.cookie`**: Setze hier einen **langen, zufälligen und sicheren** Wert. Dieser muss auf **allen Cluster-Nodes exakt gleich** sein.
2.  **Hostnamen-Auflösung:** Stelle sicher, dass jeder EMQX-Node die Hostnamen der anderen Nodes auflösen kann (z.B. über DNS oder `/etc/hosts`). Beispiel für `/etc/hosts` auf beiden Nodes:
    ```
    # Füge diese Zeilen zu /etc/hosts auf beiden Nodes hinzu
    192.168.1.101 emqx-node1 # <--- Ersetze durch die tatsächliche IP von Node 1
    192.168.1.102 emqx-node2 # <--- Ersetze durch die tatsächliche IP von Node 2
    ```

### 8.3. EMQX starten und Cluster bilden

1.  **Starte EMQX auf beiden Nodes:**
    ```bash
    sudo systemctl daemon-reload
    sudo systemctl enable emqx
    sudo systemctl start emqx
    sudo systemctl status emqx
    ```
2.  **Cluster bilden (nur auf *einem* der Nodes ausführen):**
    ```bash
    sudo emqx ctl cluster join emqx@emqx-node2 # Ersetze emqx-node2 durch den Hostnamen des Partner-Nodes
    ```
3.  **Cluster-Status überprüfen (auf beiden Nodes):**
    ```bash
    sudo emqx ctl cluster status
    ```
    Beide Nodes sollten nun als "Running" im Cluster angezeigt werden.

-----

## 9\. Monitoring mit Uptime Kuma und WebHooks

Nutze EMQX WebHooks, um den Broker-Status an Uptime Kuma zu senden.

1.  **Uptime Kuma Push Monitor erstellen:**

      * In Uptime Kuma: "Add New Monitor" -\> Type: **"Push"**.
      * Gib einen Namen (z.B. "EMQX Broker Status") und ein "Heartbeat Interval" (z.B. 60s).
      * **Kopiere die generierte "Push URL"** (z.B. `https://your-uptime-kuma-url/api/push/<YOUR_API_KEY>`).

2.  **EMQX WebHook-Regel erstellen (Regel-Engine):**

      * Erstelle einen Timer in deiner `emqx.conf` (oder `etc/plugins/emqx_rule_engine.conf`):
        ```hocon
        rule_engine.timer.my_heartbeat_timer {
          interval = "50s" # Kleiner als Uptime Kuma Interval
          event = "timer_event_emqx_heartbeat" # Benutzerdefinierter Event-Name
        }
        ```
      * Erstelle eine Regel-Datei unter `/etc/emqx/rules/uptime_kuma_heartbeat.rule`:
        ```hocon
        ## /etc/emqx/rules/uptime_kuma_heartbeat.rule
        rule {
          id = "uptime_kuma_heartbeat"
          description = "Send a regular heartbeat webhook to Uptime Kuma"
          for = "timer_event_emqx_heartbeat"
          actions = [
            {
              function = "do_webhook"
              args = {
                url = "https://your-uptime-kuma-url/api/push/<YOUR_API_KEY>" # <--- DEINE UPTIME KUMA URL HIER!
                method = "GET"
                headers = {}
                body = ""
                pool = "default"
              }
            }
          ]
        }
        ```
      * **Speichere die Dateien und starte EMQX neu:** `sudo systemctl restart emqx`.

-----

## 10\. Automatisierte Paketliste mit GitHub Actions

Ein GitHub Actions Workflow generiert und aktualisiert automatisch eine Liste aller im Repository enthaltenen Pakete in der Datei `package_list.txt`.

### 10.1. Workflow-Datei (`.github/workflows/generate-package-list.yml`)

Lege diese Datei im Ordner `.github/workflows/` deines `archrepo`-Repositorys ab.

```yaml
name: Generate Package List

on:
  push:
    branches:
      - main # Führt den Workflow aus, wenn ein Push auf den main-Branch erfolgt
    paths:
      - 'packages/*.db.tar.gz' # Nur ausführen, wenn die Datenbankdatei geändert wird
      - 'packages/*.pkg.tar.zst' # Oder wenn Pakete hinzugefügt/aktualisiert werden
  workflow_dispatch: {} # Erlaubt das manuelle Starten des Workflows über die GitHub UI

jobs:
  build:
    permissions:
      contents: write # Dies ist entscheidend, damit der Workflow die Liste in das Repo zurückschreiben kann!

    runs-on: ubuntu-latest

    steps:
    - name: Checkout repository
      uses: actions/checkout@v4

    - name: Set up Python
      uses: actions/setup-python@v5
      with:
        python-version: '3.x'

    - name: Generate package list with Python
      working-directory: packages # Führt das Skript im packages-Ordner aus
      run: |
        cat <<EOF > generate_list.py
        import tarfile
        import os

        db_file = 'archrepo.db.tar.gz'
        output_file = 'package_list.txt'
        packages = []

        if not os.path.exists(db_file):
            print(f"Error: Database file {db_file} not found!", file=os.sys.stderr)
            exit(1)

        try:
            with tarfile.open(db_file, 'r:gz') as tar:
                for member in tar.getmembers():
                    if '/desc' in member.name and not member.isdir():
                        try:
                            desc_content = tar.extractfile(member).read().decode('utf-8')
                            name = ""
                            version = ""
                            description = ""

                            lines = desc_content.splitlines()
                            for i, line in enumerate(lines):
                                if line == "%NAME%" and i + 1 < len(lines):
                                    name = lines[i+1]
                                elif line == "%VERSION%" and i + 1 < len(lines):
                                    version = lines[i+1]
                                elif line == "%DESC%" and i + 1 < len(lines):
                                    description = lines[i+1]
                                if name and version and description:
                                    break
                            
                            if name and version:
                                packages.append(f"{name} {version} - {description}")
                        except Exception as e:
                            print(f"Warning: Could not process {member.name}: {e}", file=os.sys.stderr)
            
            packages.sort(key=lambda s: s.lower()) # Alphabetisch sortieren
            with open(output_file, 'w') as f:
                for pkg_info in packages:
                    f.write(pkg_info + '\n')
            
            print(f"Package list generated successfully: {output_file}", file=os.sys.stderr)

        except Exception as e:
            print(f"Error processing {db_file}: {e}", file=os.sys.stderr)
            exit(1)

        EOF
        python generate_list.py
        rm generate_list.py

    - name: Push generated package list to main branch
      run: |
        git config user.name "github-actions[bot]"
        git config user.email "github-actions[bot]@users.noreply.github.com"
        git add packages/package_list.txt
        git commit -m "Update package list [skip ci]" || echo "No changes to package list."
        git push origin main
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### 10.2. Manuelle Schritte zur Aktualisierung der Paketliste

1.  **Lokal im Repository:** Führe `repo-add` im `packages/` Ordner aus, um die Datenbank zu aktualisieren (z.B. nach Hinzufügen eines neuen Pakets):
    ```bash
    cd ~/my-packages/archrepo/packages/
    repo-add archrepo.db.tar.gz <neues_paket>.pkg.tar.zst
    ```
2.  **Committen und Pushen:** Gehe ins Root-Verzeichnis deines `archrepo` und pushe die Änderungen:
    ```bash
    cd ~/my-packages/archrepo/
    git add .
    git commit -m "Updated repository with new packages/db"
    git push origin main
    ```
    Dieser Push wird den GitHub Actions Workflow `Generate Package List` automatisch auslösen.

### 10.3. Paketliste einsehen

Die automatisch generierte Liste der Pakete ist unter folgender URL verfügbar:
`https://dp20eic.github.io/archrepo/packages/package_list.txt`

-----
