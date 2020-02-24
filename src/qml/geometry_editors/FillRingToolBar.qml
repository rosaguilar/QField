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
      var closeLine = true
      var line = drawPolygonToolbar.rubberbandModel.pointSequence(featureModel.currentLayer.crs, featureModel.currentLayer.wkbType(), closeLine)
      if (!featureModel.currentLayer.editBuffer())
        featureModel.currentLayer.startEditing()
      var result = featureModel.currentLayer.addRing(line, featureModel.feature.id)
      if ( result !== QgsGeometryStatic.Success )
      {
        // TODO WARN
        /*
      AddRingNotClosed, //!< The input ring is not closed
      AddRingNotValid, //!< The input ring is not valid
      AddRingCrossesExistingRings, //!< The input ring crosses existing rings (it is not disjoint)
      AddRingNotInExistingFeature
      */
        featureModel.currentLayer.rollBack()
      }
      else
      {
        polygonGeometry = QFieldUtils.lineToPolygonGeometry(line)

        // Show form
        var popupComponent = Qt.createComponent("qrc:/EmbeddedFeatureForm.qml")
        var popup2 = popupComponent.createObject(drawPolygonToolbar);
        popup2.open()


        embeddedPopup.state = 'Add'
        embeddedPopup.attributeFormModel.featureModel.currentLayer = featureModel.currentLayer
        embeddedPopup.attributeFormModel.featureModel.resetAttributes()
        embeddedPopup.open()
      }
      cancel()
      finished()
    }
  }

  function init(featureModel, mapSettings, editorRubberbandModel)
  {
    fillRingToolbar.featureModel = featureModel
    drawPolygonToolbar.rubberbandModel = editorRubberbandModel
    drawPolygonToolbar.rubberbandModel.geometryType = QgsWkbTypes.PolygonGeometry
    drawPolygonToolbar.mapSettings = mapSettings
    drawPolygonToolbar.stateVisible = true
  }

  function cancel()
  {
    drawPolygonToolbar.cancel()
  }

}
