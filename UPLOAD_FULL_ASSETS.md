# Upload full NEON RUSH 3D assets

1. Split the supplied source ZIP into chunks smaller than 20 MB. Name them exactly:
   - assets.part-00
   - assets.part-01
   - assets.part-02
   - assets.part-03
   - assets.part-04
   (Add further sequential parts if your split utility creates them.)
2. Upload every part to the repository root (same level as project.godot) using GitHub in a browser. Do not rename the files.
3. Open Actions -> Build Full NEON RUSH 3D APK -> Run workflow.
4. Wait for the run to finish. Download the artifact named NEON-RUSH-3D-FULL-Android.

The workflow joins the parts in numeric order, checks the ZIP, restores the complete Godot project, imports it, and exports an Android APK. If the workflow fails, open the failed run and share its log.

Important: do not upload these parts to the BlockNova or trading-app repositories. This repository is only for NEON RUSH 3D.
