#include "dashboardcontroller.h"
#include "model/dashboardmodel.h"
#include <algorithm>
#include <cmath>

DashboardController::DashboardController(DashboardModel *model, QObject *parent)
    : QObject(parent), m_model(model)
{
    m_elapsed.start();
    connect(&m_timer, &QTimer::timeout, this, [this] {
        advance(std::min(m_elapsed.restart() / 1000.0, 0.1));
    });
    m_timer.start(16);
}
void DashboardController::setIgnition(bool on)
{
    auto s = m_model->state();
    s.ignition = on;
    if (!on) { s.demo = false; s.targetSpeed = 0; }
    m_model->setState(s);
}
void DashboardController::setDemo(bool on)
{
    auto s = m_model->state(); s.demo = on;
    if (on) { s.ignition = true; m_time = 0; }
    else s.targetSpeed = s.speed;
    m_model->setState(s);
}
void DashboardController::setHeadlights(bool on)
{ auto s = m_model->state(); s.headlights = on; m_model->setState(s); }
void DashboardController::setHazards(bool on)
{ auto s = m_model->state(); s.hazards = on; m_blinkTime = 0; s.blink = on || s.turn != 0; m_model->setState(s); }
void DashboardController::setTurn(int direction)
{
    auto s = m_model->state();
    s.turn = s.turn == direction ? 0 : direction;
    m_blinkTime = 0; s.blink = s.hazards || s.turn != 0;
    m_model->setState(s);
}
void DashboardController::setTargetSpeed(int speed)
{ auto s = m_model->state(); s.demo = false; s.targetSpeed = speed; m_model->setState(s); }
void DashboardController::setFuel(int percent)
{ auto s = m_model->state(); s.fuel = percent; m_model->setState(s); }
void DashboardController::resetTrip()
{ auto s = m_model->state(); s.trip = 0; m_model->setState(s); }
void DashboardController::advance(double seconds)
{
    if (!std::isfinite(seconds) || seconds <= 0) return;
    const double dt = std::min(seconds, 0.1);
    auto s = m_model->state();
    m_time += dt;
    m_blinkTime = std::fmod(m_blinkTime + dt, 1.0);
    s.blink = (s.hazards || s.turn != 0) && m_blinkTime < 0.5;
    if (s.demo) s.targetSpeed = 95 + 65 * std::sin(m_time * 0.16 - 0.8);
    const bool running = s.ignition && s.fuel > 0;
    const double oldSpeed = s.speed;
    s.speed += std::clamp((running ? s.targetSpeed : 0) - s.speed, -28 * dt, 16 * dt);
    const double rpm = running ? (s.speed < 1 ? 850 : 1400 + std::fmod(s.speed, 42.0) * 87) : 0;
    s.rpm += (rpm - s.rpm) * std::min(1.0, dt * 5);
    s.voltage = running ? 14.2 : 12.6;
    s.coolant += ((running ? 90 : 24) - s.coolant) * dt * 0.015;
    const double distance = (oldSpeed + s.speed) * 0.5 * dt / 3600;
    s.trip += distance; s.odometer += distance;
    if (running) s.fuel -= dt * 0.0005 + distance * 0.055;
    m_model->setState(s);
}
