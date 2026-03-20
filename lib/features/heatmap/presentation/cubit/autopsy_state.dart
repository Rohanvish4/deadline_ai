class AutopsyState {
  final bool isSubmitting;
  final String? errorMessage;
  final Map<String, dynamic>? response;

  const AutopsyState({
    this.isSubmitting = false,
    this.errorMessage,
    this.response,
  });

  AutopsyState copyWith({
    bool? isSubmitting,
    String? errorMessage,
    Map<String, dynamic>? response,
  }) {
    return AutopsyState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
      response: response ?? this.response,
    );
  }
}
