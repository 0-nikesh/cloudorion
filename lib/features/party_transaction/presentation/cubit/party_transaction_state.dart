enum PartyTransactionType { received, given }

class PartyTransactionState {
  const PartyTransactionState({
    required this.type,
    required this.expression,
    required this.amountDisplay,
    required this.date,
    this.expressionPreview,
    this.description = '',
    this.isCalculatorOpen = true,
    this.isAmountFocused = true,
    this.isLoading = false,
    this.error,
  });

  factory PartyTransactionState.initial() => PartyTransactionState(
    type: PartyTransactionType.received,
    expression: '',
    amountDisplay: '',
    date: DateTime.now(),
  );

  final PartyTransactionType type;
  final String expression;
  final String amountDisplay;
  final String? expressionPreview;
  final String description;
  final DateTime date;
  final bool isCalculatorOpen;
  final bool isAmountFocused;
  final bool isLoading;
  final String? error;

  bool get hasAmount => expression.isNotEmpty;
  bool get canSave => hasAmount && !isLoading;

  PartyTransactionState copyWith({
    PartyTransactionType? type,
    String? expression,
    String? amountDisplay,
    Object? expressionPreview = _unset,
    String? description,
    DateTime? date,
    bool? isCalculatorOpen,
    bool? isAmountFocused,
    bool? isLoading,
    Object? error = _unset,
  }) {
    return PartyTransactionState(
      type: type ?? this.type,
      expression: expression ?? this.expression,
      amountDisplay: amountDisplay ?? this.amountDisplay,
      expressionPreview: expressionPreview == _unset
          ? this.expressionPreview
          : expressionPreview as String?,
      description: description ?? this.description,
      date: date ?? this.date,
      isCalculatorOpen: isCalculatorOpen ?? this.isCalculatorOpen,
      isAmountFocused: isAmountFocused ?? this.isAmountFocused,
      isLoading: isLoading ?? this.isLoading,
      error: error == _unset ? this.error : error as String?,
    );
  }
}

const _unset = Object();
