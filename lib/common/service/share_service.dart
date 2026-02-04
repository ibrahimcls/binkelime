import 'package:binkelime/model/word.dart';
import 'package:share_plus/share_plus.dart';

class ShareService {
  // Sadece düz metin paylaşımı
  static Future<void> shareText(String text) async {
    await Share.share(text);
  }

  // Senin Word modeline özel paylaşım formatı
  static Future<void> shareWord(Word word) async {
    final String message = """
💡 Doğru Kullanım Rehberi

❌ Yanlış: ${word.instead}
✅ Doğru: ${word.use} 

📝 Not: ${word.description}
  
#kelime #doğrutürkçe
""";

    await Share.share(message, subject: 'Kelime Paylaşımı');
  }
}
