import 'package:hive/hive.dart';

part 'file_model.g.dart';

@HiveType(typeId: 0)
class FileModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String path;

  @HiveField(3)
  DateTime lastOpened;

  @HiveField(4)
  int size;

  @HiveField(5)
  String type;

  FileModel({
    required this.id,
    required this.name,
    required this.path,
    required this.lastOpened,
    required this.size,
    required this.type,
  });

  // Helper getters
  String get displayName {
    return name.split('.').first;
  }

  String get extension {
    return name.split('.').last.toLowerCase();
  }

  String get formattedSize {
    if (size < 1024) {
      return '${size}B';
    } else if (size < 1024 * 1024) {
      return '${(size / 1024).toStringAsFixed(1)}KB';
    } else {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
  }

  String get formattedLastOpened {
    final now = DateTime.now();
    final difference = now.difference(lastOpened);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  bool get isExcelFile {
    return extension == 'xlsx' || extension == 'xls';
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'path': path,
      'lastOpened': lastOpened.toIso8601String(),
      'size': size,
      'type': type,
    };
  }

  factory FileModel.fromJson(Map<String, dynamic> json) {
    return FileModel(
      id: json['id'],
      name: json['name'],
      path: json['path'],
      lastOpened: DateTime.parse(json['lastOpened']),
      size: json['size'],
      type: json['type'],
    );
  }

  // Copy with method for updates
  FileModel copyWith({
    String? id,
    String? name,
    String? path,
    DateTime? lastOpened,
    int? size,
    String? type,
  }) {
    return FileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      lastOpened: lastOpened ?? this.lastOpened,
      size: size ?? this.size,
      type: type ?? this.type,
    );
  }

  @override
  String toString() {
    return 'FileModel(id: $id, name: $name, path: $path, lastOpened: $lastOpened, size: $size, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FileModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
