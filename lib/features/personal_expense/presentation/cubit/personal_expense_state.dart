enum PersonalExpenseType { expense, income }

class PersonalExpenseState {
  const PersonalExpenseState({
    required this.type,
    required this.expression,
    required this.amountDisplay,
    required this.date,
    this.expressionPreview,
    this.category,
    this.description = '',
    this.isCalculatorOpen = true,
    this.isAmountFocused = true,
    this.isLoading = false,
    this.error,
  });

  factory PersonalExpenseState.initial() => PersonalExpenseState(
    type: PersonalExpenseType.expense,
    expression: '',
    amountDisplay: '',
    date: DateTime.now(),
  );

  final PersonalExpenseType type;
  final String expression;
  final String amountDisplay;
  final String? expressionPreview;
  final String? category;
  final String description;
  final DateTime date;
  final bool isCalculatorOpen;
  final bool isAmountFocused;
  final bool isLoading;
  final String? error;

  bool get hasAmount => expression.isNotEmpty;
  bool get canSave => hasAmount && !isLoading;

  PersonalExpenseState copyWith({
    PersonalExpenseType? type,
    String? expression,
    String? amountDisplay,
    Object? expressionPreview = _unset,
    Object? category = _unset,
    String? description,
    DateTime? date,
    bool? isCalculatorOpen,
    bool? isAmountFocused,
    bool? isLoading,
    Object? error = _unset,
  }) {
    return PersonalExpenseState(
      type: type ?? this.type,
      expression: expression ?? this.expression,
      amountDisplay: amountDisplay ?? this.amountDisplay,
      expressionPreview: expressionPreview == _unset
          ? this.expressionPreview
          : expressionPreview as String?,
      category: category == _unset ? this.category : category as String?,
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
