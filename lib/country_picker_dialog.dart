import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/helpers.dart';

class CustomModelSheet extends StatelessWidget {
  const CustomModelSheet({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    var color = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 25,
        vertical: 25,
      ),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
        boxShadow: [
          BoxShadow(
            spreadRadius: -5,
            color: Colors.black.withOpacity(0.8),
            blurRadius: 6, // Set blur radius
            offset: const Offset(-6, -6),
            inset: true,
          ),
          BoxShadow(
            spreadRadius: -5,
            color: Colors.black.withOpacity(0.8),
            blurRadius: 6, // Set blur radius
            offset: const Offset(6, 6),
            inset: true,
          ),
        ],
        color: color.colorScheme.secondary,
        border: Border.all(
          color: color.colorScheme.onPrimaryContainer,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 65,
            height: 3,
            decoration: BoxDecoration(
              color: color.colorScheme.onPrimaryContainer,
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          child,
        ],
      ),
    );
  }
}

class PickerDialogStyle {
  final Color? backgroundColor;

  final TextStyle? countryCodeStyle;

  final TextStyle? countryNameStyle;

  final Widget? listTileDivider;

  final EdgeInsets? listTilePadding;

  final EdgeInsets? padding;

  final Color? searchFieldCursorColor;

  final InputDecoration? searchFieldInputDecoration;

  final EdgeInsets? searchFieldPadding;

  final double? width;

  PickerDialogStyle({
    this.backgroundColor,
    this.countryCodeStyle,
    this.countryNameStyle,
    this.listTileDivider,
    this.listTilePadding,
    this.padding,
    this.searchFieldCursorColor,
    this.searchFieldInputDecoration,
    this.searchFieldPadding,
    this.width,
  });
}

class CountryPickerDialog extends StatefulWidget {
  final List<Country> countryList;
  final Country selectedCountry;
  final ValueChanged<Country> onCountryChanged;
  final String searchText;
  final List<Country> filteredCountries;
  final PickerDialogStyle? style;
  final String languageCode;

  const CountryPickerDialog({
    Key? key,
    required this.searchText,
    required this.languageCode,
    required this.countryList,
    required this.onCountryChanged,
    required this.selectedCountry,
    required this.filteredCountries,
    this.style,
  }) : super(key: key);

  @override
  State<CountryPickerDialog> createState() => _CountryPickerDialogState();
}

class _CountryPickerDialogState extends State<CountryPickerDialog> {
  late List<Country> _filteredCountries;
  late Country _selectedCountry;

  @override
  void initState() {
    _selectedCountry = widget.selectedCountry;
    _filteredCountries = widget.filteredCountries.toList()
      ..sort(
        (a, b) => a.localizedName(widget.languageCode).compareTo(b.localizedName(widget.languageCode)),
      );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomModelSheet(
      child: Column(
        children: <Widget>[
          Padding(
            padding: widget.style?.searchFieldPadding ?? const EdgeInsets.all(0),
            child: TextField(
              cursorColor: widget.style?.searchFieldCursorColor,
              decoration: widget.style?.searchFieldInputDecoration ??
                  InputDecoration(
                    suffixIcon: const Icon(Icons.search),
                    labelText: widget.searchText,
                  ),
              onChanged: (value) {
                _filteredCountries = widget.countryList.stringSearch(value)
                  ..sort(
                    (a, b) => a.localizedName(widget.languageCode).compareTo(b.localizedName(widget.languageCode)),
                  );
                if (mounted) setState(() {});
              },
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _filteredCountries.length,
              itemBuilder: (ctx, index) => Column(
                children: <Widget>[
                  ListTile(
                    leading: kIsWeb
                        ? Image.asset(
                            'assets/flags/${_filteredCountries[index].code.toLowerCase()}.png',
                            package: 'intl_phone_field',
                            width: 32,
                          )
                        : Text(
                            _filteredCountries[index].flag,
                            style: const TextStyle(fontSize: 18),
                          ),
                    contentPadding: widget.style?.listTilePadding,
                    title: Text(
                      _filteredCountries[index].localizedName(widget.languageCode),
                      style: widget.style?.countryNameStyle ?? const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    trailing: Text(
                      '+${_filteredCountries[index].dialCode}',
                      style: widget.style?.countryCodeStyle ?? const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    onTap: () {
                      _selectedCountry = _filteredCountries[index];
                      widget.onCountryChanged(_selectedCountry);
                      Navigator.of(context).pop();
                    },
                  ),
                  widget.style?.listTileDivider ?? const Divider(thickness: 1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
