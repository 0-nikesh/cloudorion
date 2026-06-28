import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../shared/layout/calculator_aware_scaffold.dart';
import '../../../shared/widgets/amount_input_field.dart';
import '../../../shared/widgets/progressive_reveal.dart';
import '../../../shared/widgets/secondary_form_field.dart';
import 'cubit/party_transaction_cubit.dart';
import 'cubit/party_transaction_state.dart';

class PartyTransactionPage extends StatelessWidget {
  const PartyTransactionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PartyTransactionCubit(),
      child: const _PartyTransactionView(),
    );
  }
}

class _PartyTransactionView extends StatefulWidget {
  const _PartyTransactionView();

  @override
  State<_PartyTransactionView> createState() => _PartyTransactionViewState();
}

class _PartyTransactionViewState extends State<_PartyTransactionView> {
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
      (PartyTransactionCubit cubit) =>
          cubit.state.type == PartyTransactionType.received
          ? AppColors.received
          : AppColors.given,
    );
    return BlocBuilder<PartyTransactionCubit, PartyTransactionState>(
      buildWhen: (p, c) =>
          p.isCalculatorOpen != c.isCalculatorOpen ||
          p.isLoading != c.isLoading ||
          p.hasAmount != c.hasAmount ||
          p.type != c.type,
      builder: (context, state) {
        final cubit = context.read<PartyTransactionCubit>();
        return CalculatorAwareScaffold(
          key: _scaffoldKey,
          title: 'Add Party Transaction',
          accentColor: accent,
          saveLabel: 'Save Entry',
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
              _TypeToggle(accent: accent),
              const SizedBox(height: 18),
              BlocBuilder<PartyTransactionCubit, PartyTransactionState>(
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
                      label: 'Description',
                      child: TextField(
                        focusNode: _descriptionFocus,
                        textInputAction: TextInputAction.done,
                        onTap: () => _scaffoldKey.currentState
                            ?.focusNativeField(_descriptionFocus),
                        onChanged: cubit.updateDescription,
                        decoration: const InputDecoration(
                          hintText: 'Person or note',
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

class _TypeToggle extends StatelessWidget {
  const _TypeToggle({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    final selected = context.select(
      (PartyTransactionCubit cubit) => cubit.state.type,
    );
    return SegmentedButton<PartyTransactionType>(
      segments: const [
        ButtonSegment(
          value: PartyTransactionType.received,
          label: Text('Received'),
        ),
        ButtonSegment(value: PartyTransactionType.given, label: Text('Given')),
      ],
      selected: {selected},
      style: ButtonStyle(
        visualDensity: VisualDensity.comfortable,
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
          context.read<PartyTransactionCubit>().selectType(value.first),
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
