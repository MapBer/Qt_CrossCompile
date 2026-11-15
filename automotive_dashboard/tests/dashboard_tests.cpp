#include "model/dashboardmodel.h"
#include "controller/dashboardcontroller.h"
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickWindow>
#include <QQuickStyle>
#include <QMetaProperty>
#include <cmath>
#include <iostream>
#include <limits>

int main(int argc, char **argv)
{
    QGuiApplication app(argc,argv);
    QQuickStyle::setStyle("Basic");
    int failures=0;
    auto check=[&](bool passed,const char *message) {
        if (!passed) { std::cerr<<"FAIL: "<<message<<'\n'; ++failures; }
    };
    DashboardModel model;
    DashboardController controller(&model);
    DashboardState invalid;
    invalid.speed=-3; invalid.fuel=120; invalid.rpm=9000;
    invalid.coolant=std::numeric_limits<double>::quiet_NaN();
    model.setState(invalid);
    check(model.state().speed==0 && model.state().fuel==100 && model.state().rpm==8000 && model.state().coolant==0,"model validates out-of-range and non-finite values");
    model.setState(DashboardState{});
    controller.setTargetSpeed(100);
    for(int i=0;i<100;++i) controller.advance(.1);
    check(model.state().speed==0,"engine off cannot accelerate");
    controller.setIgnition(true);
    const double trip=model.state().trip;
    for(int i=0;i<100;++i) controller.advance(.1);
    check(std::abs(model.state().speed-100)<.01 && model.state().rpm>800,"engine reaches requested speed");
    check(model.state().trip>trip && model.state().fuel<72,"distance and fuel integrate while driving");
    controller.setIgnition(false);
    for(int i=0;i<100;++i) controller.advance(.1);
    check(model.state().speed==0 && model.state().rpm<1 && !model.state().demo,"ignition off brings vehicle to rest");
    controller.setDemo(true);
    controller.advance(.1);
    check(model.state().ignition && model.state().targetSpeed>0,"auto drive starts engine and requests speed");
    controller.setTargetSpeed(60);
    check(!model.state().demo,"manual target exits auto drive");
    controller.setTurn(-1);
    check(model.state().turn==-1 && model.state().blink,"left turn activates immediately");
    for(int i=0;i<6;++i) controller.advance(.1);
    check(!model.state().blink,"indicators blink off after half a second");
    controller.setHazards(true);
    check(model.state().hazards && model.state().blink,"hazards activate immediately");
    controller.setFuel(0);
    for(int i=0;i<100;++i) controller.advance(.1);
    check(model.state().speed==0 && model.state().rpm<1,"empty fuel stops simulated engine");
    controller.resetTrip();
    check(model.state().trip==0 && model.state().odometer>=157256,"trip reset preserves odometer");

    model.setState(DashboardState{});
    QQmlApplicationEngine engine;
    int qmlWarnings=0;
    QObject::connect(&engine,&QQmlEngine::warnings,[&](const QList<QQmlError> &errors) {
        qmlWarnings+=errors.size();
        for(const auto &error:errors) std::cerr<<error.toString().toStdString()<<'\n';
    });
    engine.rootContext()->setContextProperty("vehicleModel", &model);
    engine.rootContext()->setContextProperty("dashboardController", &controller);
    engine.load(QUrl("qrc:/qml/Dashboard.qml"));
    check(!engine.rootObjects().isEmpty(),"QML dashboard loads from embedded resources");
    if (engine.rootObjects().isEmpty()) return 1;
    auto root=engine.rootObjects().first();
    auto click=[&](const char *name) {
        auto button=root->findChild<QObject *>(name);
        check(button && QMetaObject::invokeMethod(button,"clicked"),name);
    };
    click("ignition");
    check(model.state().ignition,"QML ignition button routes command through controller");
    click("demo");
    check(model.state().demo,"QML auto drive button routes command through controller");
    click("headlights"); click("hazards"); click("left");
    check(model.state().headlights && model.state().hazards && model.state().turn==-1,"QML light and indicator controls update model through controller");
    auto speedSlider=root->findChild<QObject *>("speedSlider");
    check(speedSlider!=nullptr,"QML target speed slider exists");
    if (speedSlider) {
        speedSlider->setProperty("value",80);
        QMetaObject::invokeMethod(speedSlider,"moved");
        check(model.state().targetSpeed==80 && !model.state().demo,"moving QML speed slider sets target and exits auto drive");
    }
    auto fuelSlider=root->findChild<QObject *>("fuelSlider");
    if (fuelSlider) {
        fuelSlider->setProperty("value",10);
        QMetaObject::invokeMethod(fuelSlider,"moved");
    }
    check(fuelSlider && model.state().fuel==10,"QML fuel slider routes command through controller");
    auto updated=model.state(); updated.speed=65; updated.targetSpeed=90; model.setState(updated);
    auto speedGauge=root->findChild<QObject *>("speedGauge");
    check(speedGauge && speedGauge->property("value").toDouble()==65,"QML gauge binding follows C++ model notification");
    check(model.state().targetSpeed==90,"model notifications do not emit slider commands");
    const auto property=model.metaObject()->property(model.metaObject()->indexOfProperty("speed"));
    check(!property.isWritable(),"model properties exposed to QML are read-only");
    click("resetTrip");
    check(model.state().trip==0,"QML reset button clears trip");
    auto window=qobject_cast<QQuickWindow *>(root);
    check(window!=nullptr,"QML view is a Qt Quick window");
    if(window) { window->resize(960,700); app.processEvents(); }
    check(qmlWarnings==0,"QML initializes and updates without runtime warnings");
    std::cout<<(failures ? "FAILED" : "PASS")<<": dashboard MVC checks\n";
    return failures?1:0;
}
