## How to run

```bash
flutter pub get
flutter run
```

## Package choices

- `flutter_bloc`: used for `Cubit` state management on each screen.
- `cupertino_icons`: kept from the Flutter scaffold.

## Why Cubit

Cubit was choosed here because each form has direct, event-like mutations like select a type, edit an amount, pick a date, change split mode, and save. It kept business state out of widgets.

## Folder structure

The project follows the requested structure:

- `app/`: app shell, routes, and home navigation.
- `core/calculator/`: pure dart expression engine and parser.
- `core/theme/`: colors and material theme.
- `core/utils/`: date formatting and keyboard helpers.
- `shared/widgets/`: amount field, keypad, save button, secondary field wrapper, and reveal animation.
- `shared/layout/`: calculator-aware scaffold that coordinates the bottom panel and keyboard inset.
- `features/`: 1 feature folder per form, each with its own Cubit and state.

## Keyboard and calculator transition

The calculator scaffold controls the sequence. When an amount field is tapped, it dismisses the keyboard, waits for the keyboard to leave, then animates the calculator up with an ease-out curve. When a native text field or picker is requested, the calculator reverses first, then the requested focus or sheet action happens.

## Save button pinning

Each form uses `resizeToAvoidBottomInset: false` and a `Stack`. The save button is positioned above the active bottom panel: above the calculator when it is open, or above the live keyboard inset when a native field is focused. Form content gets matching bottom padding so it scrolls clear of the fixed bottom controls.

## Back button keyboard jump

When back is pressed while the keyboard is open, the scaffold freezes the last known keyboard inset, dismisses focus, waits briefly for the close animation to start, then pops the route. Freezing the inset avoids a last-frame layout jump during route exit.

## Hardest part

The hardest part was making the bottom area feel consistent across three different interaction types: custom calculator, native keyboard, and modal pickers. The layout treats them as one coordinated bottom-panel system rather than separate widgets fighting over insets.

## With more time

- Add widget tests for keyboard/calculator sequencing.
- Tried saved entries locally for review history.
- Add richer validation for custom group split totals.
