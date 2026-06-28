import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/calculator/calculator_engine.dart';
import 'group_expense_state.dart';

class GroupExpenseCubit extends Cubit<GroupExpenseState> {
  GroupExpenseCubit({CalculatorExpressionEngine? engine})
    : _engine = engine ?? CalculatorExpressionEngine(),
      super(GroupExpenseState.initial());

  final CalculatorExpressionEngine _engine;

  void focusMainAmount() {
    emit(state.copyWith(focusedTarget: 'amount', isCalculatorOpen: true));
  }

  void focusMemberAmount(String name) {
    emit(state.copyWith(focusedTarget: name, isCalculatorOpen: true));
  }

  void setCalculatorOpen(bool value) {
    emit(state.copyWith(isCalculatorOpen: value));
  }

  void editFocusedAmount(String key) {
    if (state.focusedTarget == 'amount') {
      final snapshot = _engine.apply(state.expression, key);
      emit(
        state.copyWith(
          expression: snapshot.expression,
          amountDisplay: snapshot.display,
          expressionPreview: snapshot.preview,
        ),
      );
      return;
    }

    final members = [
      for (final member in state.members)
        if (member.name == state.focusedTarget)
          _applyToMember(member, key)
        else
          member,
    ];
    emit(state.copyWith(members: members));
  }

  void doneFocusedAmount() {
    if (state.focusedTarget == 'amount') {
      final snapshot = _engine.apply(state.expression, 'done');
      emit(
        state.copyWith(
          expression: snapshot.expression,
          amountDisplay: snapshot.display,
          expressionPreview: snapshot.preview,
          isCalculatorOpen: false,
        ),
      );
      return;
    }
    final members = [
      for (final member in state.members)
        if (member.name == state.focusedTarget)
          _applyToMember(member, 'done')
        else
          member,
    ];
    emit(state.copyWith(members: members, isCalculatorOpen: false));
  }

  GroupMemberSplit _applyToMember(GroupMemberSplit member, String key) {
    final snapshot = _engine.apply(member.expression, key);
    return member.copyWith(
      expression: snapshot.expression,
      amountDisplay: snapshot.display,
      expressionPreview: snapshot.preview,
    );
  }

  void updateDescription(String value) =>
      emit(state.copyWith(description: value));

  void updateDate(DateTime value) => emit(state.copyWith(date: value));

  void updatePayer(String value) => emit(state.copyWith(payer: value));

  void updateSplitType(SplitType value) =>
      emit(state.copyWith(splitType: value));

  Future<void> save() async {
    if (!state.canSave) return;
    emit(state.copyWith(isLoading: true));
    await Future<void>.delayed(const Duration(milliseconds: 450));
    emit(state.copyWith(isLoading: false));
  }
}
