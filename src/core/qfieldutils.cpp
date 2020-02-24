#include "qfieldutils.h"

#include <qgslinestring.h>
#include <qgspolygon.h>

QFieldUtils::QFieldUtils(QObject *parent) : QObject(parent)
{

}

QgsGeometry QFieldUtils::lineToPolygonGeometry(const QgsPointSequence &pointSequence)
{
  QgsLineString ext( pointSequence );
  std::unique_ptr< QgsPolygon > polygon = qgis::make_unique< QgsPolygon >( );
  polygon->setExteriorRing( ext.clone() );
  QgsGeometry g( std::move( polygon ) );
  return g;
}
