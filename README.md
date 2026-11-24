# Flycastrophe / muOS Brick – experimenteller Build 0.1
Kein fertiger Core. Der Workflow lädt den auf aa6b3800f49a7a7155d04a3f4a15a0e47d58bbe6 fixierten GPL-2.0-Quellcode samt Submodulen und baut eine separate ARM64-Libretro-Datei. GLES3, kein Vulkan, Cortex-A53, O2, kein PGO. Die allgemeine Ubuntu-22.04-Cross-Toolchain ist ein erster Versuch, nicht das bestätigte muOS-SDK; ABI und Grafiktreiber müssen auf dem Brick geprüft werden. Statische C++-Runtime reduziert externe Abhängigkeiten, ersetzt keine glibc-Kompatibilitätsprüfung.

## GitHub
Leeres Repository erstellen, alle Dateien einschließlich .github/workflows/build.yml hochladen (bei Browser-Upload Workflow ggf. separat über Add file / Create new file mit exakt diesem Pfad anlegen). Unter Actions den Workflow auswählen und Run workflow klicken. Bei Erfolg das Artefakt und bei Fehler build-log herunterladen. Für lokale Linux-Builds die im Workflow genannten Pakete installieren und bash build.sh starten. Optional CROSS_PREFIX und TARGET_ROOT für ein vorhandenes muOS-SDK setzen.

## Test
Noch nicht als muOS-Archiv installieren. Zuerst die ABI-Berichte prüfen und die Core-Datei über RetroArch separat laden. Den bestehenden Flycast nicht ersetzen. Für die endgültige Core-Zuordnung muss das originale core.json des Geräts erweitert werden, nicht durch eine unvollständige Datei ersetzt werden. Die .info-Datei ist vorläufig; Erweiterungen sind nicht einzeln getestet.

Upstream: https://github.com/Helaas/Flycastrophe (GPL-2.0), Build-Referenz: https://github.com/Helaas/Flycastrophe-pak. Bei Weitergabe des kompilierten Cores GPL-Pflichten beachten und entsprechenden Quellcode samt Build-Skripten bereitstellen.
