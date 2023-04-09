import 'package:adaptivex/adaptivex.dart';
import 'package:flutter/material.dart';

import 'datatable_header.dart';

class ResponsiveDatatable extends StatefulWidget {
  final bool showSelect;
  final List<DatatableHeader> headers;
  final List<Map<String, dynamic>>? source;
  final List<Map<String, dynamic>>? selecteds;
  final Widget? title;
  final List<Widget>? actions;
  final List<Widget>? footers;
  final Function(bool? value)? onSelectAll;
  final Function(bool? value, Map<String, dynamic> data)? onSelect;
  final Function(Map<String, dynamic> value)? onTabRow;
  final Function(dynamic value)? onSort;
  final String? sortColumn;
  final bool? sortAscending;
  final bool isLoading;
  final bool autoHeight;
  final bool hideUnderline;
  final bool commonMobileView;
  final bool isExpandRows;
  final List<bool>? expanded;
  final Widget Function(Map<String, dynamic> value)? dropContainer;
  final Function(Map<String, dynamic> value, DatatableHeader header)? onChangedRow;
  final Function(Map<String, dynamic> value, DatatableHeader header)? onSubmittedRow;

  /// `responseScreenSizes`
  ///
  /// the ScreenSize that will responsive as list view
  final List<ScreenSize> responseScreenSizes;

  /// `rowDecoration`
  ///
  /// allow to decorate the data row
  final BoxDecoration? rowDecoration;

  /// `selectedDecoration`
  ///
  /// allow to decorate the selected data row
  final BoxDecoration? selectedDecoration;

  /// `selectedTextStyle`
  ///
  /// allow to styling the header row
  final TextStyle? headerTextStyle;

  /// `selectedTextStyle`
  ///
  /// allow to styling the data row
  final TextStyle? rowTextStyle;

  /// `selectedTextStyle`
  ///
  /// allow to styling the selected data row
  final TextStyle? selectedTextStyle;

  const ResponsiveDatatable({
    Key? key,
    this.showSelect = false,
    this.onSelectAll,
    this.onSelect,
    this.onTabRow,
    this.onSort,
    this.headers = const [],
    this.source,
    this.selecteds,
    this.title,
    this.actions,
    this.footers,
    this.sortColumn,
    this.sortAscending,
    this.isLoading = false,
    this.autoHeight = true,
    this.hideUnderline = true,
    this.commonMobileView = false,
    this.isExpandRows = true,
    this.expanded,
    this.dropContainer,
    this.onChangedRow,
    this.onSubmittedRow,
    this.responseScreenSizes = const [ScreenSize.xs, ScreenSize.sm, ScreenSize.md],
    this.rowDecoration,
    this.selectedDecoration,
    this.headerTextStyle,
    this.rowTextStyle,
    this.selectedTextStyle,
  }) : super(key: key);

  @override
  _ResponsiveDatatableState createState() => _ResponsiveDatatableState();
}

class _ResponsiveDatatableState extends State<ResponsiveDatatable> {
  static Alignment headerAlignSwitch(TextAlign? textAlign) {
    switch (textAlign) {
      case TextAlign.center:
        return Alignment.center;
      case TextAlign.left:
        return Alignment.centerLeft;
      case TextAlign.right:
        return Alignment.centerRight;
      default:
        return Alignment.center;
    }
  }

