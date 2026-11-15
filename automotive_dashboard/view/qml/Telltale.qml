import QtQuick 2.15

Item {
    id: telltale
    property string kind: "brake"
    property string caption: "BRAKE"
    property color activeColor: "#ff4945"
    property bool active: false
    width: 90; height: 58
    onActiveChanged: symbol.requestPaint()
    onActiveColorChanged: symbol.requestPaint()
    Canvas {
        id: symbol
        width: 48; height: 36; anchors.horizontalCenter: parent.horizontalCenter
        onPaint: {
            var c = getContext("2d")
            c.reset(); c.translate(24,18)
            c.strokeStyle = telltale.active ? telltale.activeColor : "#343b46"
            c.lineWidth = 1.8; c.lineCap = "round"; c.lineJoin = "round"
            c.beginPath()
            if (kind === "battery") {
                c.rect(-15,-8,30,18)
                c.moveTo(-10,-11); c.lineTo(-4,-11); c.moveTo(5,-11); c.lineTo(11,-11)
                c.moveTo(-10,0); c.lineTo(-4,0); c.moveTo(6,0); c.lineTo(12,0); c.moveTo(9,-3); c.lineTo(9,3)
            } else if (kind === "oil") {
                c.moveTo(-15,-5); c.lineTo(4,-5); c.lineTo(9,-10); c.lineTo(17,-10)
                c.lineTo(8,3); c.lineTo(-7,7); c.closePath()
                c.moveTo(-8,-10); c.lineTo(0,-10); c.moveTo(-4,-10); c.lineTo(-4,-5)
                c.moveTo(19,7); c.arc(17,7,2,0,Math.PI*2)
            } else if (kind === "engine") {
                c.moveTo(-14,-5); c.lineTo(-7,-5); c.lineTo(-3,-10); c.lineTo(7,-10)
                c.lineTo(11,-5); c.lineTo(17,-5); c.lineTo(17,9); c.lineTo(8,9)
                c.lineTo(4,5); c.lineTo(-14,5); c.closePath()
                c.moveTo(-18,-5); c.lineTo(-18,4); c.moveTo(-2,-14); c.lineTo(7,-14)
            } else if (kind === "lights") {
                c.moveTo(0,-11); c.bezierCurveTo(19,-11,19,11,0,11); c.closePath()
                for(var i=-9;i<=9;i+=6) { c.moveTo(-17,i); c.lineTo(-5,i) }
            } else if (kind === "temp") {
                c.rect(-3,-14,6,22); c.moveTo(6,10); c.arc(0,10,6,0,Math.PI*2)
                for(var y=-10;y<=0;y+=5) { c.moveTo(5,y); c.lineTo(10,y) }
            } else if (kind === "fuel") {
                c.rect(-12,-13,17,26); c.rect(-9,-10,11,9)
                c.moveTo(5,-1); c.bezierCurveTo(17,-4,5,15,14,10); c.lineTo(14,-7); c.lineTo(9,-12)
            } else {
                c.arc(0,0,12,0,Math.PI*2)
                c.moveTo(-14,-12); c.bezierCurveTo(-22,-5,-22,5,-14,12)
                c.moveTo(14,-12); c.bezierCurveTo(22,-5,22,5,14,12)
            }
            c.stroke()
        }
        Text {
            anchors.centerIn: parent
            visible: kind === "abs" || kind === "brake"
            text: kind === "abs" ? "ABS" : "!"
            color: telltale.active ? telltale.activeColor : "#343b46"
            font.pixelSize: kind === "abs" ? 8 : 17; font.bold: true
        }
    }
    Text {
        anchors.horizontalCenter: parent.horizontalCenter; y: 43
        text: telltale.caption; color: telltale.active ? telltale.activeColor : "#778293"
        font.pixelSize: 8; font.bold: true
    }
}
