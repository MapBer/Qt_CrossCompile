#pragma once
#include <QObject>
#include <QElapsedTimer>
#include <QTimer>
class DashboardModel;

// User commands and simulation behavior; no dependency on the view.
class DashboardController : public QObject
{
    Q_OBJECT
public:
    explicit DashboardController(DashboardModel *model, QObject *parent = nullptr);
    void advance(double seconds);
public slots:
    void setIgnition(bool on);
    void setDemo(bool on);
    void setHeadlights(bool on);
    void setHazards(bool on);
    void setTurn(int direction);
    void setTargetSpeed(int speed);
    void setFuel(int percent);
    void resetTrip();
private:
    DashboardModel *m_model;
    QTimer m_timer;
    QElapsedTimer m_elapsed;
    double m_time = 0;
    double m_blinkTime = 0;
};
