import QtQuick 2.15

Item {
    id: gauge
    property real value: 0
    property real maximum: 280
    property int step: 20
    property string title: "SPEEDOMETER"
    property string unit: "km/h"
    property int decimals: 0
    width: 380
    height: 380

    Rectangle {
        anchors.centerIn: parent
        width: 360; height: width; radius: width / 2
        color: "#10141d"
        border.color: "#48232b"; border.width: 2
    }
    Canvas {
        id: face
        anchors.fill: parent
        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            var c = width / 2, r = 174
            function point(radius, angle) {
                var a = angle * Math.PI / 180
                return {x: c + Math.cos(a) * radius, y: c - Math.sin(a) * radius}
            }
            function arc(radius, start, end, color, lineWidth) {
                ctx.beginPath()
                ctx.strokeStyle = color; ctx.lineWidth = lineWidth
                ctx.arc(c, c, radius, -start * Math.PI / 180, -end * Math.PI / 180, false)
                ctx.stroke()
            }
            arc(r + 6, 220, -40, "#21171e", 15)
            arc(r + 4, 220, -40, "#3c1c25", 5)
            arc(r, 220, -40, "#3b3b46", 2)
            arc(r - 10, 12, -40, "#a53640", 4)
            var ticks = gauge.maximum / gauge.step * 5
            for (var i = 0; i <= ticks; ++i) {
                var a = 220 - 260 * i / ticks
                var major = i % 5 === 0
                var p1 = point(r - 17, a), p2 = point(r - (major ? 30 : 23), a)
                ctx.beginPath(); ctx.moveTo(p1.x,p1.y); ctx.lineTo(p2.x,p2.y)
                ctx.lineWidth = major ? 2 : 1
                ctx.strokeStyle = i > ticks * .8 ? "#ff4945" : major ? "#c5cbd6" : "#535c6a"
                ctx.stroke()
            }
        }
    }
    Canvas {
        id: progress
        anchors.fill: parent
        Connections { target: gauge; function onValueChanged() { progress.requestPaint() } }
        onPaint: {
            var c = getContext("2d"); c.reset()
            c.beginPath(); c.strokeStyle = "#ff4945"; c.lineWidth = 3; c.lineCap = "round"
            c.arc(190,190,174,-220*Math.PI/180,(-220+260*gauge.value/gauge.maximum)*Math.PI/180,false)
            c.stroke()
        }
    }
    Repeater {
        model: gauge.maximum / gauge.step + 1
        Text {
            required property int index
            readonly property real angle: (220 - 260 * index * gauge.step / gauge.maximum) * Math.PI / 180
            x: 190 + Math.cos(angle) * 126 - width / 2
            y: 190 - Math.sin(angle) * 126 - height / 2
            text: index * gauge.step
            color: "#e9edf4"; font.pixelSize: 18
        }
    }
    Text {
        anchors.horizontalCenter: parent.horizontalCenter; y: 116
        text: gauge.title; color: "#778293"; font.pixelSize: 11; font.letterSpacing: 1
    }
    Text {
        anchors.horizontalCenter: parent.horizontalCenter; y: 144
        text: gauge.unit; color: "#778293"; font.pixelSize: 12
    }
    Item {
        x: 190; y: 190
        rotation: -130 + 260 * Math.min(gauge.maximum,Math.max(0,gauge.value)) / gauge.maximum
        Rectangle { x: -5; y: -143; width: 10; height: 165; radius: 5; color: "#442323" }
        Rectangle { x: -1.5; y: -143; width: 3; height: 165; radius: 1.5; color: "#ff4945" }
    }
    Rectangle {
        anchors.centerIn: parent
        width: 24; height: 24; radius: 12; color: "#171820"; border.color: "#ff4945"; border.width: 2
        Rectangle { anchors.centerIn: parent; width: 7; height: 7; radius: 4; color: "#ff4945" }
    }
    Text {
        anchors.horizontalCenter: parent.horizontalCenter; y: 273
        text: gauge.value.toFixed(gauge.decimals)
        color: "#e9edf4"; font.pixelSize: 32; font.bold: true
    }
    Text {
        anchors.horizontalCenter: parent.horizontalCenter; y: 316
        text: gauge.maximum === 8 ? "ENGINE SPEED" : "VEHICLE SPEED"
        color: "#778293"; font.pixelSize: 9; font.letterSpacing: 1
    }
}
