import 'package:appflowy/plugins/document/presentation/editor_plugins/base/selectable_svg_widget.dart';
import 'package:appflowy_backend/protobuf/flowy-folder2/view.pb.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy/generated/locale_keys.g.dart';
import 'package:appflowy/plugins/document/application/prelude.dart';
import 'package:appflowy/plugins/document/presentation/editor_plugins/base/insert_page_command.dart';
import 'package:appflowy/workspace/application/app/app_service.dart';
import 'package:easy_localization/easy_localization.dart';

SelectionMenuItem boardViewMenuItem(DocumentBloc documentBloc) =>
    SelectionMenuItem(
      name: LocaleKeys.document_slashMenu_board_createANewBoard.tr(),
      icon: (editorState, onSelected, style) => SelectableSvgWidget(
        name: 'editor/board',
        isSelected: onSelected,
        style: style,
      ),
      keywords: ['board', 'kanban'],
      handler: (editorState, menuService, context) async {
        if (!documentBloc.view.hasParentViewId()) {
          return;
        }

        final appId = documentBloc.view.parentViewId;
        final service = AppBackendService();

        final result = (await service.createView(
          parentViewId: appId,
          name: LocaleKeys.menuAppHeader_defaultNewPageName.tr(),
          layoutType: ViewLayoutPB.Board,
        ))
            .getLeftOrNull();

        // If the result is null, then something went wrong here.
        if (result == null) {
          return;
        }

        final app = (await service.getView(result.viewId)).getLeftOrNull();
        // We should show an error dialog.
        if (app == null) {
          return;
        }

        final view = (await service.getChildView(result.viewId, result.id))
            .getLeftOrNull();
        // As this.
        if (view == null) {
          return;
        }

        editorState.insertPage(app, view);
      },
    );