#include "dashboardmodel.h"
#include <algorithm>
#include <cmath>

void DashboardModel::setState(DashboardState state)
{
    auto clamp = [](double value, double low, double high) {
        return std::isfinite(value) ? std::clamp(value, low, high) : low;
    };
    state.speed = clamp(state.speed, 0, 280);
    state.rpm = clamp(state.rpm, 0, 8000);
    state.fuel = clamp(state.fuel, 0, 100);
    state.coolant = clamp(state.coolant, 0, 130);
    state.voltage = clamp(state.voltage, 0, 16);
    state.targetSpeed = clamp(state.targetSpeed, 0, 240);
    state.odometer = clamp(state.odometer, 0, 9999999);
    state.trip = clamp(state.trip, 0, 99999);
    state.turn = std::clamp(state.turn, -1, 1);
    m_state = state;
    emit propertiesChanged();
    emit stateChanged(m_state);
}
