class ScanResult {
  final bool isSuccess;
  final bool isCancelled;
  final List<String>? filePaths;
  final String? errorMessage;

  ScanResult._({
    required this.isSuccess,
    required this.isCancelled,
    this.filePaths,
    this.errorMessage,
  });

  factory ScanResult.success(List<String> filePaths) {
    return ScanResult._(
      isSuccess: true,
      isCancelled: false,
      filePaths: filePaths,
    );
  }

  factory ScanResult.cancelled() {
    return ScanResult._(
      isSuccess: false,
      isCancelled: true,
    );
  }

  factory ScanResult.error(String errorMessage) {
    return ScanResult._(
      isSuccess: false,
      isCancelled: false,
      errorMessage: errorMessage,
    );
  }
}