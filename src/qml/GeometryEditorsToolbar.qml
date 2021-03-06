import QtQuick 2.12
import QtQml.Models 2.12
import org.qgis 1.0
import org.qfield 1.0
import Theme 1.0


/**
This contains several geometry editing tools
A tool must subclass VisibilityFadingRow
And contains following functions:
  * function init(featureModel, mapSettings, editorRubberbandModel)
  * function cancel()
The following signal:
  * signal finished()
*/

VisibilityFadingRow {
  id: geometryEditorsToolbar

  property FeatureModel featureModel
  property MapSettings mapSettings
  property RubberbandModel editorRubberbandModel

  spacing: 4 * dp

  GeometryEditorsModel {
    id: editors
  }
  Component.onCompleted: {
    editors.addEditor("Vertex tool", "ray-vertex", "VertexEditorToolbar.qml")
    editors.addEditor("Split tool", "content-cut", "SplitFeatureToolbar.qml", GeometryEditorsModelSingleton.Line | GeometryEditorsModelSingleton.Polygon)
  }

  function init() {
    selectorRow.stateVisible = false
    var lastUsed = settings.setValue( "/QField/GeometryEditorLastUsed", 0 )
    var toolbarQml = editors.data(editors.index(lastUsed,0), GeometryEditorsModelSingleton.ToolbarRole)
    var iconPath = editors.data(editors.index(lastUsed,0), GeometryEditorsModelSingleton.IconPathRole)
    toolbarRow.load(toolbarQml, iconPath)
  }

  function cancelEditors() {
    if (toolbarRow.item)
      toolbarRow.item.cancel()
    featureModel.vertexModel.clear()
  }

  VisibilityFadingRow {
    id: selectorRow
    stateVisible: false

    spacing: 4 * dp

    Repeater {
      model: editors
      delegate: Button {
        round: true
        bgcolor: Theme.mainColor
        iconSource: Theme.getThemeIcon(iconPath)
        visible: GeometryEditorsModelSingleton.supportsGeometry(featureModel.vertexModel.geometry, supportedGeometries)
        onClicked: {
          // close current tool if any
          if (toolbarRow.item)
            toolbarRow.item.cancel()
          selectorRow.stateVisible = false
          toolbarRow.load(toolbar, iconPath)
          settings.setValue( "/QField/GeometryEditorLastUsed", index )
          displayToast(name)
        }
      }
    }
  }

  Loader {
    id: toolbarRow

    width: item && item.stateVisible ? item.implicitWidth : 0

    function load(qmlSource, iconPath){
      source = qmlSource
      item.init(geometryEditorsToolbar.featureModel, geometryEditorsToolbar.mapSettings, geometryEditorsToolbar.editorRubberbandModel)
      toolbarRow.item.stateVisible = true
      activeToolButton.iconSource = Theme.getThemeIcon(iconPath)
    }
  }

  Connections {
      target: toolbarRow.item
      onFinished: featureModel.vertexModel.clear()
  }

  Button {
    id: activeToolButton
    round: true
    visible: !selectorRow.stateVisible && !( toolbarRow.item && toolbarRow.item.stateVisible && toolbarRow.item.blocking )
    bgcolor: Theme.mainColor
    onClicked: {
      toolbarRow.source = ''
      selectorRow.stateVisible = true
    }
  }

}
