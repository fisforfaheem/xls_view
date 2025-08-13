# Play Store Release Guide - XLSX View

## 📱 App Information
- **App Name**: XLSX View
- **Package Name**: `com.apexcollc.xlsxfileviewer.xlsxreader.smartxlsxviewer`
- **Version**: 1.0.0+1
- **Developer**: Apex & Co LLC

## 🔐 Keystore Information

### Keystore File Location
```
android/app/upload-keystore.jks
```

### Credentials
- **Keystore Password**: `password`
- **Key Alias**: `upload`
- **Key Password**: `password`
- **Validity**: 10,000 days (approximately 27 years)

### Keystore Details
- **Algorithm**: RSA
- **Key Size**: 2048 bits
- **Certificate Type**: Self-signed (SHA256withRSA)

## 📦 Build Information

### App Bundle Location
```
build/app/outputs/bundle/release/app-release.aab
```

### Build Commands
```bash
# Clean build (if needed)
flutter clean
flutter pub get

# Generate app bundle
flutter build appbundle
```

### Build Size
- **App Bundle Size**: 42.8MB

## 🚀 Release Checklist

### Pre-Release
- [x] Keystore generated and secured
- [x] App bundle built successfully
- [x] Version number updated in pubspec.yaml
- [x] App icons configured for all platforms
- [x] Company name updated to "Apex & Co LLC"
- [x] Recent files duplicate issue fixed

### Play Store Requirements
- [ ] Create Play Store Console account
- [ ] Upload app bundle (.aab file)
- [ ] Add app screenshots (phone, tablet, TV if applicable)
- [ ] Write app description
- [ ] Set up content rating
- [ ] Configure app pricing (free/paid)
- [ ] Add privacy policy URL
- [ ] Set up app categories and tags

## 📝 App Description Template

### Short Description
A modern Flutter XLSX file reader app with clean UI and file management features.

### Full Description
```
📊 XLSX View - Smart Excel File Viewer

Transform the way you view Excel files on your mobile device! XLSX View is a beautiful, intuitive app designed to make reading .xlsx and .xls files effortless and enjoyable.

✨ KEY FEATURES:
• 📁 Easy file browsing and selection
• 📊 Clean, readable spreadsheet display
• 🔍 Search functionality within files
• 📱 Modern, responsive design
• 🕐 Recent files tracking
• 📤 Share files with others
• 🌙 Beautiful UI with smooth animations

🎯 PERFECT FOR:
• Business professionals
• Students and researchers
• Anyone who works with Excel files
• Mobile productivity enthusiasts

🔧 TECHNICAL HIGHLIGHTS:
• Built with Flutter for optimal performance
• Supports both .xlsx and .xls formats
• Lightweight and fast
• Cross-platform compatibility

📱 DEVELOPED BY APEX & CO LLC
Your trusted partner for IT & HR solutions, bringing you innovative mobile applications that enhance productivity and simplify your digital workflow.

Download XLSX View today and experience the future of mobile Excel file viewing!
```

## 🖼️ Required Assets

### App Icons
- [x] Android: Generated from `assets/icons/Xlsx. Logo.png`
- [x] iOS: Generated from `assets/icons/Xlsx. Logo.png`
- [x] Web: Generated from `assets/icons/Xlsx. Logo.png`

### Screenshots Needed
- [ ] Home screen showing file picker
- [ ] File viewer displaying Excel data
- [ ] Recent files list
- [ ] About screen
- [ ] File sharing functionality

## 🔒 Security Notes

### Keystore Security
⚠️ **IMPORTANT**: Keep the keystore file and credentials secure!

- **Backup Location**: Store a backup of `upload-keystore.jks` in a secure location
- **Access Control**: Only authorized team members should have access
- **Version Control**: Never commit keystore files to public repositories

### App Signing
The app is configured for automatic signing using the keystore:
- Release builds will be automatically signed
- Debug builds use Flutter's default debug keystore

## 🏪 Play Store Categories
- **Primary Category**: Productivity
- **Secondary Category**: Business
- **Content Rating**: Everyone
- **Target Audience**: Business professionals, students, general users

## 📊 App Permissions
The app requests the following permissions:
- **Storage Access**: To read Excel files from device storage
- **Internet**: For sharing functionality and potential updates

## 🔄 Update Process

### For Future Updates
1. Update version in `pubspec.yaml`
2. Build new app bundle: `flutter build appbundle`
3. Upload new .aab file to Play Store Console
4. Update release notes
5. Submit for review

### Version Naming Convention
- Major releases: 2.0.0+1, 3.0.0+1
- Minor releases: 1.1.0+1, 1.2.0+1
- Patches: 1.0.1+1, 1.0.2+1

## 📞 Support Information
- **Developer**: Apex & Co LLC
- **Support Email**: [Add your support email]
- **Website**: [Add your website]

## 📅 Release Timeline
- **Development Completed**: [Current Date]
- **Internal Testing**: [Add dates]
- **Play Store Submission**: [Add date]
- **Expected Release**: [Add expected date]

---

**Last Updated**: $(date)
**Generated for**: XLSX View v1.0.0+1
**Developer**: Apex & Co LLC
