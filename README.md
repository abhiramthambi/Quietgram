# Quietgram

Instagram without Reels, ads or the Explore doomscroll. Personal use only.

## No Mac? Build in the cloud, install from Windows

### 1. Build the IPA on GitHub (free)
1. Create a free GitHub account and a new **public** repository (public = free Mac build minutes).
2. Upload everything in this folder, keeping the structure (including `.github/workflows/build.yml`).
   Tip: the web uploader skips hidden folders, so create `.github/workflows/build.yml` via "Add file > Create new file" and paste it in.
3. Open the **Actions** tab. The build runs automatically (about 5 min).
4. When it goes green, open the run and download **Quietgram-ipa** under Artifacts. Unzip it to get `Quietgram.ipa`.

### 2. Install with Sideloadly (Windows)
1. Install **iTunes and iCloud from Apple's website** (not the Microsoft Store versions), then **Sideloadly**.
2. Plug in the iPhone, tap Trust on the phone.
3. Drag `Quietgram.ipa` into Sideloadly, enter your Apple ID, click Start.
4. iPhone: Settings > Privacy & Security > Developer Mode > On (restart).
5. iPhone: Settings > General > VPN & Device Management > trust your Apple ID.

### 3. The 7-day refresh
Free Apple ID apps expire after 7 days. Options:
- Re-run Sideloadly (tick its auto-refresh option and leave the PC on the same Wi-Fi), or
- Use **SideStore**: needs a computer once for setup, then refreshes on the phone itself.

## Changing filters
Edit `Quietgram/FilterSettings.swift` on GitHub, commit, and a new IPA builds automatically. Reinstall it with Sideloadly.

## Have a Mac after all?
`brew install xcodegen && xcodegen generate`, open `Quietgram.xcodeproj`, set your Team under Signing, Cmd+R.

## Pair with Screen Time
Settings > Screen Time > App Limits > add Instagram at 1 minute.
