enum SplitType { equal, custom }

class GroupMemberSplit {
  const GroupMemberSplit({
    required this.name,
    this.expression = '',
    this.amountDisplay = '',
    this.expressionPreview,
  });

  final String name;
  final String expression;
  final String amountDisplay;
  final String? expressionPreview;

  GroupMemberSplit copyWith({
    String? expression,
    String? amountDisplay,
    Object? expressionPreview = _unset,
  }) {
    return GroupMemberSplit(
      name: name,
      expression: expression ?? this.expression,
      amountDisplay: amountDisplay ?? this.amountDisplay,
      expressionPreview: expressionPreview == _unset
          ? this.expressionPreview
          : expressionPreview as String?,
    );
  }
}

class GroupExpenseState {
  const GroupExpenseState({
    required this.expression,
    required this.amountDisplay,
    required this.date,
    required this.members,
    this.expressionPreview,
    this.description = '',
    this.payer = 'Anita',
    this.splitType = SplitType.equal,
    this.focusedTarget = 'amount',
    this.isCalculatorOpen = true,
    this.isLoading = false,
    this.error,
  });

  factory GroupExpenseState.initial() => GroupExpenseState(
    expression: '',
    amountDisplay: '',
    date: DateTime.now(),
    members: const [
      GroupMemberSplit(name: 'Anita'),
      GroupMemberSplit(name: 'Bikash'),
      GroupMemberSplit(name: 'Chandra'),
    ],
  );

  final String expression;
  final String amountDisplay;
  final String? expressionPreview;
  final String description;
  final DateTime date;
  final String payer;
  final SplitType splitType;
  final List<GroupMemberSplit> members;
  final String focusedTarget;
  final bool isCalculatorOpen;
  final bool isLoading;
  final String? error;

  bool get hasAmount => expression.isNotEmpty;
  bool get canSave => hasAmount && !isLoading;
  bool get isMainFocused => focusedTarget == 'amount' && isCalculatorOpen;
  double get amountValue => double.tryParse(amountDisplay) ?? 0;
  double get equalShare => members.isEmpty ? 0 : amountValue / members.length;

  GroupMemberSplit? memberByName(String name) {
    for (final member in members) {
      if (member.name == name) return member;
    }
    return null;
  }

  GroupExpenseState copyWith({
    String? expression,
    String? amountDisplay,
    Object? expressionPreview = _unset,
    String? description,
    DateTime? date,
    String? payer,
    SplitType? splitType,
    List<GroupMemberSplit>? members,
    String? focusedTarget,
    bool? isCalculatorOpen,
    bool? isLoading,
    Object? error = _unset,
  }) {
    return GroupExpenseState(
      expression: expression ?? this.expression,
      amountDisplay: amountDisplay ?? this.amountDisplay,
      expressionPreview: expressionPreview == _unset
          ? this.expressionPreview
          : expressionPreview as String?,
      description: description ?? this.description,
      date: date ?? this.date,
      payer: payer ?? this.payer,
      splitType: splitType ?? this.splitType,
      members: members ?? this.members,
      focusedTarget: focusedTarget ?? this.focusedTarget,
      isCalculatorOpen: isCalculatorOpen ?? this.isCalculatorOpen,
      isLoading: isLoading ?? this.isLoading,
      error: error == _unset ? this.error : error as String?,
    );
  }
}

const _unset = Object();
