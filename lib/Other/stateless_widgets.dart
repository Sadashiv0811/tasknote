import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tasknote/Other/constants.dart';
import 'package:tasknote/Other/theme.dart';

class CTextFormField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextCapitalization textCapitalization;
  final TextEditingController controller;
  final List<TextInputFormatter>? inputFormatters;
  final bool readOnly;
  final bool autofocus;
  final FocusNode? focusNode;
  final void Function(String)? onChanged;

  const CTextFormField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.inputFormatters,
    this.readOnly = false,
    this.autofocus = false,
    this.textCapitalization = TextCapitalization.none,
    this.focusNode,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = themeNotifier.value == ThemeMode.dark;
    return TextFormField(
      controller: controller,
      autofocus: autofocus,
      textCapitalization: textCapitalization,
      readOnly: readOnly,
      focusNode: focusNode,
      keyboardType: label == "Content" || label == "Description"
          ? TextInputType.multiline
          : TextInputType.text,
      maxLines: label == "Content" || label == "Description" ? null : 1,
      style: Theme.of(context).textTheme.bodySmall,
      cursorColor: isDark ? AppColors.primary : AppColors.dThirdColor,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Required';
        }
        return null;
      },
      inputFormatters: inputFormatters,
      decoration: AppTheme.inputDecoration(
        fBColor: isDark ? AppColors.lFirstColor : AppColors.dFirstColor,
        eBColor: isDark ? AppColors.primary : AppColors.dThirdColor,
        hint: hint,
      ),
      onChanged: onChanged,
    );
  }
}

class CLabel extends StatelessWidget {
  final String text;
  const CLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = themeNotifier.value == ThemeMode.dark;

    return Text(
      text,
      style: theme.textTheme.bodyMedium!.copyWith(
        color: isDark ? AppColors.primary : AppColors.dThirdColor,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class ColorSelector extends StatelessWidget {
  // Pass the currently selected color and the change handler down from the parent
  final Color selectedColor;
  final ValueChanged<Color> onColorSelected;

  const ColorSelector({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6, // Horizontal space between items
      runSpacing: 4, // Vertical space between lines

      alignment: .start,
      children: uniqueColors.map((color) {
        final isSelected = color == selectedColor;

        return GestureDetector(
          onTap: () => onColorSelected(color), // Notify parent of the click
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            width: isSelected ? 54 : 46,
            height: isSelected ? 54 : 46,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? color.withValues(alpha: 0.5)
                      : Colors.black.withValues(alpha: 0.1),
                  blurRadius: isSelected ? 10 : 4,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 3,
              ),
            ),
            child: isSelected
                ? Icon(
                    Icons.check,
                    color:
                        ThemeData.estimateBrightnessForColor(color) ==
                            Brightness.light
                        ? Colors.black87
                        : Colors.white,
                    size: 22,
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }
}

class CSearchbar extends StatelessWidget {
  final void Function(String)? onChanged;
  final TextEditingController controller;
  final String hintText;
  final String searchQuery;
  final VoidCallback clearSearch;

  const CSearchbar({
    super.key,
    this.onChanged,
    required this.controller,
    required this.hintText,
    required this.searchQuery,
    required this.clearSearch,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      margin: EdgeInsets.only(
        left: getWidth(context, 0.07),
        right: getWidth(context, 0.07),
        top: getHeight(context, 0.01),
        bottom: getHeight(context, 0.02),
      ),
      decoration: BoxDecoration(
        borderRadius: .circular(25),
        gradient: LinearGradient(
          begin: .centerLeft,
          end: .centerRight,
          colors: isDark
              ? [Color(0xFF26658c), Color(0xFF011c40)]
              : [Colors.white, Color(0xFF54acbf)],
        ),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        inputFormatters: [FilteringTextInputFormatter.allow(titlePattern)],
        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 16),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontSize: 16),
          prefixIcon: Icon(
            Icons.search,
            color: isDark ? AppColors.lFirstColor : AppColors.dThirdColor,
          ),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: clearSearch,
                )
              : null,
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: isDark ? AppColors.lFirstColor : AppColors.dFirstColor,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(25),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: isDark ? AppColors.lFirstColor : AppColors.dThirdColor,
            ),
            borderRadius: BorderRadius.circular(25),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 5,
          ),
        ),
      ),
    );
  }
}

