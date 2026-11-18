# NEON RUSH 3D

A standalone futuristic 3D parkour prototype built with Godot 4.3.

## Project isolation
This repository is independent from BlockNova and any trading application. Android application ID: `com.neonrush.parkour`.

## Current prototype
- Procedural neon platform course
- Third-person player and follow camera
- Keyboard movement, sprint, jump and double jump, slide
- On-screen Android touch controls
- Moving platforms and run timer

## Android APK
An Android export preset and GitHub Actions workflow are included. Every push to `main` that changes game source or export configuration starts an APK build. The APK is published as a workflow artifact named `NEON-RUSH-3D-Android`.

Open the repository's **Actions** tab, select the latest **Build Android APK** run, and download the artifact when the run succeeds.

## Build locally
Open `project.godot` in Godot 4.3, install Android export templates, configure the Android SDK and JDK 17, then export using the **Android** preset.

## Not yet implemented / verified
Online multiplayer, accounts, leaderboards, final character animations, and full device testing are not yet complete. The first APK workflow must pass before an installable build can be claimed.