  Widget mobileHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Checkbox(
          value: widget.selecteds!.length == widget.source!.length && widget.source != null && widget.source!.isNotEmpty,
          onChanged: (value) {
            if (widget.onSelectAll != null) widget.onSelectAll!(value);
          },
        ),
        PopupMenuButton(
          child: Container(
            padding: const EdgeInsets.all(
              16.0,
            ),
            child: const Text("SORT BY"),
          ),
          tooltip: "SORT BY",
          initialValue: widget.sortColumn,
          itemBuilder: (_) => widget.headers
              .where((header) => header.show == true && header.sortable == true)
              .toList()
              .map(
                (header) => PopupMenuItem(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        header.text,
                        textAlign: header.textAlign,
                      ),
                      if (widget.sortColumn != null && widget.sortColumn == header.value)
                        widget.sortAscending!
                            ? const Icon(
                                Icons.arrow_downward,
                                size: 18.0,
                              )
                            : const Icon(
                                Icons.arrow_upward,
                                size: 18.0,
                              )
                    ],
                  ),
                  value: header.value,
                ),
              )
              .toList(),
          onSelected: (dynamic value) {
            if (widget.onSort != null) widget.onSort!(value);
          },
        )
      ],
    );
  }

  List<Widget> mobileList() {
    final _decoration = BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[300]!, width: 1)));
    final _rowDecoration = widget.rowDecoration ?? _decoration;
    final _selectedDecoration = widget.selectedDecoration ?? _decoration;
    return widget.source!.map((data) {
      return InkWell(
        onTap: () => widget.onTabRow?.call(data),
        child: Container(
          /// TODO:
          decoration: widget.selecteds!.contains(data) ? _selectedDecoration : _rowDecoration,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Spacer(),
                  if (widget.showSelect && widget.selecteds != null)
                    Checkbox(
                      value: widget.selecteds!.contains(data),
                      onChanged: (value) {
                        if (widget.onSelect != null) {
                          widget.onSelect!(value, data);
                        }
                      },
                    ),
                ],
              ),
              if (widget.commonMobileView && widget.dropContainer != null) widget.dropContainer!(data),
              if (!widget.commonMobileView)
                ...widget.headers
                    .where((header) => header.show == true)
                    .toList()
                    .map(
                      (header) => Container(
                        padding: const EdgeInsets.all(
                          8.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            header.headerBuilder != null
                                ? header.headerBuilder!(header.value)
                                : Text(
                                    header.text,
                                    overflow: TextOverflow.clip,
                                    style: widget.selecteds!.contains(data) ? widget.selectedTextStyle : widget.rowTextStyle,
                                  ),
                            const Spacer(),
                            header.sourceBuilder != null
                                ? header.sourceBuilder!(data[header.value], data)
                                : header.editable
                                    ? TextEditableWidget(
                                        data: data,
                                        header: header,
                                        textAlign: TextAlign.end,
                                        onChanged: widget.onChangedRow,
                                        onSubmitted: widget.onSubmittedRow,
                                        hideUnderline: widget.hideUnderline,
                                      )
                                    : Text(
                                        "${data[header.value]}",
                                        style: widget.selecteds!.contains(data) ? widget.selectedTextStyle : widget.rowTextStyle,
                                      )
                          ],
                        ),
                      ),
                    )
                    .toList()
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget desktopHeader() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[300]!,
            width: .5,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 4.0,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          if (widget.showSelect && widget.selecteds != null)
            Checkbox(
              value: widget.selecteds!.length == widget.source!.length && widget.source != null && widget.source!.isNotEmpty,
              onChanged: (value) {
                if (widget.onSelectAll != null) widget.onSelectAll!(value);
              },
            ),
          ...widget.headers
              .where((header) => header.show == true)
              .map(
                (header) => Expanded(
                  flex: header.flex,
                  child: InkWell(
                    onTap: () {
                      if (widget.onSort != null && header.sortable) {
                        widget.onSort!(header.value);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16.0,
                        horizontal: 8.0,
                      ),
                      child: header.headerBuilder != null
                          ? header.headerBuilder!(header.value)
                          : Container(
                              alignment: headerAlignSwitch(header.textAlign),
                              child: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(
                                    header.text,
                                    textAlign: header.textAlign,
                                    style: widget.headerTextStyle,
                                  ),
                                  if (widget.sortColumn != null && widget.sortColumn == header.value)
                                    widget.sortAscending!
                                        ? const Icon(
                                            Icons.arrow_downward,
                                            size: 16.0,
                                          )
                                        : const Icon(
                                            Icons.arrow_upward,
                                            size: 16.0,
                                          )
                                ],
                              ),
                            ),
                    ),
                  ),
                ),
              )
              .toList()
        ],
      ),
    );
  }

  List<Widget> desktopList() {
    List<Widget> widgets = [];
    for (var index = 0; index < widget.source!.length; index++) {
      final data = widget.source![index];
      widgets.add(
        Column(
          children: [
            InkWell(
              onTap: () {
                widget.onTabRow?.call(data);
                setState(() {
                  widget.expanded![index] = !widget.expanded![index];
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4.0,
                  vertical: 2.0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.showSelect && widget.selecteds != null)
                      Checkbox(
                        value: widget.selecteds!.contains(data),
                        onChanged: (value) {
                          if (widget.onSelect != null) {
                            widget.onSelect!(value, data);
                          }
                        },
                      ),
                    ...widget.headers
                        .where((header) => header.show == true)
                        .map(
                          (header) => Expanded(
                            flex: header.flex,
                            child: header.sourceBuilder != null
                                ? header.sourceBuilder!(data[header.value], data)
                                : header.editable
                                    ? TextEditableWidget(
                                        data: data,
                                        header: header,
                                        textAlign: header.textAlign,
                                        onChanged: widget.onChangedRow,
                                        onSubmitted: widget.onSubmittedRow,
                                        hideUnderline: widget.hideUnderline,
                                      )
                                    : Text(
                                        "${data[header.value]}",
                                        textAlign: header.textAlign,
                                        style: widget.selecteds!.contains(data) ? widget.selectedTextStyle : widget.rowTextStyle,
                                      ),
                          ),
                        )
                        .toList()
                  ],
                ),
              ),
            ),
            if (widget.isExpandRows && widget.expanded![index] && widget.dropContainer != null) widget.dropContainer!(data)
          ],
        ),
      );
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    // for small screen else large screen
    return widget.responseScreenSizes.isNotEmpty && widget.responseScreenSizes.contains(context.screenSize)
        ? Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // title and actions
              if (widget.title != null || widget.actions != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (widget.title != null) widget.title!,
                    if (widget.actions != null) ...widget.actions!,
                  ],
                ),
                const SizedBox(
                  height: 16.0,
                ),
              ],

              // mobileHeader and mobileList
              if (widget.autoHeight)
                Column(
                  children: [
                    if (widget.showSelect && widget.selecteds != null) mobileHeader(),
                    if (widget.isLoading) const LinearProgressIndicator(),
                    ...mobileList(),
                  ],
                ),
              if (!widget.autoHeight)
                Expanded(
                  child: ListView(
                    children: [
                      if (widget.showSelect && widget.selecteds != null) mobileHeader(),
                      if (widget.isLoading) const LinearProgressIndicator(),
                      ...mobileList(),
                    ],
                  ),
                ),

              // footer
              if (widget.footers != null)
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    ...widget.footers!,
                  ],
                )
            ],
          )
        : Column(
            children: [
              // title and actions
              if (widget.title != null || widget.actions != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (widget.title != null) widget.title!,
                    if (widget.actions != null) ...widget.actions!,
                  ],
                ),
                const SizedBox(
                  height: 16.0,
                ),
              ],

              // desktopHeader
              if (widget.headers.isNotEmpty) desktopHeader(),
              if (widget.isLoading) const LinearProgressIndicator(),

              // desktopList
              if (widget.autoHeight)
                Column(
                  children: desktopList(),
                ),
              if (!widget.autoHeight)
                if (widget.source != null && widget.source!.isNotEmpty)
                  Expanded(
                    child: ListView(
                      children: desktopList(),
                    ),
                  ),

              // footer
              if (widget.footers != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ...widget.footers!,
                  ],
                )
            ],
          );
  }
}

