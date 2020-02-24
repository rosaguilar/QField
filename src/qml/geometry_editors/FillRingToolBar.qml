import ".."
import QtQuick 2.12
import org.qgis 1.0
import org.qfield 1.0
import Theme 1.0
import Utils 1.0


VisibilityFadingRow {
  id: fillRingToolbar

  signal finished()

  property FeatureModel featureModel
  readonly property bool blocking: drawPolygonToolbar.isDigitizing

  spacing: 4 * dp

  DigitizingToolbar {
    id: drawPolygonToolbar
    showConfirmButton: true

    onConfirm: {
      var line = drawLineToolbar.rubberbandModel.pointSequence(featureModel.currentLayer.crs)
      if (!featureModel.currentLayer.editBuffer())
        featureModel.currentLayer.startEditing()
      var result = featureModel.currentLayer.addRing( line, featureModel.feature.id)
      if ( result !== QgsGeometryStatic.Success )
      {
        // TODO WARN
        featureModel.currentLayer.rollBack()
      }
      else
      {

        polygonGeometry = QFieldUtils.lineToPolygonGeometry(line)


        // TODO SHOW FORM

        featureModel.currentLayer.commitChanges()
      }
      cancel()
      finished()
    }


  }

  function init(featureModel, mapSettings, editorRubberbandModel)
  {
    splitFeatureToolbar.featureModel = featureModel
    drawPolygonToolbar.rubberbandModel = editorRubberbandModel
    drawPolygonToolbar.mapSettings = mapSettings
    drawPolygonToolbar.stateVisible = true
  }

  function cancel()
  {
    drawPolygonToolbar.cancel()
  }

}
