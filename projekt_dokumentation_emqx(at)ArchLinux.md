-----

# EMQX Cluster auf Arch Linux LXC: Installation, Automatisierung & Monitoring mit Uptime Kuma

Diese Dokumentation führt dich durch die Installation, Konfiguration und Überwachung eines EMQX Clusters auf Arch Linux LXC Containern unter Proxmox. Es werden bewährte Methoden für Clustering, TLS-Verschlüsselung, Firewall-Konfiguration, automatische Updates mittels GitHub Actions und das Monitoring mit Uptime Kuma behandelt.

*Hinweis: Der Abschnitt zur EMQX Cluster Überwachung mit Uptime Kuma (Heartbeat) wurde mit den neuesten, funktionierenden Konfigurationen aktualisiert.*

**Inhaltsverzeichnis**

1.  [Einleitung](https://www.google.com/search?q=%231-einleitung)
2.  [Arch Linux LXC Container auf Proxmox aufsetzen](https://www.google.com/search?q=%232-arch-linux-lxc-container-auf-proxmox-aufsetzen)
    1.  [LXC erstellen](https://www.google.com/search?q=%2321-lxc-erstellen)
    2.  [Installation von Paketen](https://www.google.com/search?q=%2322-installation-von-paketen)
    3.  [LXC vorbereiten](https://www.google.com/search?q=%2323-lxc-vorbereiten)
3.  [EMQX Installation](https://www.google.com/search?q=%233-emqx-installation)
    1.  [PKGBUILD erstellen](https://www.google.com/search?q=%2331-pkgbuild-erstellen)
    2.  [Abhängigkeiten installieren](https://www.google.com/search?q=%2332-abh%C3%A4ngigkeiten-installieren)
    3.  [Paket kompilieren und installieren](https://www.google.com/search?q=%2333-paket-kompilieren-und-installieren)
    4.  [Systemd-Dienst starten und aktivieren](https://www.google.com/search?q=%2334-systemd-dienst-starten-und-aktivieren)
4.  [EMQX Cluster Konfiguration](https://www.google.com/search?q=%234-emqx-cluster-konfiguration)
    1.  [EMQX Cluster Nodes benennen](https://www.google.com/search?q=%2341-emqx-cluster-nodes-benennen)
    2.  [Erlang Cookie konfigurieren](https://www.google.com/search?q=%2342-erlang-cookie-konfigurieren)
    3.  [EMQX Cluster bilden](https://www.google.com/search?q=%2343-emqx-cluster-bilden)
5.  [Let's Encrypt Zertifikate für EMQX](https://www.google.com/search?q=%235-lets-encrypt-zertifikate-f%C3%BCr-emqx)
    1.  [Certbot Installation und Konfiguration](https://www.google.com/search?q=%2351-certbot-installation-und-konfiguration)
    2.  [Zertifikate für EMQX konfigurieren](https://www.google.com/search?q=%2352-zertifikate-f%C3%BCr-emqx-konfigurieren)
6.  [EMQX Dashboard und Basic Security](https://www.google.com/search?q=%236-emqx-dashboard-und-basic-security)
    1.  [Dashboard Zugang](https://www.google.com/search?q=%2361-dashboard-zugang)
    2.  [Standard-Benutzer und Passwörter ändern](https://www.google.com/search?q=%2362-standard-benutzer-und-passw%C3%B6rter-%C3%A4ndern)
7.  [Firewall-Konfiguration (ufw)](https://www.google.com/search?q=%237-firewall-konfiguration-ufw)
    1.  [UFW installieren und konfigurieren](https://www.google.com/search?q=%2371-ufw-installieren-und-konfigurieren)
    2.  [Erforderliche Ports öffnen](https://www.google.com/search?q=%2372-erforderliche-ports-%C3%B6ffnen)
8.  [GitHub Actions Integration (Automatischer Paket-Push)](https://www.google.com/search?q=%238-github-actions-integration-automatischer-paket-push)
    1.  [SSH-Schlüsselpaar generieren](https://www.google.com/search?q=%2381-ssh-schl%C3%BCsselpaar-generieren)
    2.  [GitHub Secrets konfigurieren](https://www.google.com/search?q=%2382-github-secrets-konfigurieren)
    3.  [GitHub Actions Workflow einrichten](https://www.google.com/search?q=%2383-github-actions-workflow-einrichten)
    4.  [Arch Linux Repository aufsetzen](https://www.google.com/search?q=%2384-arch-linux-repository-aufsetzen)
9.  [Uptime Kuma Installation und Monitoring (Basis)](https://www.google.com/search?q=%239-uptime-kuma-installation-und-monitoring-basis)
    1.  [Uptime Kuma Installation (Docker)](https://www.google.com/search?q=%2391-uptime-kuma-installation-docker)
    2.  [Einfaches HTTP(s) Monitoring](https://www.google.com/search?q=%2392-einfaches-https-monitoring)
10. [EMQX Cluster Überwachung mit Uptime Kuma (Heartbeat)](https://www.google.com/search?q=%2310-emqx-cluster-%C3%BCberwachung-mit-uptime-kuma-heartbeat)
    1.  [Voraussetzungen](https://www.google.com/search?q=%23101-voraussetzungen)
    2.  [Uptime Kuma Konfiguration: Push-Monitor erstellen](https://www.google.com/search?q=%23102-uptime-kuma-konfiguration-push-monitor-erstellen)
    3.  [EMQX MQTT Broker Konfiguration](https://www.google.com/search?q=%23103-emqx-mqtt-broker-konfiguration)
        1.  [HTTP-Connector erstellen](https://www.google.com/search?q=%231031-http-connector-erstellen)
        2.  [Regel für den Heartbeat erstellen](https://www.google.com/search?q=%231032-regel-f%C3%BCr-den-heartbeat-erstellen)
    4.  [Arch Linux LXC Konfiguration für Heartbeat](https://www.google.com/search?q=%23104-arch-linux-lxc-konfiguration-f%C3%BCr-heartbeat)
        1.  [Python und `paho-mqtt` installieren](https://www.google.com/search?q=%231041-python-und-paho-mqtt-installieren)
        2.  [Python Heartbeat-Skript erstellen](https://www.google.com/search?q=%231042-python-heartbeat-skript-erstellen)
        3.  [Systemd Service Unit erstellen](https://www.google.com/search?q=%231043-systemd-service-unit-erstellen)
        4.  [Systemd Timer Unit erstellen](https://www.google.com/search?q=%231044-systemd-timer-unit-erstellen)
        5.  [Systemd Units aktivieren und starten](https://www.google.com/search?q=%231045-systemd-units-aktivieren-und-starten)
    5.  [Fehlerbehebung und Überprüfung](https://www.google.com/search?q=%23105-fehlerbehebung-und-%C3%BCberpr%C3%BCfung)

-----

\<a name="1-einleitung"\>\</a\>

## 1\. Einleitung

Diese Dokumentation führt dich durch die Installation, Konfiguration und Überwachung eines EMQX Clusters auf Arch Linux LXC Containern unter Proxmox. Es werden bewährte Methoden für Clustering, TLS-Verschlüsselung, Firewall-Konfiguration, automatische Updates mittels GitHub Actions und das Monitoring mit Uptime Kuma behandelt.

\<a name="2-arch-linux-lxc-container-auf-proxmox-aufsetzen"\>\</a\>

## 2\. Arch Linux LXC Container auf Proxmox aufsetzen

\<a name="21-lxc-erstellen"\>\</a\>

### 2.1. LXC erstellen

Erstelle zwei Arch Linux LXC Container in Proxmox. Dies dient der Hochverfügbarkeit und Skalierbarkeit deines EMQX Clusters.

\<a name="22-installation-von-paketen"\>\</a\>

### 2.2. Installation von Paketen

Auf beiden LXC-Containern benötigst du grundlegende Pakete. Aktualisiere zuerst das System und installiere dann die notwendigen Tools:

```bash
sudo pacman -Syu
sudo pacman -S base-devel git nano openssh
```

\<a name="23-lxc-vorbereiten"\>\</a\>

### 2.3. LXC vorbereiten

Stelle sicher, dass die Netzwerkkonfiguration in beiden LXCs korrekt ist (statische IPs empfohlen) und die Hostnamen korrekt gesetzt sind (z.B. `emqx1.fritz.box`, `emqx2.fritz.box`). Dies ist entscheidend für das Clustering.

\<a name="3-emqx-installation"\>\</a\>

## 3\. EMQX Installation

EMQX wird aus dem Quellcode gebaut, um die Kontrolle über die Version und Konfiguration zu haben.

\<a name="31-pkgbuild-erstellen"\>\</a\>

### 3.1. PKGBUILD erstellen

Erstelle ein `PKGBUILD` für EMQX. Dieses Skript automatisiert den Bau und die Installation des Pakets.

```bash
mkdir -p ~/emqx-pkgbuild
cd ~/emqx-pkgbuild
nano PKGBUILD
```

Beispiel `PKGBUILD` (Stelle sicher, dass die `pkgver` deiner gewünschten EMQX-Version entspricht):

```pkgbuild
# PKGBUILD for EMQX (Example - adjust version as needed)
pkgname=emqx
pkgver=5.8.6 # <--- ANPASSEN AN AKTUELLE VERSION
pkgrel=1
pkgdesc="A highly scalable, real-time MQTT messaging platform."
arch=('x86_64')
url="https://www.emqx.io/"
license=('Apache')
depends=('erlang' 'openssl' 'ncurses') # Basic dependencies, may need more based on EMQX build requirements
makedepends=('git' 'rebar3') # Build tools for Erlang

source=("https://github.com/emqx/emqx/archive/refs/tags/v${pkgver}.tar.gz")
sha256sums=('SKIP') # Use actual checksum if available, or 'SKIP' for testing

build() {
  cd "${srcdir}/emqx-${pkgver}"
  make
}

package() {
  cd "${srcdir}/emqx-${pkgver}"
  # EMQX typically has a _build directory, we want to copy the runtime
  # Adjust this based on actual EMQX build output structure
  mkdir -p "${pkgdir}/usr/lib/emqx"
  cp -a _build/default/rel/emqx/* "${pkgdir}/usr/lib/emqx/"

  # Create symlink for /usr/bin/emqx
  mkdir -p "${pkgdir}/usr/bin"
  ln -s /usr/lib/emqx/bin/emqx "${pkgdir}/usr/bin/emqx"

  # Copy systemd service file (if provided by EMQX source or create custom)
  mkdir -p "${pkgdir}/usr/lib/systemd/system/"
  install -m644 "${srcdir}/emqx-${pkgver}/etc/emqx.service" "${pkgdir}/usr/lib/systemd/system/emqx.service"

  # Copy default configuration files
  mkdir -p "${pkgdir}/etc/emqx/"
  cp -a "${srcdir}/emqx-${pkgver}/etc/emqx.conf" "${pkgdir}/etc/emqx/"
  cp -a "${srcdir}/emqx-${pkgver}/etc/cluster.hocon" "${pkgdir}/etc/emqx/"
  cp -a "${srcdir}/emqx-${pkgver}/etc/certs/" "${pkgdir}/etc/emqx/"
  cp -a "${srcdir}/emqx-${pkgver}/etc/plugins/" "${pkgdir}/etc/emqx/"
  cp -a "${srcdir}/emqx-${pkgver}/etc/rules/" "${pkgdir}/etc/emqx/"
  cp -a "${srcdir}/emqx-${pkgver}/etc/base.hocon" "${pkgdir}/etc/emqx/"
}
```

\<a name="32-abhängigkeiten-installieren"\>\</a\>

### 3.2. Abhängigkeiten installieren

Installieren Sie die für den Bau notwendigen Abhängigkeiten:

```bash
sudo pacman -S erlang openssl ncurses git rebar3
```

\<a name="33-paket-kompilieren-und-installieren"\>\</a\>

### 3.3. Paket kompilieren und installieren

Navigieren Sie in das Verzeichnis mit Ihrem `PKGBUILD` und bauen Sie das Paket, dann installieren Sie es.

```bash
cd ~/emqx-pkgbuild
makepkg -si
```

\<a name="34-systemd-dienst-starten-und-aktivieren"\>\</a\>

### 3.4. Systemd-Dienst starten und aktivieren

Nach der Installation aktivieren und starten Sie den EMQX-Dienst:

```bash
sudo systemctl enable emqx
sudo systemctl start emqx
sudo systemctl status emqx
```

\<a name="4-emqx-cluster-konfiguration"\>\</a\>

## 4\. EMQX Cluster Konfiguration

Konfiguriere beide EMQX-Nodes für den Cluster-Betrieb.

\<a name="41-emqx-cluster-nodes-benennen"\>\</a\>

### 4.1. EMQX Cluster Nodes benennen

Bearbeite auf **beiden** Nodes die `/etc/emqx/emqx.conf` und passe den `node.name` an den jeweiligen Hostnamen an.

```bash
sudo nano /etc/emqx/emqx.conf
```

**Auf `emqx1`:**

```hocon
node {
  name = "emqx@emqx1.fritz.box"
  # ...
}
```

**Auf `emqx2`:**

```hocon
node {
  name = "emqx@emqx2.fritz.box"
  # ...
}
```

\<a name="42-erlang-cookie-konfigurieren"\>\</a\>

### 4.2. Erlang Cookie konfigurieren

Setze auf **beiden** Nodes den `node.cookie` in `/etc/emqx/emqx.conf` auf einen **identischen, langen und zufälligen String**. Dies ist entscheidend für die Sicherheit des Clusters.

```bash
sudo nano /etc/emqx/emqx.conf
```

```hocon
node {
  # ...
  cookie = "your_super_secret_and_long_erlang_cookie" # <-- Diesen Wert ändern und auf beiden Nodes gleich setzen!
  # ...
}
```

Nach den Änderungen an `emqx.conf` auf beiden Nodes:

```bash
sudo systemctl restart emqx
```

\<a name="43-emqx-cluster-bilden"\>\</a\>

### 4.3. EMQX Cluster bilden

Wähle einen Node (z.B. `emqx1`) als den "Starter" und füge den anderen Node hinzu. Führe diese Schritte nur auf **einem** Node aus.

**Auf `emqx1`:**

1.  **Node-Status überprüfen:**
    ```bash
    emqx ctl status
    ```
    Stelle sicher, dass EMQX läuft.
2.  **Cluster join vom zweiten Node aus initiieren (vom ersten Node aus):**
    ```bash
    emqx ctl cluster join emqx@emqx2.fritz.box
    ```
3.  **Cluster-Status überprüfen:**
    ```bash
    emqx ctl cluster status
    ```
    Beide Nodes sollten nun als Teil des Clusters angezeigt werden.

\<a name="5-lets-encrypt-zertifikate-für-emqx"\>\</a\>

## 5\. Let's Encrypt Zertifikate für EMQX

Sichere die MQTT- und Dashboard-Verbindungen mit TLS/SSL-Zertifikaten von Let's Encrypt. Dies ist nur auf einem Node (z.B. `emqx1`) notwendig, da die Zertifikate dann auf den anderen Node repliziert werden können.

\<a name="51-certbot-installation-und-konfiguration"\>\</a\>

### 5.1. Certbot Installation und Konfiguration

Installieren Sie Certbot und beantragen Sie die Zertifikate.

```bash
sudo pacman -S certbot certbot-nginx # certbot-nginx ist nützlich, wenn du Nginx als Reverse Proxy nutzt
```

Beantragen Sie die Zertifikate (passen Sie `your.domain.com` an):

```bash
sudo certbot certonly --standalone -d mqtt.your.domain.com -d dashboard.your.domain.com --agree-tos --email your-email@example.com
```

Die Zertifikate werden typischerweise unter `/etc/letsencrypt/live/mqtt.your.domain.com/` gespeichert.

\<a name="52-zertifikate-für-emqx-konfigurieren"\>\</a\>

### 5.2. Zertifikate für EMQX konfigurieren

Passe die EMQX-Konfiguration an, um die Let's Encrypt Zertifikate zu verwenden.

```bash
sudo nano /etc/emqx/emqx.conf
```

**Für MQTT TLS:**
Aktiviere den TLS Listener und gib die Pfade zu den Zertifikaten an:

```hocon
listeners.ssl.default {
  bind = "8883"
  enable = true
  ssl_options {
    # Full chain of certificates
    certfile = "/etc/letsencrypt/live/mqtt.your.domain.com/fullchain.pem"
    # Private key
    keyfile = "/etc/letsencrypt/live/mqtt.your.domain.com/privkey.pem"
    # ... weitere SSL-Optionen wie 'cacertfile', 'verify', 'versions'
  }
}
```

**Für Dashboard HTTPS:**
Aktiviere den HTTPS Listener für das Dashboard:

```hocon
dashboard {
  listeners.https {
    bind = "18083" # Oder ein anderer Port, wenn du 18083 schon für HTTP nutzt
    enable = true
    ssl_options {
      # Full chain of certificates
      certfile = "/etc/letsencrypt/live/dashboard.your.domain.com/fullchain.pem"
      # Private key
      keyfile = "/etc/letsencrypt/live/dashboard.your.domain.com/privkey.pem"
      # ...
    }
  }
}
```

Nach den Änderungen EMQX neu starten: `sudo systemctl restart emqx`.

\<a name="6-emqx-dashboard-und-basic-security"\>\</a\>

## 6\. EMQX Dashboard und Basic Security

\<a name="61-dashboard-zugang"\>\</a\>

### 6.1. Dashboard Zugang

Das EMQX Dashboard ist über Port 18083 (HTTP) oder 18084 (HTTPS, falls konfiguriert) erreichbar: `http://<EMQX_IP_ADDRESS>:18083`.

\<a name="62-standard-benutzer-und-passwörter-ändern"\>\</a\>

### 6.2. Standard-Benutzer und Passwörter ändern

**Ändere UNBEDINGT die Standardanmeldedaten des Dashboards\!**

  * Melde dich mit dem Standardbenutzer `admin` und Passwort `public` an.
  * Gehe zu **"System" -\> "Users"** und ändere das Passwort für den `admin`-Benutzer.
  * Erstelle bei Bedarf weitere Benutzer mit spezifischen Rollen.

\<a name="7-firewall-konfiguration-ufw"\>\</a\>

## 7\. Firewall-Konfiguration (ufw)

Konfiguriere die Firewall (ufw) auf **jedem** EMQX-Node, um die notwendigen Ports zu öffnen.

\<a name="71-ufw-installieren-und-konfigurieren"\>\</a\>

### 7.1. UFW installieren und konfigurieren

```bash
sudo pacman -S ufw
sudo ufw enable
```

\<a name="72-erforderliche-ports-öffnen"\>\</a\>

### 7.2. Erforderliche Ports öffnen

  * **MQTT (Standard):** 1883/tcp
  * **MQTT (TLS):** 8883/tcp (falls konfiguriert)
  * **Dashboard (HTTP):** 18083/tcp
  * **Dashboard (HTTPS):** 18084/tcp (falls konfiguriert)
  * **Erlang Distribution (Cluster-Kommunikation):** 4370/tcp (Standard)
  * **EMQX Cluster Port Range:** Standardmäßig `6000-60000`/tcp (EMQX wählt einen zufälligen Port im `listener.tcp.internal` Bereich, oft ab 6000. Überprüfe deine `emqx.conf` für `cluster.rpc_port` oder `listener.tcp.internal` um den genauen Port oder Bereich zu bestimmen.)

<!-- end list -->

```bash
sudo ufw allow 1883/tcp
sudo ufw allow 8883/tcp
sudo ufw allow 18083/tcp
sudo ufw allow 18084/tcp
sudo ufw allow 4370/tcp
sudo ufw allow 6000:60000/tcp # Oder den spezifischen Bereich anpassen
sudo ufw status verbose
```

\<a name="8-github-actions-integration-automatischer-paket-push"\>\</a\>

## 8\. GitHub Actions Integration (Automatischer Paket-Push)

Automatisiere das Bauen und Pushen deiner Arch Linux Pakete (z.B. des EMQX PKGBUILD) auf ein GitHub-basiertes Repository mit GitHub Actions.

\<a name="81-ssh-schlüsselpaar-generieren"\>\</a\>

### 8.1. SSH-Schlüsselpaar generieren

Generiere ein SSH-Schlüsselpaar, das GitHub Actions zum Pushen verwenden kann. **Verwenden Sie keine Passphrase für den privaten Schlüssel.**

```bash
ssh-keygen -t ed25519 -f ~/.ssh/github_actions_deploy -N ""
```

  * **Privater Schlüssel:** `~/.ssh/github_actions_deploy` (Dieser muss in GitHub Secrets hinterlegt werden).
  * **Öffentlicher Schlüssel:** `~/.ssh/github_actions_deploy.pub` (Dieser muss zum `authorized_keys` auf deinem LXC hinzugefügt werden).

\<a name="82-github-secrets-konfigurieren"\>\</a\>

### 8.2. GitHub Secrets konfigurieren

Füge den privaten Schlüssel als GitHub Secret in deinem Repository hinzu:

1.  Gehe zu deinem GitHub Repository -\> **Settings -\> Secrets and variables -\> Actions**.
2.  Klicke auf **"New repository secret"**.
3.  **Name:** `SSH_PRIVATE_KEY`
4.  **Value:** Füge den **kompletten Inhalt** deines privaten SSH-Schlüssels (`~/.ssh/github_actions_deploy`) ein, beginnend mit `-----BEGIN OPENSSH PRIVATE KEY-----` und endend mit `-----END OPENSSH PRIVATE KEY-----`.

\<a name="83-github-actions-workflow-einrichten"\>\</a\>

### 8.3. GitHub Actions Workflow einrichten

Erstelle eine `.github/workflows/build.yml`-Datei in deinem Repository, die den Build- und Push-Prozess definiert.

```yaml
# .github/workflows/build.yml
name: Build and Deploy Arch Package

on:
  push:
    branches:
      - main # Trigger on pushes to the main branch

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4

    - name: Set up SSH
      uses: webfactory/ssh-agent@v0.8.0
      with:
        ssh-private-key: ${{ secrets.SSH_PRIVATE_KEY }}

    - name: Add SSH key to known_hosts
      run: |
        mkdir -p ~/.ssh
        ssh-keyscan github.com >> ~/.ssh/known_hosts
        ssh-keyscan your_lxc_server_ip >> ~/.ssh/known_hosts # Add your LXC server's fingerprint
      
    - name: Build and Push Package
      run: |
        # Example: Replace with your actual build and push commands
        # This part assumes you have a script or commands to build your PKGBUILD
        # and then rsync/scp it to your LXC server.
        
        # Example: Build package in a Docker container (archlinux/archlinux)
        docker run --rm -v "$(pwd):/build" archlinux/archlinux /bin/bash -c "cd /build && makepkg -s --noconfirm"
        
        # Example: Rsync the built package to your Arch Linux LXC
        # Ensure 'your_user@your_lxc_server_ip' has permissions to write to '/srv/archrepo'
        rsync -avz --delete *.pkg.tar.zst your_user@your_lxc_server_ip:/srv/archrepo/
```

\<a name="84-arch-linux-repository-aufsetzen"\>\</a\>

### 8.4. Arch Linux Repository aufsetzen

Auf deinem Arch Linux LXC Container:

1.  **Repository-Verzeichnis erstellen:**
    ```bash
    sudo mkdir -p /srv/archrepo
    sudo chown your_user:your_user /srv/archrepo # Gib dem Benutzer, der per SSH pusht, Schreibrechte
    ```
2.  **Repo-Tool installieren:**
    ```bash
    sudo pacman -S repo
    ```
3.  **Repository initialisieren und hinzufügen:**
    ```bash
    cd /srv/archrepo
    repo-add yourrepo.db.tar.gz *.pkg.tar.zst # Erstelle oder aktualisiere die Datenbank
    ```
    Dieser Befehl muss jedes Mal ausgeführt werden, wenn neue Pakete hinzugefügt oder aktualisiert werden. Du kannst dies in einem Post-Receive-Hook für Git oder einem separaten Cron-Job automatisieren.

\<a name="9-uptime-kuma-installation-und-monitoring-basis"\>\</a\>

## 9\. Uptime Kuma Installation und Monitoring (Basis)

Uptime Kuma ist ein benutzerfreundliches Überwachungstool, das dir den Status deiner Dienste anzeigt.

\<a name="91-uptime-kuma-installation-docker"\>\</a\>

### 9.1. Uptime Kuma Installation (Docker)

Die einfachste Methode ist die Installation mittels Docker:

```bash
docker run -d --restart=always -p 3001:3001 -v uptime-kuma:/app/data --name uptime-kuma louislam/uptime-kuma:1
```

Uptime Kuma ist dann unter `http://<Your-Server-IP>:3001` erreichbar.

\<a name="92-einfaches-https-monitoring"\>\</a\>

### 9.2. Einfaches HTTP(s) Monitoring

Füge einen grundlegenden Monitor für das EMQX Dashboard hinzu:

1.  Im Uptime Kuma Dashboard: **"Add New Monitor"**.
2.  **Monitor Type:** `HTTP(s)`.
3.  **Friendly Name:** "EMQX Dashboard".
4.  **URL:** `http://<EMQX_IP_ADDRESS>:18083` (oder HTTPS-URL, falls konfiguriert).
5.  **Heartbeat Interval:** Z.B. `60 Sekunden`.
6.  **Setup Notification:** Konfiguriere eine Benachrichtigungsmethode (E-Mail, Telegram etc.).

\<a name="10-emqx-cluster-überwachung-mit-uptime-kuma-heartbeat"\>\</a\>

## 10\. EMQX Cluster Überwachung mit Uptime Kuma (Heartbeat)

Um die Verfügbarkeit deines EMQX-Clusters zu überwachen, kannst du Uptime Kuma als Heartbeat-Monitor verwenden. Da die direkte "Timed Event"-Funktion im EMQX Dashboard deiner Version möglicherweise nicht sichtbar ist, nutzen wir eine Kombination aus `systemd timer` auf dem EMQX-Server und der EMQX Regel-Engine.

\<a name="101-voraussetzungen"\>\</a\>

### 10.1. Voraussetzungen

  * Ein laufender Arch Linux LXC-Container.
  * EMQX MQTT Broker auf dem LXC installiert und aktiv.
  * Uptime Kuma Instanz läuft und ist über das Netzwerk erreichbar.
  * Grundkenntnisse im Umgang mit der Kommandozeile unter Arch Linux und `systemd`.

\<a name="102-uptime-kuma-konfiguration-push-monitor-erstellen"\>\</a\>

### 10.2. Uptime Kuma Konfiguration: Push-Monitor erstellen

1.  Logge dich in dein Uptime Kuma Dashboard ein.
2.  Klicke auf **"+ Neuen Monitor hinzufügen"**.
3.  Wähle als **Monitor-Typ** `Push`.
4.  Gib einen aussagekräftigen **Anzeigenamen** ein (z.B. "EMQX Node 1 Status").
5.  Setze das **Heartbeat Interval** auf `60` Sekunden.
      * *Hinweis:* Wir werden den Heartbeat alle 50 Sekunden senden, um eine Pufferzeit zu haben.
6.  Wähle `Auto` für **"Wird für X Minuten als 'Down' angezeigt, wenn kein Heartbeat empfangen wurde."**.
7.  Kopiere die angezeigte **Push URL**. Diese URL wird im EMQX Broker benötigt. Sie sieht etwa so aus: `http(s)://your-uptime-kuma-url/api/push/<YOUR_API_KEY>`.
8.  Klicke auf **"Speichern"**. Der Monitor wird zunächst als "Inaktiv" angezeigt.

\<a name="103-emqx-mqtt-broker-konfiguration"\>\</a\>

### 10.3. EMQX MQTT Broker Konfiguration

Logge dich in das EMQX Dashboard ein (normalerweise Port 18083).

\<a name="1031-http-connector-erstellen"\>\</a\>

#### 10.3.1. HTTP-Connector erstellen

1.  Navigiere zu **"Rule Engine"** (oder "Data Integrations") -\> **"Connectors"**.
2.  Klicke auf **"+ Erstellen"**.
3.  Wähle **"HTTP Server"** als Connector-Typ.
4.  Gib einen **Namen** für den Connector ein (z.B. `UptimeKuma_WebHook_Connector`).
5.  Im Feld **"URL"** gibst du die **Basis-URL deiner Uptime Kuma Instanz** ein (ohne den `/api/push/...`-Teil).
      * Beispiel: `http://kuma.fritz.box:3001` (oder `https://` falls Uptime Kuma HTTPS verwendet).
6.  Stelle die **"Method"** auf **`GET`**.
7.  Stelle sicher, dass **keine "Headers"** definiert sind (insbesondere `content-type: application/json` muss gelöscht werden).
8.  Stelle sicher, dass das Feld **"Body" LEER** ist.
9.  Klicke auf **"Test Connectivity"**, um sicherzustellen, dass EMQX Uptime Kuma erreichen kann.
10. Klicke auf **"Erstellen"**.

\<a name="1032-regel-für-den-heartbeat-erstellen"\>\</a\>

#### 10.3.2. Regel für den Heartbeat erstellen

1.  Navigiere zu **"Rule Engine" -\> "Rules"**.
2.  Klicke auf **"+ Erstellen"**.
3.  Gib einen **Regelnamen** ein (z.B. `uptime_kuma_mqtt_heartbeat_rule`).
4.  **SQL Editor:** Füge die folgende SQL-Abfrage ein:
    ```sql
    SELECT * FROM "/emqx/heartbeat"
    ```
5.  **Action Outputs:**
      * Klicke auf **"Add Action"**.
      * Wähle als **"Type of Action"** `HTTP Server`.
      * Wähle unter **"Connectors"** deinen zuvor erstellten Connector aus (z.B. `UptimeKuma_WebHook_Connector`).
      * Im Feld **"URL Path"** gibst du den **Pfad und API-Schlüssel** der Uptime Kuma Push URL ein (beginnt mit `/api/push/`).
          * Beispiel: `/api/push/povsWYV5SWF3Uhr`
      * Stelle die **"Method"** auf **`GET`**.
      * Stelle sicher, dass **"Headers" LEER** sind.
      * Stelle sicher, dass **"Body" LEER** ist. (Ein Wert wie `1` oder ähnliches muss entfernt werden).
      * Klicke auf **"Bestätigen"**.
6.  Klicke auf **"Erstellen"**, um die Regel zu speichern.
7.  Stelle sicher, dass der Schalter neben deiner neuen Regel auf der "Rules"-Übersichtsseite auf **"Enable"** (grün) steht.

\<a name="104-arch-linux-lxc-konfiguration-für-heartbeat"\>\</a\>

### 10.4. Arch Linux LXC Konfiguration für Heartbeat

Verbinde dich per SSH mit deinem Arch Linux LXC-Container.

\<a name="1041-python-und-paho-mqtt-installieren"\>\</a\>

#### 10.4.1. Python und `paho-mqtt` installieren

1.  **Python und Pip installieren:**
    ```bash
    sudo pacman -S python python-pip
    ```
2.  **`paho-mqtt` systemweit installieren:**
    ```bash
    paru -S python-paho-mqtt
    ```
      * *Hinweis:* `python-paho-mqtt` ist ein Arch Linux Paket, das die Bibliothek systemweit installiert, daher ist `pip` in diesem Schritt nicht notwendig.

\<a name="1042-python-heartbeat-skript-erstellen"\>\</a\>

#### 10.4.2. Python Heartbeat-Skript erstellen

1.  Erstelle die Datei `/usr/local/bin/emqx_heartbeat.py`:
    ```bash
    sudo nano /usr/local/bin/emqx_heartbeat.py
    ```
2.  Füge folgenden Python-Code ein:
    ```python
    #!/usr/bin/env python3

    import paho.mqtt.client as mqtt
    import time
    import sys

    # Konfiguration
    BROKER_ADDRESS = "localhost"  # Oder die IP deines EMQX-Servers
    BROKER_PORT = 1883           # Standard MQTT Port
    TOPIC = "/emqx/heartbeat"    # Muss mit dem Topic in deiner Regel übereinstimmen
    MESSAGE = ""                 # Eine leere Nachricht ist ausreichend für den Heartbeat
    QOS = 0

    def on_connect(client, userdata, flags, rc):
        """Callback-Funktion, die bei erfolgreicher Verbindung aufgerufen wird."""
        if rc == 0:
            print("Verbunden mit MQTT Broker.")
        else:
            print(f"Verbindung fehlgeschlagen, Rückgabecode {rc}\n")
            sys.exit(1) # Skript bei Verbindungsfehler beenden

    def on_publish(client, userdata, mid):
        """Callback-Funktion, die nach dem Publizieren aufgerufen wird."""
        pass # Für diesen Heartbeat brauchen wir keine Bestätigung im Log

    def main():
        client = mqtt.Client() # Angepasst für paho-mqtt < 2.0.0
        client.on_connect = on_connect
        client.on_publish = on_publish

        try:
            client.connect(BROKER_ADDRESS, BROKER_PORT, 60)
            client.loop_start() # Startet einen Thread für die Hintergrundverarbeitung
            
            # Publizieren der Nachricht
            result, mid = client.publish(TOPIC, MESSAGE, QOS)
            if result == mqtt.MQTT_ERR_SUCCESS:
                print(f"'{MESSAGE}' erfolgreich an Topic '{TOPIC}' gesendet.")
            else:
                print(f"Fehler beim Senden der Nachricht: {mqtt.error_string(result)}")
                sys.exit(1)

            time.sleep(1) # Kurze Pause, um dem Publish Zeit zu geben
            client.loop_stop() # Stoppt den Hintergrund-Thread
            client.disconnect()

        except Exception as e:
            print(f"Ein Fehler ist aufgetreten: {e}")
            sys.exit(1)

    if __name__ == "__main__":
        main()
    ```
3.  Mache das Skript ausführbar:
    ```bash
    sudo chmod +x /usr/local/bin/emqx_heartbeat.py
    ```

\<a name="1043-systemd-service-unit-erstellen"\>\</a\>

#### 10.4.3. Systemd Service Unit erstellen

1.  Erstelle die Service-Datei `/etc/systemd/system/emqx-heartbeat.service`:
    ```bash
    sudo nano /etc/systemd/system/emqx-heartbeat.service
    ```
2.  Füge den folgenden Inhalt ein:
    ```ini
    [Unit]
    Description=EMQX Heartbeat to Uptime Kuma
    # Stellt sicher, dass Netzwerk und EMQX laufen, bevor der Service startet
    After=network.target emqx.service

    [Service]
    Type=oneshot
    # Führe das Python-Skript aus
    ExecStart=/usr/local/bin/emqx_heartbeat.py
    # Führe das Skript als der EMQX-Benutzer aus (oder ein anderer Benutzer, der Berechtigungen hat)
    User=emqx
    # Führe das Skript als die EMQX-Gruppe aus
    Group=emqx
    StandardOutput=journal
    StandardError=journal

    [Install]
    WantedBy=multi-user.target
    ```

\<a name="1044-systemd-timer-unit-erstellen"\>\</a\>

#### 10.4.4. Systemd Timer Unit erstellen

1.  Erstelle die Timer-Datei `/etc/systemd/system/emqx-heartbeat.timer`:
    ```bash
    sudo nano /etc/systemd/system/emqx-heartbeat.timer
    ```
2.  Füge den folgenden Inhalt ein:
    ```ini
    [Unit]
    Description=Run EMQX Heartbeat every 50 seconds

    [Timer]
    OnBootSec=10s
    OnUnitActiveSec=50s
    AccuracySec=1s

    [Install]
    WantedBy=timers.target
    ```

\<a name="1045-systemd-units-aktivieren-und-starten"\>\</a\>

#### 10.4.5. Systemd Units aktivieren und starten

1.  Lade die `systemd`-Konfiguration neu, um die neuen Dateien zu erkennen:
    ```bash
    sudo systemctl daemon-reload
    ```
2.  Aktiviere und starte den Timer:
    ```bash
    sudo systemctl enable emqx-heartbeat.timer
    sudo systemctl start emqx-heartbeat.timer
    ```

\<a name="105-fehlerbehebung-und-überprüfung"\>\</a\>

### 10.5. Fehlerbehebung und Überprüfung

1.  **Überprüfe den Status der Units:**
    ```bash
    sudo systemctl status emqx-heartbeat.timer
    sudo systemctl status emqx-heartbeat.service
    ```
      * Der Timer sollte `active (waiting)` sein.
      * Der Service sollte `active (exited)` sein (da er `oneshot` ist und nach Ausführung beendet wird).
2.  **Überprüfe die Logs des Services:**
    ```bash
    journalctl -u emqx-heartbeat.service -f
    ```
    Hier solltest du die Ausgaben des Python-Skripts sehen (z.B. "Verbunden mit MQTT Broker." und "'' erfolgreich an Topic '/emqx/heartbeat' gesendet."). Fehler im Skript werden hier ebenfalls angezeigt.
3.  **Überprüfe die EMQX Regel-Engine Statistiken:**
    Im EMQX Dashboard unter **"Rule Engine" -\> "Rules"** solltest du bei deiner `uptime_kuma_mqtt_heartbeat_rule` sehen, dass die Zähler für "Rule Matched" und "Success" alle 50 Sekunden steigen.
4.  **Überprüfe Uptime Kuma:**
    Nachdem die Regel erfolgreich ausgelöst wurde und der HTTP-Aufruf korrekt war, sollte dein "EMQX Node 1 Status" Monitor in Uptime Kuma von "Inaktiv" auf **"Up"** wechseln.
    Sollten weiterhin Probleme auftreten, ist der `journalctl`-Output die wichtigste Quelle für die Fehlersuche.