/// `TextEditableWidget`
///
/// use to display when user allow any header columns to be editable
class TextEditableWidget extends StatelessWidget {
  /// `data`
  ///
  /// current data as Map
  final Map<String, dynamic> data;

  /// `header`
  ///
  /// current editable text header
  final DatatableHeader header;

  /// `textAlign`
  ///
  /// by default textAlign will be center
  final TextAlign textAlign;

  /// `hideUnderline`
  ///
  /// allow use to decorate hideUnderline false or true
  final bool hideUnderline;

  /// `onChanged`
  ///
  /// trigger the call back update when user make any text change
  final Function(Map<String, dynamic> vaue, DatatableHeader header)? onChanged;

  /// `onSubmitted`
  ///
  /// trigger the call back when user press done or enter
  final Function(Map<String, dynamic> vaue, DatatableHeader header)? onSubmitted;

  const TextEditableWidget({
    Key? key,
    required this.data,
    required this.header,
    this.textAlign = TextAlign.center,
    this.hideUnderline = false,
    this.onChanged,
    this.onSubmitted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 150),
      padding: const EdgeInsets.all(0),
      margin: const EdgeInsets.all(0),
      child: TextField(
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(0),
          border: hideUnderline
              ? InputBorder.none
              : const UnderlineInputBorder(
                  borderSide: BorderSide(
                    width: .5,
                  ),
                ),
          alignLabelWithHint: true,
        ),
        textAlign: textAlign,
        controller: TextEditingController.fromValue(
          TextEditingValue(text: "${data[header.value]}"),
        ),
        onChanged: (newValue) {
          data[header.value] = newValue;
          onChanged?.call(data, header);
        },
        onSubmitted: (x) => onSubmitted?.call(data, header),
      ),
    );
  }
}
