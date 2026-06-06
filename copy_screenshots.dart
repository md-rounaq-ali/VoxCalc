import 'dart:io';

void main() async {
  print("🚀 Starting VoxCalc Screenshot Importer...");

  final String sourceDir = "C:\\Users\\Md Rounaq Ali\\.gemini\\antigravity\\brain\\19952dad-40d6-4491-a51e-3758312b49cf";
  final String targetDir = "C:\\VoxCalc\\screenshots";

  // Create target directory if it doesn't exist
  final Directory dir = Directory(targetDir);
  if (!await dir.exists()) {
    await dir.create(recursive: true);
    print("📁 Created screenshots folder at: $targetDir");
  }

  // Source files mapping to target files
  final Map<String, String> filesMap = {
    "media__1779211159385.jpg": "keypad_dark.jpg",
    "media__1779211165460.jpg": "voice_dark.jpg",
    "media__1779211170335.jpg": "drawer_dark.jpg",
  };

  int successCount = 0;

  for (var entry in filesMap.entries) {
    final File srcFile = File("$sourceDir\\${entry.key}");
    final File destFile = File("$targetDir\\${entry.value}");

    if (await srcFile.exists()) {
      await srcFile.copy(destFile.path);
      print("✅ Successfully imported: ${entry.value}");
      successCount++;
    } else {
      print("⚠️ Source file not found: ${entry.key}");
    }
  }

  if (successCount == 3) {
    print("\n🎉 SUCCESS! All 3 device screenshots are imported into: C:\\VoxCalc\\screenshots\\");
    print("Now you are ready to commit and push them to your GitHub profile!");
  } else {
    print("\n⚠️ Imported $successCount out of 3 screenshots. Please check the paths.");
  }
}
