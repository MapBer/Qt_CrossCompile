#pragma once
#include <QObject>

struct DashboardState
{
    double speed = 0;
    double rpm = 0;
    double fuel = 72;
    double coolant = 24;
    double voltage = 12.6;
    double odometer = 157256;
    double trip = 135.4;
    double targetSpeed = 0;
    bool ignition = false;
    bool demo = false;
    bool headlights = false;
    bool hazards = false;
    bool blink = false;
    int turn = 0; // -1: left, 0: off, +1: right
};

// Validated vehicle state, independent of widgets and painting.
class DashboardModel : public QObject
{
    Q_OBJECT
    Q_PROPERTY(double speed READ speed NOTIFY propertiesChanged)
    Q_PROPERTY(double rpm READ rpm NOTIFY propertiesChanged)
    Q_PROPERTY(double fuel READ fuel NOTIFY propertiesChanged)
    Q_PROPERTY(double coolant READ coolant NOTIFY propertiesChanged)
    Q_PROPERTY(double voltage READ voltage NOTIFY propertiesChanged)
    Q_PROPERTY(double odometer READ odometer NOTIFY propertiesChanged)
    Q_PROPERTY(double trip READ trip NOTIFY propertiesChanged)
    Q_PROPERTY(double targetSpeed READ targetSpeed NOTIFY propertiesChanged)
    Q_PROPERTY(bool ignition READ ignition NOTIFY propertiesChanged)
    Q_PROPERTY(bool demo READ demo NOTIFY propertiesChanged)
    Q_PROPERTY(bool headlights READ headlights NOTIFY propertiesChanged)
    Q_PROPERTY(bool hazards READ hazards NOTIFY propertiesChanged)
    Q_PROPERTY(bool blink READ blink NOTIFY propertiesChanged)
    Q_PROPERTY(int turn READ turn NOTIFY propertiesChanged)
public:
    explicit DashboardModel(QObject *parent = nullptr) : QObject(parent) {}
    const DashboardState &state() const { return m_state; }
    double speed() const { return m_state.speed; }
    double rpm() const { return m_state.rpm; }
    double fuel() const { return m_state.fuel; }
    double coolant() const { return m_state.coolant; }
    double voltage() const { return m_state.voltage; }
    double odometer() const { return m_state.odometer; }
    double trip() const { return m_state.trip; }
    double targetSpeed() const { return m_state.targetSpeed; }
    bool ignition() const { return m_state.ignition; }
    bool demo() const { return m_state.demo; }
    bool headlights() const { return m_state.headlights; }
    bool hazards() const { return m_state.hazards; }
    bool blink() const { return m_state.blink; }
    int turn() const { return m_state.turn; }
    void setState(DashboardState state);
signals:
    void propertiesChanged();
    void stateChanged(const DashboardState &state);
private:
    DashboardState m_state;
};
