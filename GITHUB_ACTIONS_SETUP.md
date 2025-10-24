# GitHub Actions iOS Build Setup

This project is configured to automatically build iOS apps using GitHub Actions with macOS runners (FREE and LEGAL).

## ✅ What's Been Set Up

1. **iOS folder structure** created with `flutter create --platforms=ios`
2. **GitHub Actions workflow** at `.github/workflows/ios-build.yml`
3. **.gitignore** properly configured to exclude build artifacts

## 🚀 How to Use

### Step 1: Create GitHub Repository

If you haven't already:

```powershell
# Initialize git (if not already initialized)
cd d:\Xampp\htdocs\camalig\gym_project
git init

# Add all files
git add .

# Commit
git commit -m "Initial commit with iOS support and GitHub Actions"

# Create a new repository on GitHub, then:
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git
git branch -M main
git push -u origin main
```

### Step 2: Automatic Build Triggers

The iOS build will automatically run when:
- ✅ You push to `main`, `master`, or `develop` branches
- ✅ You create a pull request
- ✅ You manually trigger it from GitHub Actions tab

### Step 3: Monitor the Build

1. Go to your GitHub repository
2. Click **Actions** tab
3. Watch the build progress in real-time
4. Download build artifacts when complete

### Step 4: Download the Built App

After a successful build:

1. Go to the **Actions** tab
2. Click on the completed workflow run
3. Scroll to **Artifacts** section
4. Download `ios-build-artifacts.zip`
5. Extract to get the `Runner.app` file

## 📦 What Gets Built

The workflow creates:
- **Debug build** (without code signing) - for testing
- **Release build attempt** (may fail without certificates)
- **Build artifacts** uploaded and stored for 30 days

## ⚠️ Important Notes

### Code Signing (For App Store/TestFlight)

The current workflow builds **unsigned apps** (good for testing). To distribute via App Store or TestFlight, you need:

1. **Apple Developer Account** ($99/year)
2. **Certificates and Provisioning Profiles**
3. **GitHub Secrets** configured:
   - `APPLE_CERTIFICATE`
   - `APPLE_CERTIFICATE_PASSWORD`
   - `PROVISIONING_PROFILE`
   - `KEYCHAIN_PASSWORD`

### To Add Code Signing Later:

Add this step before the release build in `.github/workflows/ios-build.yml`:

```yaml
- name: Import Signing Certificate
  env:
    CERTIFICATE_BASE64: ${{ secrets.APPLE_CERTIFICATE }}
    CERTIFICATE_PASSWORD: ${{ secrets.APPLE_CERTIFICATE_PASSWORD }}
    KEYCHAIN_PASSWORD: ${{ secrets.KEYCHAIN_PASSWORD }}
  run: |
    CERTIFICATE_PATH=$RUNNER_TEMP/build_certificate.p12
    KEYCHAIN_PATH=$RUNNER_TEMP/app-signing.keychain-db
    
    echo -n "$CERTIFICATE_BASE64" | base64 --decode -o $CERTIFICATE_PATH
    
    security create-keychain -p "$KEYCHAIN_PASSWORD" $KEYCHAIN_PATH
    security set-keychain-settings -lut 21600 $KEYCHAIN_PATH
    security unlock-keychain -p "$KEYCHAIN_PASSWORD" $KEYCHAIN_PATH
    
    security import $CERTIFICATE_PATH -P "$CERTIFICATE_PASSWORD" -A -t cert -f pkcs12 -k $KEYCHAIN_PATH
    security list-keychain -d user -s $KEYCHAIN_PATH
```

## 🔧 Customization

### Change Flutter Version

Edit `.github/workflows/ios-build.yml`:

```yaml
flutter-version: '3.24.0' # Change to your desired version
```

### Add More Branches

```yaml
on:
  push:
    branches: [ main, master, develop, staging, production ]
```

### Skip Tests

Remove or comment out the test step:

```yaml
# - name: Run Tests
#   run: flutter test
```

## 📱 Testing the Build

### On iOS Simulator (Mac required):

```bash
# Install on simulator
xcrun simctl install booted path/to/Runner.app

# Launch
xcrun simctl launch booted com.example.camaligGym
```

### On Physical Device:

You need:
1. Apple Developer account
2. Code-signed build
3. Xcode to install via USB

## 🆓 Free Tier Limits

GitHub Actions free tier includes:
- **2,000 minutes/month** for private repos
- **Unlimited** for public repos
- macOS runners use **10x multiplier** (20 min build = 200 min used)

**Tip:** Make your repo public to get unlimited builds!

## 🐛 Troubleshooting

### Build Fails on CocoaPods

Add this before `pod install`:

```yaml
- name: Update CocoaPods Repo
  run: pod repo update
```

### Build Fails on Dependencies

Clear cache by adding:

```yaml
- name: Clean Flutter
  run: flutter clean
```

### Need Different Xcode Version

```yaml
- name: Select Xcode Version
  run: sudo xcode-select -s /Applications/Xcode_15.0.app/Contents/Developer
```

## 📚 Next Steps

1. ✅ **Push to GitHub** to trigger first build
2. ✅ **Monitor Actions tab** to see build progress
3. ✅ **Download artifacts** to test the build
4. 📱 Get Apple Developer account for code signing (optional)
5. 🚀 Configure TestFlight for beta testing (optional)

## 🎯 Current Build Status

After pushing to GitHub, you'll see a badge showing build status. Add to your README:

```markdown
![iOS Build](https://github.com/YOUR_USERNAME/YOUR_REPO/workflows/iOS%20Build/badge.svg)
```

## 💡 Alternative Services

If you need more build minutes or advanced features:

- **Codemagic** - 500 min/month free, Flutter-specific
- **Bitrise** - 200 builds/month free
- **CircleCI** - 6,000 min/month free (30x multiplier for macOS)
- **Travis CI** - Credits-based pricing

---

**Ready to build!** Push your code to GitHub and watch the magic happen. 🎉