class SortViewOptions extends StatelessWidget {
  final bool showIcons;
  final String title;
  final List<String> options;
  final String currentSelected;
  const SortViewOptions({
    super.key,
    required this.title,
    required this.options,
    required this.showIcons,
    required this.currentSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        color: isDark ? AppColors.dThirdColor : AppColors.lThirdColor,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: theme.textTheme.displayLarge!.copyWith(
              fontSize: 25.0,
              color: isDark ? Colors.white : Colors.white,
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            itemCount: options.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: showIcons
                    ? Icon(viewOptionsIcons[index], color: Colors.white)
                    : null,
                title: Text(
                  options[index],
                  style: theme.textTheme.bodyMedium!.copyWith(
                    color: isDark ? Colors.white : Colors.white,
                  ),
                ),
                trailing: currentSelected == options[index]
                    ? Icon(Icons.check_circle, color: theme.primaryColor)
                    : null,
                onTap: () {
                  Navigator.pop(context, options[index]);
                },
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return Divider(
                height: 1,
                thickness: 0.5,
                color: isDark ? theme.colorScheme.outlineVariant : Colors.grey,
              );
            },
          ),
        ],
      ),
    );
  }
}

class CActionContainer extends StatelessWidget {
  final VoidCallback onTapSort;
  final VoidCallback? onTapView;
  final bool showViewButton;
  final String sort;

