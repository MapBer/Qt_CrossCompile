#include "model/dashboardmodel.h"
#include "controller/dashboardcontroller.h"
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickWindow>
#include <QQuickStyle>
#include <QTimer>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QQuickStyle::setStyle("Basic");
    DashboardModel model;
    DashboardController controller(&model);
    // Destruction order keeps the backend alive until the QML engine is gone.
    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("vehicleModel", &model);
    engine.rootContext()->setContextProperty("dashboardController", &controller);
    engine.load(QUrl(QStringLiteral("qrc:/qml/Dashboard.qml")));
    if (engine.rootObjects().isEmpty()) return 1;
    auto window = qobject_cast<QQuickWindow *>(engine.rootObjects().first());
    if (!window) return 1;
    const QStringList args = app.arguments();
    if (args.contains("--demo")) controller.setDemo(true);
    if (args.contains("--compact")) { window->setWidth(960); window->setHeight(700); }
    const int snapshot = args.indexOf("--snapshot");
    if (!args.contains("--compact") && snapshot < 0)
        window->showMaximized();
    if (snapshot >= 0 && snapshot + 1 < args.size()) {
        QTimer::singleShot(1200, window, [&] {
            app.exit(window->grabWindow().save(args.at(snapshot + 1)) ? 0 : 1);
        });
    }
    return app.exec();
}
