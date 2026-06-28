import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../shared/layout/calculator_aware_scaffold.dart';
import '../../../shared/widgets/amount_input_field.dart';
import '../../../shared/widgets/progressive_reveal.dart';
import '../../../shared/widgets/secondary_form_field.dart';
import 'cubit/personal_expense_cubit.dart';
import 'cubit/personal_expense_state.dart';

class PersonalExpensePage extends StatelessWidget {
  const PersonalExpensePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PersonalExpenseCubit(),
      child: const _PersonalExpenseView(),
    );
  }
}

class _PersonalExpenseView extends StatefulWidget {
  const _PersonalExpenseView();

  @override
  State<_PersonalExpenseView> createState() => _PersonalExpenseViewState();
}

class _PersonalExpenseViewState extends State<_PersonalExpenseView> {
  final _scaffoldKey = GlobalKey<CalculatorAwareScaffoldState>();
  final _descriptionFocus = FocusNode();

  @override
  void dispose() {
    _descriptionFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = context.select(
      (PersonalExpenseCubit cubit) =>
          cubit.state.type == PersonalExpenseType.expense
          ? AppColors.expense
          : AppColors.income,
    );
    return BlocBuilder<PersonalExpenseCubit, PersonalExpenseState>(
      buildWhen: (p, c) =>
          p.isCalculatorOpen != c.isCalculatorOpen ||
          p.isLoading != c.isLoading ||
          p.hasAmount != c.hasAmount ||
          p.type != c.type ||
          p.category != c.category,
      builder: (context, state) {
        final cubit = context.read<PersonalExpenseCubit>();
        return CalculatorAwareScaffold(
          key: _scaffoldKey,
          title: 'Add Personal Expense',
          accentColor: accent,
          saveLabel: 'Save Expense',
          calculatorOpen: state.isCalculatorOpen,
          saveEnabled: state.canSave,
          isSaveLoading: state.isLoading,
          onSave: cubit.save,
          onCalculatorKey: cubit.editAmount,
          onCalculatorDone: cubit.doneAmount,
          onCalculatorVisibilityChanged: cubit.setCalculatorOpen,
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _TypeSwitcher(accent: accent),
              const SizedBox(height: 18),
              BlocBuilder<PersonalExpenseCubit, PersonalExpenseState>(
                buildWhen: (p, c) =>
                    p.amountDisplay != c.amountDisplay ||
                    p.expressionPreview != c.expressionPreview ||
                    p.isAmountFocused != c.isAmountFocused,
                builder: (context, amountState) {
                  return AmountInputField(
                    amountDisplay: amountState.amountDisplay,
                    expressionPreview: amountState.expressionPreview,
                    accentColor: accent,
                    isFocused: amountState.isAmountFocused,
                    onTap: () => cubit.setCalculatorOpen(true),
                  );
                },
              ),
              const SizedBox(height: 18),
              ProgressiveReveal(
                visible: state.hasAmount,
                child: Column(
                  children: [
                    SecondaryFormField(
                      label: 'Category',
                      child: _PickerTile(
                        value: state.category ?? 'Choose category',
                        icon: Icons.expand_more_rounded,
                        onTap: () async {
                          await _scaffoldKey.currentState
                              ?.closeCalculatorBefore(() async {
                                final selected =
                                    await showModalBottomSheet<String>(
                                      context: context,
                                      showDragHandle: true,
                                      builder: (_) => const _CategorySheet(),
                                    );
                                if (selected != null) {
                                  cubit.selectCategory(selected);
                                }
                              });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    SecondaryFormField(
                      label: 'Description',
                      child: TextField(
                        focusNode: _descriptionFocus,
                        textInputAction: TextInputAction.done,
                        onTap: () => _scaffoldKey.currentState
                            ?.focusNativeField(_descriptionFocus),
                        onChanged: cubit.updateDescription,
                        decoration: const InputDecoration(
                          hintText: 'Optional note',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SecondaryFormField(
                      label: 'Date',
                      child: _PickerTile(
                        value: DateFormatter.compact(state.date),
                        icon: Icons.calendar_today_rounded,
                        onTap: () async {
                          await _scaffoldKey.currentState
                              ?.closeCalculatorBefore(() async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: state.date,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2035),
                                );
                                if (picked != null) cubit.updateDate(picked);
                              });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TypeSwitcher extends StatelessWidget {
  const _TypeSwitcher({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    final selected = context.select(
      (PersonalExpenseCubit cubit) => cubit.state.type,
    );
    return SegmentedButton<PersonalExpenseType>(
      segments: const [
        ButtonSegment(
          value: PersonalExpenseType.expense,
          label: Text('Expense'),
        ),
        ButtonSegment(value: PersonalExpenseType.income, label: Text('Income')),
      ],
      selected: {selected},
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? Colors.white
              : AppColors.ink,
        ),
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? accent : Colors.white,
        ),
      ),
      onSelectionChanged: (value) =>
          context.read<PersonalExpenseCubit>().selectType(value.first),
    );
  }
}

class _CategorySheet extends StatelessWidget {
  const _CategorySheet();

  @override
  Widget build(BuildContext context) {
    const categories = [
      'Food',
      'Transport',
      'Entertainment',
      'Shopping',
      'Bills',
    ];
    return SafeArea(
      child: ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        itemCount: categories.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final category = categories[index];
          return ListTile(
            title: Text(category),
            onTap: () => Navigator.of(context).pop(category),
          );
        },
      ),
    );
  }
}

class _PickerTile extends StatelessWidget {
  const _PickerTile({
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final String value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.line),
          ),
          child: Row(
            children: [
              Expanded(child: Text(value)),
              Icon(icon, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