  const CActionContainer({
    super.key,
    required this.onTapSort,
    this.onTapView,
    this.showViewButton = true,
    this.sort = "",
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Theme-specific colors
    final Color containerColor = isDark
        ? AppColors.dThirdColor
        : AppColors.lThirdColor;

    // Shadow color uses primary color for an attractive glow
    final Color shadowColor = isDark
        ? AppColors.primary.withValues(alpha: 0.5)
        : AppColors.dThirdColor.withValues(alpha: 0.5);

    // Text style configuration for reusability
    final buttonTextStyle =
        theme.textTheme.bodyMedium?.copyWith(
          color: Colors.white,
          fontSize: 16.0, 
          fontWeight: FontWeight.w600,
        ) ??
        const TextStyle(
          color: Colors.white,
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
        );

    return Container(
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(30.0),
        boxShadow: [
          BoxShadow(
            blurRadius: 7.0,
            spreadRadius: 2.0,
            color: shadowColor,
            blurStyle: BlurStyle.normal,
          ),
        ],
      ),
      // IntrinsicHeight ensures the vertical divider matches the Row's height dynamically
      child: IntrinsicHeight(
        child: Padding(
          padding: EdgeInsetsGeometry.symmetric(horizontal: 20),
          child: Row(
            mainAxisSize: .min,
            mainAxisAlignment: .spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () async {
                  onTapSort();
                },
                label: Text("Sort By", style: buttonTextStyle),
                icon: const Icon(Icons.sort_rounded, color: Colors.white),
                style: TextButton.styleFrom(
                  splashFactory: NoSplash.splashFactory,
                  alignment: Alignment.center,
                  padding: EdgeInsets.zero,
                ),
              ),
              if (!showViewButton)
                Text(" : $sort", style: buttonTextStyle.copyWith(fontSize: 14)),
              if (showViewButton) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 10,
                  ),
                  child: VerticalDivider(
                    color: Colors.white.withValues(alpha: 0.6),
                    width: 1,
                    thickness: 1.5,
                  ),
                ),

                TextButton.icon(
                  onPressed: () async {
                    if (showViewButton) {
                      onTapView!();
                    }
                  },
                  iconAlignment: IconAlignment.end,
                  label: Text("View", style: buttonTextStyle),
                  icon: const Icon(Icons.view_agenda, color: Colors.white),
                  style: TextButton.styleFrom(
                    splashFactory: NoSplash.splashFactory,
                    alignment: Alignment.center,
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class SelectedCount extends StatelessWidget {
  final String text;
  const SelectedCount({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadiusGeometry.all(Radius.circular(20.0)),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
        color: isDark ? AppColors.lSecondColor : AppColors.dThirdColor,
        child: Text(
          text,
          style: theme.textTheme.bodyMedium!.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}

class DatesRow extends StatelessWidget {
  final String created, updated;
  const DatesRow({super.key, required this.created, required this.updated});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = themeNotifier.value == ThemeMode.dark;

    return Row(
      mainAxisAlignment: .spaceBetween,
      children: [
        Align(
          alignment: AlignmentGeometry.topLeft,
          child: Text(
            "Last updated\n$updated",
            style: theme.textTheme.bodySmall!.copyWith(
              color: isDark ? AppColors.primary : AppColors.dThirdColor,
            ),
          ),
        ),
        Align(
          alignment: AlignmentGeometry.topRight,
          child: Text(
            textAlign: TextAlign.end,
            "Created\n$created",
            style: theme.textTheme.bodySmall!.copyWith(
              color: isDark ? AppColors.primary : AppColors.dThirdColor,
            ),
          ),
        ),
      ],
    );
  }
}

class EmptySearchResult extends StatelessWidget {
  final String text;
  const EmptySearchResult({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 60,
              color: isDark ? Colors.white : AppColors.dThirdColor,
            ),
            const SizedBox(height: 10),
            Text(
              text,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.white : AppColors.dThirdColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DeleteConfirmation extends StatelessWidget {
  final bool singleDeletion;
  final VoidCallback yesAction;
  final String? item;
  final int? nCount;

  const DeleteConfirmation({
    super.key,
    required this.singleDeletion,
    required this.yesAction,
    this.item = "note",
    this.nCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    String msg;
    if (item == "note") {
      // Note deletion
      msg = singleDeletion
          ? "Are you sure you want to delete this note?"
          : "Are you sure you want to delete the selected notes?";
    } else {
      // Group deletion
      if (nCount! > 1) {
        msg =
            "Are you sure you want to delete the folder?\nAll notes inside this folder will be deleted.";
      } else if (nCount! == 1) {
        msg =
            "Are you sure you want to delete the folder?\nNote inside this folder will be deleted.";
      } else {
        // nCount is 0
        msg = "Are you sure you want to delete the folder?";
      }
    }
    return AlertDialog(
      title: Text("Delete"),
      content: Text(msg, textAlign: TextAlign.start),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                yesAction();
              },
              child: Text("Yes"),
            ),
          ],
        ),
      ],
    );
  }
}

class CDialogTitle extends StatelessWidget {
  final String text;
  final IconData? icon;
  const CDialogTitle({super.key, required this.text, this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        if (icon != null) ...[
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 16.0),
        ],
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
      ],
    );
  }
}

class CDialogContent extends StatelessWidget {
  final String text1;
  final String? text2;
  const CDialogContent({super.key, required this.text1, this.text2});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: .min,
      crossAxisAlignment: .start,
      children: [
        Text(
          text1,
          style: TextStyle(
            fontSize: 16,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        if (text2 != null) ...[
          const SizedBox(height: 8),
          Text(
            text2!,
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color:
                  theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7) ??
                  Colors.grey.shade700,
            ),
          ),
        ],
      ],
    );
  }
}

final GlobalKey<ScaffoldMessengerState> snackbarKey =
    GlobalKey<ScaffoldMessengerState>();

void scaffoldMessenger(String message) {
  snackbarKey.currentState?.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      margin: EdgeInsets.all(20.0),
      duration: Duration(seconds: 2),
      content: Text(message),
    ),
  );
}
