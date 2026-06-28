import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/calculator/calculator_engine.dart';
import 'personal_expense_state.dart';

class PersonalExpenseCubit extends Cubit<PersonalExpenseState> {
  PersonalExpenseCubit({CalculatorExpressionEngine? engine})
    : _engine = engine ?? CalculatorExpressionEngine(),
      super(PersonalExpenseState.initial());

  final CalculatorExpressionEngine _engine;

  void selectType(PersonalExpenseType type) => emit(state.copyWith(type: type));

  void setCalculatorOpen(bool value) {
    emit(state.copyWith(isCalculatorOpen: value, isAmountFocused: value));
  }

  void editAmount(String key) {
    final snapshot = _engine.apply(state.expression, key);
    emit(
      state.copyWith(
        expression: snapshot.expression,
        amountDisplay: snapshot.display,
        expressionPreview: snapshot.preview,
      ),
    );
  }

  void doneAmount() {
    final snapshot = _engine.apply(state.expression, 'done');
    emit(
      state.copyWith(
        expression: snapshot.expression,
        amountDisplay: snapshot.display,
        expressionPreview: snapshot.preview,
        isCalculatorOpen: false,
        isAmountFocused: false,
      ),
    );
  }

  void selectCategory(String value) => emit(state.copyWith(category: value));

  void updateDescription(String value) =>
      emit(state.copyWith(description: value));

  void updateDate(DateTime value) => emit(state.copyWith(date: value));

  Future<void> save() async {
    if (!state.canSave) return;
    emit(state.copyWith(isLoading: true));
    await Future<void>.delayed(const Duration(milliseconds: 450));
    emit(state.copyWith(isLoading: false));
  }
}
