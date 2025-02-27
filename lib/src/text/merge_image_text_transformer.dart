import 'package:enough_mail/mime.dart';
import 'package:enough_mail_html/enough_mail_html.dart';
import 'package:enough_mail_html/src/dom/image_transformers.dart';

import 'text_search.dart';

class MergeAttachedImageTextTransformer extends TextTransformer {
  const MergeAttachedImageTextTransformer();

  @override
  String transform(
      String text, MimeMessage message, TransformConfiguration configuration) {
    final search = TextSearchIterator('[cid:', text, endSearchPattern: ']');
    String? nextImageDefinition;
    while ((nextImageDefinition = search.next()) != null) {
      var cid = nextImageDefinition!
          .substring('[cid:'.length, nextImageDefinition.length - 2);
      if (!cid.startsWith('<')) {
        cid = '<$cid>';
      }
      final part = message.getPartWithContentId(cid);
      if (part != null) {
        final contentType = part.getHeaderContentType();
        final mediaType = contentType?.mediaType;
        final data =
            ImageTransformer.toImageData(part, mediaType, configuration);
        final linkCid = Uri.encodeComponent(cid.substring(1, cid.length - 1));
        text = text.replaceFirst(nextImageDefinition,
            '<a href="cid://$linkCid"><img src="$data" alt="${part.getHeaderContentDisposition()?.filename}"/></a>');
      }
    }
    return text;
  }
}
