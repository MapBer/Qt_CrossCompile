import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ApplicationWindow {
    id: dashboard
    width: 1280; height: 840
    minimumWidth: 640; minimumHeight: 360
    visible: true
    title: "IGNITION | Automotive Dashboard"
    color: "#0b0e14"
    font.family: "Segoe UI"
    property string clockText: Qt.formatDateTime(new Date(), "ddd, dd MMM   |   HH:mm")
    readonly property bool engineStopped: vehicleModel.ignition && vehicleModel.rpm < 100

    Timer {
        interval: 1000; running: true; repeat: true
        onTriggered: dashboard.clockText = Qt.formatDateTime(new Date(), "ddd, dd MMM   |   HH:mm")
    }
    component Caption: Text {
        color: "#778293"; font.pixelSize: 12
        horizontalAlignment: Text.AlignHCenter
    }
    component MiniGauge: Item {
        id: mini
        property real ratio: 0
        property string kind
        property string reading
        property string low
        property string high
        property color accent: "#42e5a2"
        width: 116; height: 140
        onRatioChanged: ring.requestPaint()
        onAccentChanged: ring.requestPaint()
        Canvas {
            id: ring
            width: 116; height: 116
            onPaint: {
                var c = getContext("2d"); c.reset()
                function arc(end,color) {
                    c.beginPath(); c.strokeStyle=color; c.lineWidth=4; c.lineCap="round"
                    c.arc(58,58,51,-220*Math.PI/180,end*Math.PI/180,false); c.stroke()
                }
                arc(40,"#2a313c")
                arc((-220+260*Math.min(1,Math.max(0,mini.ratio))),mini.accent)
            }
        }
        Telltale { anchors.horizontalCenter: parent.horizontalCenter; y: 32; kind: mini.kind; caption: ""; active: true; activeColor: mini.accent }
        Caption { anchors.horizontalCenter: parent.horizontalCenter; y: 82; text: mini.reading; color: "#e9edf4"; font.bold: true; font.pixelSize: 14 }
        Caption { x: 8; y: 108; text: mini.low; font.pixelSize: 10 }
        Caption { x: 99; y: 108; text: mini.high; font.pixelSize: 10 }
    }

    // Scale controls, text and gauges together from the original design size.
    Item {
        id: designSurface
        readonly property real uiScale: Math.max(0.01,
            Math.min(dashboard.contentItem.width / 1280,
                     dashboard.contentItem.height / 840))
        width: dashboard.contentItem.width / uiScale
        height: dashboard.contentItem.height / uiScale
        scale: uiScale
        transformOrigin: Item.TopLeft

        ColumnLayout {
            anchors.fill: parent; anchors.margins: 24
            anchors.topMargin: 8; anchors.bottomMargin: 10
            spacing: 8
            Item {
                Layout.fillWidth: true; Layout.fillHeight: true
                Item {
                    id: stage
                    width: 1200; height: 600
                    anchors.centerIn: parent
                    scale: Math.min(parent.width / width, parent.height / height)
                    Text { x: 24; y: 12; text: "IGNITION"; color: "#e9edf4"; font.pixelSize: 25; font.bold: true }
                    Caption { x: 200; y: 24; text: "D I G I T A L   C O C K P I T"; font.pixelSize: 10 }
                    Caption { x: 966; y: 24; width: 205; text: dashboard.clockText }
                    Rectangle { x: 24; y: 61; width: 1152; height: 1; color: "#252b36" }
                    Row {
                        x: 240; y: 84
                        Telltale { kind: "lights"; caption: "HIGH BEAM"; active: vehicleModel.headlights; activeColor: "#51caff" }
                        Telltale { kind: "battery"; caption: "BATTERY"; active: dashboard.engineStopped }
                        Telltale { kind: "oil"; caption: "OIL"; active: dashboard.engineStopped }
                        Telltale { kind: "brake"; caption: "BRAKE"; active: vehicleModel.speed < 1 }
                        Telltale { kind: "engine"; caption: "ENGINE"; active: dashboard.engineStopped; activeColor: "#ffc75a" }
                        Telltale { kind: "abs"; caption: "ABS"; active: false; activeColor: "#ffc75a" }
                        Telltale { kind: "temp"; caption: "COOLANT"; active: vehicleModel.coolant > 110 }
                        Telltale { kind: "fuel"; caption: "LOW FUEL"; active: vehicleModel.fuel < 15; activeColor: "#ffc75a" }
                    }
                    TurnArrow {
                        x: 476; y: 159
                        active: vehicleModel.blink && (vehicleModel.hazards || vehicleModel.turn < 0)
                    }
                    Caption { x: 542; y: 169; width: 116; text: vehicleModel.hazards ? "HAZARD" : "INDICATORS"; font.pixelSize: 9; color: vehicleModel.hazards ? "#ffc75a" : "#778293" }
                    TurnArrow {
                        x: 684; y: 159; pointsRight: true
                        active: vehicleModel.blink && (vehicleModel.hazards || vehicleModel.turn > 0)
                    }
                    Gauge {
                        objectName: "rpmGauge"
                        x: 130; y: 150
                        value: vehicleModel.rpm / 1000; maximum: 8; step: 1; decimals: 1
                        title: "TACHOMETER"; unit: "x 1000 r/min"
                    }
                    Gauge { objectName: "speedGauge"; x: 690; y: 150; value: vehicleModel.speed }
                    Caption { x: 525; y: 250; width: 150; text: vehicleModel.ignition ? "DRIVE SYSTEM" : "SYSTEM STANDBY"; font.pixelSize: 10; font.bold: true }
                    Caption {
                        x: 540; y: 276; width: 120
                        text: !vehicleModel.ignition ? "P" : vehicleModel.speed < 1 ? "N" : Math.min(6,1+Math.floor(vehicleModel.speed/42))
                        font.pixelSize: 78; font.bold: true; color: vehicleModel.ignition ? "#e9edf4" : "#778293"
                    }
                    Caption { x: 525; y: 380; width: 150; text: vehicleModel.speed < 1 ? "STATIONARY" : "AUTOMATIC"; font.pixelSize: 10; font.bold: true }
                    Rectangle {
                        x: 517; y: 424; width: 166; height: 67; radius: 9
                        color: "#111c2a"; border.color: "#223c56"
                        Caption { width: parent.width; y: 8; text: "ODOMETER / km"; font.pixelSize: 9; font.bold: true; color: "#81b8df" }
                        Caption { width: parent.width; y: 28; text: Math.floor(vehicleModel.odometer).toString().padStart(6,"0"); font.pixelSize: 26; font.bold: true; color: "#b5ddff" }
                    }
                    MiniGauge {
                        x: 25; y: 358; ratio: vehicleModel.coolant/130; kind: "temp"
                        reading: vehicleModel.coolant.toFixed(0)+"°C"; low: "C"; high: "H"
                        accent: vehicleModel.coolant > 110 ? "#ff4945" : "#75bfe5"
                    }
                    MiniGauge {
                        x: 1059; y: 358; ratio: vehicleModel.fuel/100; kind: "fuel"
                        reading: vehicleModel.fuel.toFixed(0)+"%"; low: "E"; high: "F"
                        accent: vehicleModel.fuel < 15 ? "#ffc75a" : "#42e5a2"
                    }
                    Rectangle { x: 24; y: 541; width: 1152; height: 1; color: "#252b36" }
                    Caption { x: 24; y: 561; width: 215; text: "TRIP A   "+vehicleModel.trip.toFixed(1)+" km"; color: "#e9edf4" }
                    Caption { x: 279; y: 561; width: 210; text: "BATTERY   "+vehicleModel.voltage.toFixed(1)+" V" }
                    Caption { x: 546; y: 561; width: 215; text: "AMBIENT   24°C" }
                    Caption {
                        x: 860; y: 561; width: 316; font.pixelSize: 11; font.bold: true
                        text: vehicleModel.fuel < 15 ? "LOW FUEL / REFUEL SOON" : vehicleModel.demo ? "SIMULATION IN PROGRESS" : vehicleModel.ignition ? "ENGINE ONLINE" : "READY WHEN YOU ARE"
                        color: vehicleModel.fuel < 15 ? "#ffc75a" : vehicleModel.ignition ? "#42e5a2" : "#778293"
                    }
                }
            }
            Rectangle {
                Layout.fillWidth: true; implicitHeight: 178
                color: "#121720"; radius: 12; border.color: "#272f3b"
                ColumnLayout {
                    anchors.fill: parent; anchors.margins: 20; spacing: 12
                    RowLayout {
                        Layout.fillWidth: true
                        Caption { text: "SIMULATOR CONTROLS"; color: "#b6c0cf"; font.pixelSize: 10; font.bold: true; font.letterSpacing: 2 }
                        Item { Layout.fillWidth: true }
                        DashboardButton { objectName: "demo"; text: "Auto drive"; active: vehicleModel.demo; implicitHeight: 28; onClicked: dashboardController.setDemo(!vehicleModel.demo) }
                    }
                    RowLayout {
                        spacing: 10
                        DashboardButton { objectName: "ignition"; text: vehicleModel.ignition ? "STOP ENGINE" : "START ENGINE"; primary: true; active: vehicleModel.ignition; implicitWidth: 145; onClicked: dashboardController.setIgnition(!vehicleModel.ignition) }
                        DashboardButton { objectName: "headlights"; text: "High beam"; active: vehicleModel.headlights; onClicked: dashboardController.setHeadlights(!vehicleModel.headlights) }
                        DashboardButton { objectName: "hazards"; text: "Hazards"; active: vehicleModel.hazards; onClicked: dashboardController.setHazards(!vehicleModel.hazards) }
                        DashboardButton { objectName: "left"; text: "← Left"; active: vehicleModel.turn < 0; onClicked: dashboardController.setTurn(-1) }
                        DashboardButton { objectName: "right"; text: "Right →"; active: vehicleModel.turn > 0; onClicked: dashboardController.setTurn(1) }
                    }
                    RowLayout {
                        Layout.fillWidth: true; spacing: 28
                        ColumnLayout {
                            Layout.fillWidth: true; Layout.preferredWidth: 2
                            Caption { text: "TARGET  "+vehicleModel.targetSpeed.toFixed(0)+" km/h" }
                            DashboardSlider {
                                objectName: "speedSlider"; Layout.fillWidth: true
                                from: 0; to: 240; value: vehicleModel.targetSpeed
                                Accessible.name: "Target speed in kilometers per hour"
                                onMoved: dashboardController.setTargetSpeed(Math.round(value))
                            }
                        }
                        ColumnLayout {
                            Layout.fillWidth: true; Layout.preferredWidth: 1
                            Caption { text: "FUEL  "+vehicleModel.fuel.toFixed(0)+"%" }
                            DashboardSlider {
                                objectName: "fuelSlider"; Layout.fillWidth: true
                                from: 0; to: 100; value: vehicleModel.fuel
                                Accessible.name: "Fuel percentage"
                                onMoved: dashboardController.setFuel(Math.round(value))
                            }
                        }
                    }
                }
            }
            RowLayout {
                Layout.fillWidth: true
                Caption {
                    Layout.fillWidth: true; horizontalAlignment: Text.AlignLeft
                    text: vehicleModel.fuel <= 0 ? "Fuel empty. Add fuel to resume driving." : vehicleModel.demo ? "Auto drive active / adjust target speed to take control" : vehicleModel.ignition ? "Engine running / adjust target speed to drive" : "Start the engine or enable Auto drive to begin"
                    font.pixelSize: 11; elide: Text.ElideRight
                }
                DashboardButton { objectName: "resetTrip"; text: "Reset trip"; implicitHeight: 28; onClicked: dashboardController.resetTrip() }
                Caption { text: "  Qt Quick / MVC"; font.pixelSize: 11 }
            }
        }
    }
}
