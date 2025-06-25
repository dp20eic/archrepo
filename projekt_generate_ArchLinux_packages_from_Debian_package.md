-----

# Arch Linux EMQX Cluster und Uptime Kuma Monitoring - Vollständige Dokumentation

## Inhaltsverzeichnis

  * [1. Einleitung](https://www.google.com/search?q=%231-einleitung)
  * [2. Arch Linux LXC Container auf Proxmox aufsetzen](https://www.google.com/search?q=%232-arch-linux-lxc-container-auf-proxmox-aufsetzen)
      * [2.1. LXC erstellen](https://www.google.com/search?q=%2321-lxc-erstellen)
      * [2.2. Installation von Paketen](https://www.google.com/search?q=%2322-installation-von-paketen)
      * [2.3. LXC vorbereiten](https://www.google.com/search?q=%2323-lxc-vorbereiten)
  * [3. EMQX Installation](https://www.google.com/search?q=%233-emqx-installation)
      * [3.1. PKGBUILD erstellen](https://www.google.com/search?q=%2331-pkgbuild-erstellen)
      * [3.2. Abhängigkeiten installieren](https://www.google.com/search?q=%2332-abh%C3%A4ngigkeiten-installieren)
      * [3.3. Paket kompilieren und installieren](https://www.google.com/search?q=%2333-paket-kompilieren-und-installieren)
      * [3.4. Systemd-Dienst starten und aktivieren](https://www.google.com/search?q=%2334-systemd-dienst-starten-und-aktivieren)
  * [4. EMQX Cluster Konfiguration](https://www.google.com/search?q=%234-emqx-cluster-konfiguration)
      * [4.1. EMQX Cluster Nodes benennen](https://www.google.com/search?q=%2341-emqx-cluster-nodes-benennen)
      * [4.2. Erlang Cookie konfigurieren](https://www.google.com/search?q=%2342-erlang-cookie-konfigurieren)
      * [4.3. EMQX Cluster bilden](https://www.google.com/search?q=%2343-emqx-cluster-bilden)
  * [5. Let's Encrypt Zertifikate für EMQX](https://www.google.com/search?q=%235-lets-encrypt-zertifikate-f%C3%BCr-emqx)
      * [5.1. Certbot Installation und Konfiguration](https://www.google.com/search?q=%2351-certbot-installation-und-konfiguration)
      * [5.2. Zertifikate für EMQX konfigurieren](https://www.google.com/search?q=%2352-zertifikate-f%C3%BCr-emqx-konfigurieren)
  * [6. EMQX Dashboard und Basic Security](https://www.google.com/search?q=%236-emqx-dashboard-und-basic-security)
      * [6.1. Dashboard Zugang](https://www.google.com/search?q=%2361-dashboard-zugang)
      * [6.2. Standard-Benutzer und Passwörter ändern](https://www.google.com/search?q=%2362-standard-benutzer-und-passw%C3%B6rter-%C3%A4ndern)
  * [7. Firewall-Konfiguration (ufw)](https://www.google.com/search?q=%237-firewall-konfiguration-ufw)
      * [7.1. UFW installieren und konfigurieren](https://www.google.com/search?q=%2371-ufw-installieren-und-konfigurieren)
      * [7.2. Erforderliche Ports öffnen](https://www.google.com/search?q=%2372-erforderliche-ports-%C3%B6ffnen)
  * [8. GitHub Actions Integration (Automatischer Paket-Push)](https://www.google.com/search?q=%238-github-actions-integration-automatischer-paket-push)
      * [8.1. SSH-Schlüsselpaar generieren](https://www.google.com/search?q=%2381-ssh-schl%C3%BCsselpaar-generieren)
      * [8.2. GitHub Secrets konfigurieren](https://www.google.com/search?q=%2382-github-secrets-konfigurieren)
      * [8.3. GitHub Actions Workflow einrichten](https://www.google.com/search?q=%2383-github-actions-workflow-einrichten)
      * [8.4. Arch Linux Repository aufsetzen](https://www.google.com/search?q=%2384-arch-linux-repository-aufsetzen)
  * [9. Uptime Kuma Installation und Monitoring (Basis)](https://www.google.com/search?q=%239-uptime-kuma-installation-und-monitoring-basis)
      * [9.1. Uptime Kuma Installation (Docker)](https://www.google.com/search?q=%2391-uptime-kuma-installation-docker)
      * [9.2. Einfaches HTTP(s) Monitoring](https://www.google.com/search?q=%2392-einfaches-https-monitoring)
  * [10. EMQX Cluster Überwachung mit Uptime Kuma (Heartbeat)](https://www.google.com/search?q=%2310-emqx-cluster-%C3%BCberwachung-mit-uptime-kuma-heartbeat)
      * [10.1. Uptime Kuma: Push Monitor einrichten](https://www.google.com/search?q=%23101-uptime-kuma-push-monitor-einrichten)
      * [10.2. EMQX Konfiguration: Regel für MQTT-Heartbeat](https://www.google.com/search?q=%23102-emqx-konfiguration-regel-f%C3%BCr-mqtt-heartbeat)
      * [10.3. `systemd timer` für den Heartbeat einrichten](https://www.google.com/search?q=%23103-systemd-timer-f%C3%BCr-den-heartbeat-einrichten)
      * [10.4. Überprüfung in Uptime Kuma](https://www.google.com/search?q=%23104-%C3%BCberpr%C3%BCfung-in-uptime-kuma)

-----

## 1\. Einleitung

Diese Dokumentation führt dich durch die Installation, Konfiguration und Überwachung eines EMQX Clusters auf Arch Linux LXC Containern unter Proxmox. Es werden bewährte Methoden für Clustering, TLS-Verschlüsselung, Firewall-Konfiguration, automatische Updates mittels GitHub Actions und das Monitoring mit Uptime Kuma behandelt.

## 2\. Arch Linux LXC Container auf Proxmox aufsetzen

### 2.1. LXC erstellen

Erstelle zwei Arch Linux LXC Container in Proxmox. Dies dient der Hochverfügbarkeit und Skalierbarkeit deines EMQX Clusters.

### 2.2. Installation von Paketen

Auf beiden LXC-Containern benötigst du grundlegende Pakete. Aktualisiere zuerst das System und installiere dann die notwendigen Tools:

```bash
sudo pacman -Syu
sudo pacman -S base-devel git nano openssh
```

### 2.3. LXC vorbereiten

Stelle sicher, dass die Netzwerkkonfiguration in beiden LXCs korrekt ist (statische IPs empfohlen) und die Hostnamen korrekt gesetzt sind (z.B. `emqx1.fritz.box`, `emqx2.fritz.box`). Dies ist entscheidend für das Clustering.

## 3\. EMQX Installation

EMQX wird aus dem Quellcode gebaut, um die Kontrolle über die Version und Konfiguration zu haben.

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

### 3.2. Abhängigkeiten installieren

Installieren Sie die für den Bau notwendigen Abhängigkeiten:

```bash
sudo pacman -S erlang openssl ncurses git rebar3
```

### 3.3. Paket kompilieren und installieren

Navigieren Sie in das Verzeichnis mit Ihrem `PKGBUILD` und bauen Sie das Paket, dann installieren Sie es.

```bash
cd ~/emqx-pkgbuild
makepkg -si
```

### 3.4. Systemd-Dienst starten und aktivieren

Nach der Installation aktivieren und starten Sie den EMQX-Dienst:

```bash
sudo systemctl enable emqx
sudo systemctl start emqx
sudo systemctl status emqx
```

## 4\. EMQX Cluster Konfiguration

Konfiguriere beide EMQX-Nodes für den Cluster-Betrieb.

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

## 5\. Let's Encrypt Zertifikate für EMQX

Sichere die MQTT- und Dashboard-Verbindungen mit TLS/SSL-Zertifikaten von Let's Encrypt. Dies ist nur auf einem Node (z.B. `emqx1`) notwendig, da die Zertifikate dann auf den anderen Node repliziert werden können.

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

## 6\. EMQX Dashboard und Basic Security

### 6.1. Dashboard Zugang

Das EMQX Dashboard ist über Port 18083 (HTTP) oder 18084 (HTTPS, falls konfiguriert) erreichbar: `http://<EMQX_IP_ADDRESS>:18083`.

### 6.2. Standard-Benutzer und Passwörter ändern

**Ändere UNBEDINGT die Standardanmeldedaten des Dashboards\!**

  * Melde dich mit dem Standardbenutzer `admin` und Passwort `public` an.
  * Gehe zu **"System" -\> "Users"** und ändere das Passwort für den `admin`-Benutzer.
  * Erstelle bei Bedarf weitere Benutzer mit spezifischen Rollen.

## 7\. Firewall-Konfiguration (ufw)

Konfiguriere die Firewall (ufw) auf **jedem** EMQX-Node, um die notwendigen Ports zu öffnen.

### 7.1. UFW installieren und konfigurieren

```bash
sudo pacman -S ufw
sudo ufw enable
```

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

## 8\. GitHub Actions Integration (Automatischer Paket-Push)

Automatisiere das Bauen und Pushen deiner Arch Linux Pakete (z.B. des EMQX PKGBUILD) auf ein GitHub-basiertes Repository mit GitHub Actions.

### 8.1. SSH-Schlüsselpaar generieren

Generiere ein SSH-Schlüsselpaar, das GitHub Actions zum Pushen verwenden kann. **Verwenden Sie keine Passphrase für den privaten Schlüssel.**

```bash
ssh-keygen -t ed25519 -f ~/.ssh/github_actions_deploy -N ""
```

  * **Privater Schlüssel:** `~/.ssh/github_actions_deploy` (Dieser muss in GitHub Secrets hinterlegt werden).
  * **Öffentlicher Schlüssel:** `~/.ssh/github_actions_deploy.pub` (Dieser muss zum `authorized_keys` auf deinem LXC hinzugefügt werden).

### 8.2. GitHub Secrets konfigurieren

Füge den privaten Schlüssel als GitHub Secret in deinem Repository hinzu:

1.  Gehe zu deinem GitHub Repository -\> **Settings -\> Secrets and variables -\> Actions**.
2.  Klicke auf **"New repository secret"**.
3.  **Name:** `SSH_PRIVATE_KEY`
4.  **Value:** Füge den **kompletten Inhalt** deines privaten SSH-Schlüssels (`~/.ssh/github_actions_deploy`) ein, beginnend mit `-----BEGIN OPENSSH PRIVATE KEY-----` und endend mit `-----END OPENSSH PRIVATE KEY-----`.

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

## 9\. Uptime Kuma Installation und Monitoring (Basis)

Uptime Kuma ist ein benutzerfreundliches Überwachungstool, das dir den Status deiner Dienste anzeigt.

### 9.1. Uptime Kuma Installation (Docker)

Die einfachste Methode ist die Installation mittels Docker:

```bash
docker run -d --restart=always -p 3001:3001 -v uptime-kuma:/app/data --name uptime-kuma louislam/uptime-kuma:1
```

Uptime Kuma ist dann unter `http://<Your-Server-IP>:3001` erreichbar.

### 9.2. Einfaches HTTP(s) Monitoring

Füge einen grundlegenden Monitor für das EMQX Dashboard hinzu:

1.  Im Uptime Kuma Dashboard: **"Add New Monitor"**.
2.  **Monitor Type:** `HTTP(s)`.
3.  **Friendly Name:** "EMQX Dashboard".
4.  **URL:** `http://<EMQX_IP_ADDRESS>:18083` (oder HTTPS-URL, falls konfiguriert).
5.  **Heartbeat Interval:** Z.B. `60 Sekunden`.
6.  **Setup Notification:** Konfiguriere eine Benachrichtigungsmethode (E-Mail, Telegram etc.).

## 10\. EMQX Cluster Überwachung mit Uptime Kuma (Heartbeat)

Um die Verfügbarkeit deines EMQX-Clusters zu überwachen, kannst du Uptime Kuma als Heartbeat-Monitor verwenden. Da die direkte "Timed Event"-Funktion im EMQX Dashboard deiner Version möglicherweise nicht sichtbar ist, nutzen wir eine Kombination aus `systemd timer` auf dem EMQX-Server und der EMQX Regel-Engine.

#### 10.1. Uptime Kuma: Push Monitor einrichten

1.  Melde dich bei deinem Uptime Kuma Dashboard an.
2.  Klicke auf **"Add New Monitor"**.
3.  Wähle als **"Monitor Type"** die Option **"Push"**.
4.  Konfiguriere die Details:
      * **Friendly Name:** Z.B. "EMQX Broker Heartbeat - Node 1".
      * **Heartbeat Interval:** Setze dies auf `60 Sekunden`. Dieser Wert muss *länger* sein als das Intervall, mit dem EMQX den Webhook sendet.
      * **Expiration:** Z.B. `120 Sekunden`.
5.  Klicke auf **"Save"**.
6.  **Kopiere die "Push URL"**, die angezeigt wird (z.B. `https://your-uptime-kuma-url/api/push/<YOUR_API_KEY>`). Du benötigst diese später.

#### 10.2. EMQX Konfiguration: Regel für MQTT-Heartbeat

Da der `timer`-Block nicht direkt in der `emqx.conf` funktioniert und die "Timed Events" im Dashboard fehlen, erstellen wir eine Regel, die auf eine spezielle MQTT-Nachricht reagiert.

1.  **`emqx.conf` bereinigen:**
    Stelle sicher, dass der fehlerhafte `rule_engine { timer. ... }` Block **vollständig aus** deiner `/etc/emqx/emqx.conf` entfernt wurde.

    ```hocon
    # Dieser Block muss entfernt sein:
    # rule_engine {
    #   timer.uptime_kuma_heartbeat_timer {
    #     interval = "50s"
    #     event = "timer_event_emqx_heartbeat"
    #   }
    # }
    ```

    Danach EMQX neu starten: `sudo systemctl restart emqx`.

2.  **Im EMQX Dashboard (via Browser: `http://<EMQX_IP_ADDRESS>:18083`):**

      * Navigiere zu **"Rule Engine"** (oder **"Rules"**).
      * Klicke auf **"+ Create"**.
      * **Rule ID / Name:** Gib einen Namen ein, z.B. `uptime_kuma_mqtt_heartbeat_rule`.
      * **Data Inputs:** Klicke auf **"+ Add Input"**.
          * **Input Type:** Wähle `Messages`.
          * **Topic:** Gib das Topic ein, auf das der Heartbeat gesendet wird, z.B. `/emqx/heartbeat`. Klicke auf "Confirm".
      * **SQL Editor:** Die Abfrage sollte nun so aussehen:
        ```sql
        SELECT * FROM "messages" WHERE topic = '/emqx/heartbeat'
        ```
      * Klicke auf **"Next"**.

3.  **Action Outputs konfigurieren:**

      * Klicke auf **"+ Add Action"**.
      * **Type of Action:** Wähle **`HTTP Server`**.
      * **Connectors:** Da hier noch kein Connector existiert, klicke auf das **Plus-Symbol (`+`)** neben dem Dropdown-Feld.
          * Es öffnet sich ein neues Pop-up zur Erstellung eines Connectors.
          * **Name:** Gib einen Namen ein, z.B. `UptimeKuma_Webhook_Connector`.
          * **URL:** **Füge hier deine komplette Uptime Kuma Push URL ein\!** (z.B. `https://your-uptime-kuma-url/api/push/<YOUR_API_KEY>`).
          * **Method:** Wähle **`GET`**.
          * **Headers/Body:** Lasse diese Felder leer. Entferne auch den standardmäßig hinzugefügten `content-type` Header (Mülleimer-Icon), da er nicht benötigt wird.
          * Klicke auf **"Test Connectivity"** und dann auf **"Create"** (oder "Confirm") in diesem Pop-up.
      * Wähle nun den soeben erstellten Connector (`UptimeKuma_Webhook_Connector`) aus dem `Connectors`-Dropdown-Menü aus.
      * **URL Path:** Lasse dieses Feld **LEER**. Die vollständige URL ist bereits im Connector definiert.
      * **Method:** Wähle erneut **`GET`** (sollte vom Connector übernommen werden).
      * **Headers/Body:** Stelle sicher, dass hier keine unnötigen Header oder Body-Inhalte vorhanden sind.
      * Klicke auf **"Create"** (oder "Confirm") in diesem "Add Action" Fenster.
      * Klicke zuletzt auf **"Save"** (oder "Create Rule") im Hauptfenster der Regel.
      * Stelle sicher, dass die Regel in der "Rule List" **aktiviert** ist (grüner Schalter).

#### 10.3. `systemd timer` für den Heartbeat einrichten

Wir nutzen `systemd timer`, um regelmäßig eine MQTT-Nachricht an EMQX zu senden, welche die Regel auslöst.

1.  **Heartbeat-Skript erstellen:**
    Erstelle die Datei `/usr/local/bin/emqx_heartbeat.sh`:

    ```bash
    sudo nano /usr/local/bin/emqx_heartbeat.sh
    ```

    Inhalt:

    ```bash
    #!/bin/bash

    EMQX_TOPIC="/emqx/heartbeat"
    MESSAGE=""

    # Sende eine leere Nachricht an das Heartbeat-Topic mit emqx ctl
    /usr/lib/emqx/bin/emqx ctl pub \
      -t "$EMQX_TOPIC" \
      -p "$MESSAGE" \
      -q 0
    ```

    Mache das Skript ausführbar:

    ```bash
    sudo chmod +x /usr/local/bin/emqx_heartbeat.sh
    ```

2.  **Service-Unit-Datei erstellen:**
    Diese Datei beschreibt, was der Timer ausführen soll.

    ```bash
    sudo nano /etc/systemd/system/emqx-heartbeat.service
    ```

    Inhalt:

    ```ini
    [Unit]
    Description=EMQX Heartbeat to Uptime Kuma
    # Stellt sicher, dass Netzwerk und EMQX laufen, bevor der Service startet
    After=network.target emqx.service

    [Service]
    Type=oneshot
    ExecStart=/usr/local/bin/emqx_heartbeat.sh
    # Führe das Skript als der EMQX-Benutzer aus
    User=emqx
    # Führe das Skript als die EMQX-Gruppe aus
    Group=emqx
    StandardOutput=journal
    StandardError=journal
    ```

    Speichere die Datei.

3.  **Timer-Unit-Datei erstellen:**
    Diese Datei definiert, wann der Service ausgeführt werden soll.

    ```bash
    sudo nano /etc/systemd/system/emqx-heartbeat.timer
    ```

    Inhalt:

    ```ini
    [Unit]
    Description=Run EMQX Heartbeat every 50 seconds

    [Timer]
    OnUnitActiveSec=50s
    # Starte den Service 50 Sekunden nachdem er das letzte Mal aktiv war

    # Optional: Führt den Job nach einem Neustart aus, wenn er während des Ausfalls fällig gewesen wäre
    # Persistent=true

    [Install]
    WantedBy=timers.target
    ```

    Speichere die Datei.

4.  **`systemd`-Konfiguration neu laden, Timer aktivieren und starten:**

    ```bash
    sudo systemctl daemon-reload
    sudo systemctl enable emqx-heartbeat.timer
    sudo systemctl start emqx-heartbeat.timer
    ```

5.  **Status überprüfen:**

    ```bash
    sudo systemctl status emqx-heartbeat.timer
    sudo systemctl status emqx-heartbeat.service
    ```

    Beide sollten als `active` angezeigt werden.

6.  **Logs überprüfen:**

    ```bash
    journalctl -u emqx-heartbeat.service -f
    ```

    Hier solltest du sehen, dass das Skript alle 50 Sekunden ausgeführt wird.

#### 10.4. Überprüfung in Uptime Kuma

Nachdem alle Schritte ausgeführt wurden, sollte dein Uptime Kuma Monitor für den EMQX-Cluster auf **"Up"** wechseln und regelmäßig "Heartbeats" empfangen. Im EMQX Dashboard unter "Rule Engine" -\> "Rules" siehst du bei deiner erstellten Regel die Statistiken "Matched" und "Succeeded", die ansteigen sollten.
