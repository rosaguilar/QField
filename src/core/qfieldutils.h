#ifndef QFIELDUTILS_H
#define QFIELDUTILS_H

#include <QObject>

#include <qgsgeometry.h>
#include <qgsabstractgeometry.h>

class QFieldUtils : public QObject
{
  Q_OBJECT
public:
  explicit QFieldUtils(QObject *parent = nullptr);

  static QgsGeometry lineToPolygonGeometry(const QgsPointSequence &pointSequence );

signals:

public slots:
};

#endif // QFIELDUTILS_H
