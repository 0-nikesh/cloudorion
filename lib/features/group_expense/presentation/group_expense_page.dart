import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../shared/layout/calculator_aware_scaffold.dart';
import '../../../shared/widgets/amount_input_field.dart';
import '../../../shared/widgets/progressive_reveal.dart';
import '../../../shared/widgets/secondary_form_field.dart';
import 'cubit/group_expense_cubit.dart';
import 'cubit/group_expense_state.dart';

class GroupExpensePage extends StatelessWidget {
  const GroupExpensePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GroupExpenseCubit(),
      child: const _GroupExpenseView(),
    );
  }
}

class _GroupExpenseView extends StatefulWidget {
  const _GroupExpenseView();

  @override
  State<_GroupExpenseView> createState() => _GroupExpenseViewState();
}

class _GroupExpenseViewState extends State<_GroupExpenseView> {
  final _scaffoldKey = GlobalKey<CalculatorAwareScaffoldState>();
  final _descriptionFocus = FocusNode();

  @override
  void dispose() {
    _descriptionFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GroupExpenseCubit, GroupExpenseState>(
      buildWhen: (p, c) =>
          p.isCalculatorOpen != c.isCalculatorOpen ||
          p.isLoading != c.isLoading ||
          p.hasAmount != c.hasAmount ||
          p.splitType != c.splitType ||
          p.payer != c.payer ||
          p.members != c.members,
      builder: (context, state) {
        final cubit = context.read<GroupExpenseCubit>();
        return CalculatorAwareScaffold(
          key: _scaffoldKey,
          title: 'Add Group Expense',
          accentColor: AppColors.group,
          saveLabel: 'Add Expense',
          calculatorOpen: state.isCalculatorOpen,
          saveEnabled: state.canSave,
          isSaveLoading: state.isLoading,
          onSave: cubit.save,
          onCalculatorKey: cubit.editFocusedAmount,
          onCalculatorDone: cubit.doneFocusedAmount,
          onCalculatorVisibilityChanged: cubit.setCalculatorOpen,
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              BlocBuilder<GroupExpenseCubit, GroupExpenseState>(
                buildWhen: (p, c) =>
                    p.amountDisplay != c.amountDisplay ||
                    p.expressionPreview != c.expressionPreview ||
                    p.focusedTarget != c.focusedTarget ||
                    p.isCalculatorOpen != c.isCalculatorOpen,
                builder: (context, amountState) {
                  return AmountInputField(
                    amountDisplay: amountState.amountDisplay,
                    expressionPreview: amountState.expressionPreview,
                    accentColor: AppColors.group,
                    isFocused: amountState.isMainFocused,
                    onTap: cubit.focusMainAmount,
                  );
                },
              ),
              const SizedBox(height: 18),
              ProgressiveReveal(
                visible: state.hasAmount,
                child: Column(
                  children: [
                    SecondaryFormField(
                      label: 'Description',
                      child: TextField(
                        focusNode: _descriptionFocus,
                        textInputAction: TextInputAction.done,
                        onTap: () => _scaffoldKey.currentState
                            ?.focusNativeField(_descriptionFocus),
                        onChanged: cubit.updateDescription,
                        decoration: const InputDecoration(
                          hintText: 'Dinner, trip, rent...',
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
                    const SizedBox(height: 16),
                    SecondaryFormField(
                      label: 'Payer',
                      child: DropdownButtonFormField<String>(
                        initialValue: state.payer,
                        items: [
                          for (final member in state.members)
                            DropdownMenuItem(
                              value: member.name,
                              child: Text(member.name),
                            ),
                        ],
                        onTap: () =>
                            _scaffoldKey.currentState?.closeCalculator(),
                        onChanged: (value) {
                          if (value != null) cubit.updatePayer(value);
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SplitToggle(selected: state.splitType),
                    const SizedBox(height: 14),
                    _SplitSection(
                      state: state,
                      onMemberTap: cubit.focusMemberAmount,
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

class _SplitToggle extends StatelessWidget {
  const _SplitToggle({required this.selected});

  final SplitType selected;

  @override
  Widget build(BuildContext context) {
    return SecondaryFormField(
      label: 'Split Type',
      child: SegmentedButton<SplitType>(
        segments: const [
          ButtonSegment(value: SplitType.equal, label: Text('Equal')),
          ButtonSegment(value: SplitType.custom, label: Text('Custom')),
        ],
        selected: {selected},
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? Colors.white
                : AppColors.ink,
          ),
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? AppColors.group
                : Colors.white,
          ),
        ),
        onSelectionChanged: (value) =>
            context.read<GroupExpenseCubit>().updateSplitType(value.first),
      ),
    );
  }
}

class _SplitSection extends StatelessWidget {
  const _SplitSection({required this.state, required this.onMemberTap});

  final GroupExpenseState state;
  final ValueChanged<String> onMemberTap;

  @override
  Widget build(BuildContext context) {
    if (state.splitType == SplitType.equal) {
      return Column(
        children: [
          for (final member in state.members)
            _ShareRow(
              name: member.name,
              amount: state.equalShare
                  .toStringAsFixed(2)
                  .replaceFirst(RegExp(r'\.00$'), ''),
            ),
        ],
      );
    }
    return Column(
      children: [
        for (final member in state.members) ...[
          AmountInputField(
            amountDisplay: member.amountDisplay,
            expressionPreview: member.expressionPreview,
            placeholder: '0',
            accentColor: AppColors.group,
            isFocused:
                state.focusedTarget == member.name && state.isCalculatorOpen,
            onTap: () => onMemberTap(member.name),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                member.name,
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ShareRow extends StatelessWidget {
  const _ShareRow({required this.name, required this.amount});

  final String name;
  final String amount;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Expanded(child: Text(name)),
          Text(amount, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
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
