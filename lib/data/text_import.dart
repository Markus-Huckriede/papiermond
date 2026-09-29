import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;
import 'package:xml/xml.dart';

class ImportedText {
  const ImportedText(this.title, this.body);
  final String title;
  final String body;
}

class UnsupportedFormat implements Exception {
  const UnsupportedFormat(this.extension);
  final String extension;
}

/// Dateiendungen, die als Text importiert werden können.
const importableExtensions = ['txt', 'md', 'markdown', 'docx', 'odt'];

/// Liest Text aus .txt, .md, .docx (Word, auch aus Pages exportiert) und .odt.
/// Pages-Dateien (.pages) sind ein internes Format: dort in Pages
/// "Ablage > Exportieren > Word" wählen.
ImportedText parseDocument(String filename, Uint8List bytes) {
  final ext = p.extension(filename).toLowerCase().replaceFirst('.', '');
  final title = p.basenameWithoutExtension(filename);
  final String body;
  switch (ext) {
    case 'txt':
    case 'md':
    case 'markdown':
      body = utf8.decode(bytes, allowMalformed: true);
    case 'docx':
      body = _zipXmlText(bytes, 'word/document.xml', _docxParagraphs);
    case 'odt':
      body = _zipXmlText(bytes, 'content.xml', _odtParagraphs);
    default:
      throw UnsupportedFormat(ext);
  }
  return ImportedText(title, body.replaceAll('\r\n', '\n').trim());
}

String _zipXmlText(
    Uint8List bytes, String part, List<String> Function(XmlDocument) extract) {
  final archive = ZipDecoder().decodeBytes(bytes);
  final file = archive.findFile(part);
  if (file == null) throw const FormatException('Dokument enthält keinen Text');
  final doc = XmlDocument.parse(utf8.decode(file.readBytes()!));
  return extract(doc).join('\n');
}

List<String> _docxParagraphs(XmlDocument doc) {
  return [
    for (final para in doc.descendants.whereType<XmlElement>().where(
        (e) => e.name.qualified == 'w:p'))
      _docxRuns(para),
  ];
}

String _docxRuns(XmlElement para) {
  final b = StringBuffer();
  for (final e in para.descendants.whereType<XmlElement>()) {
    switch (e.name.qualified) {
      case 'w:t':
        b.write(e.innerText);
      case 'w:tab':
        b.write('\t');
      case 'w:br':
        b.write('\n');
    }
  }
  return b.toString();
}

List<String> _odtParagraphs(XmlDocument doc) {
  return [
    for (final para in doc.descendants.whereType<XmlElement>().where(
        (e) => e.name.qualified == 'text:p' || e.name.qualified == 'text:h'))
      _odtText(para),
  ];
}

String _odtText(XmlNode node) {
  final b = StringBuffer();
  for (final c in node.children) {
    if (c is XmlText) {
      b.write(c.value);
    } else if (c is XmlElement) {
      switch (c.name.qualified) {
        case 'text:s':
          b.write(' ' * (int.tryParse(c.getAttribute('text:c') ?? '') ?? 1));
        case 'text:tab':
          b.write('\t');
        case 'text:line-break':
          b.write('\n');
        default:
          b.write(_odtText(c));
      }
    }
  }
  return b.toString();
}
