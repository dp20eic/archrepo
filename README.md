# Mein persönliches Arch Linux Pacman Repository

Dieses Repository hostet individuell erstellte und/oder angepasste Arch Linux Pakete.
Es dient primär zur Bereitstellung dieser Pakete für meine Arch Linux Container (LXC) unter Proxmox
und andere Arch Linux Systeme, die ich verwalte.

## Enthaltene Pakete

Eine automatisch generierte Liste der derzeit im Repository verfügbaren Pakete finden Sie unter:
[Paketliste ansehen](https://dp20eic.github.io/archrepo/packages/package_list.txt)

## Repository in Pacman hinzufügen

Um dieses Repository in Ihrer `/etc/pacman.conf` zu nutzen, fügen Sie den folgenden Block **am Anfang** der Datei hinzu:

> ```bash
> [archrepo]
> SigLevel = Optional TrustAll
> Server = https://dp20eic.github.io/archrepo/packages/
> ```

Danach können Sie Ihre Paketdatenbanken synchronisieren und Pakete installieren:

> ```bash
> sudo pacman -Sy
> sudo pacman -S <PAKETNAME>
> Beispiel: sudo pacman -S emqx-broker-debian
> ```


Kontakt
Bei Fragen oder Problemen wenden Sie sich bitte an 0815_Michel@web.de.
