import QtQuick 2.15

Canvas {
    id: arrow
    property bool active: false
    property bool pointsRight: false
    width: 40; height: 32
    onActiveChanged: requestPaint()
    onPaint: {
        var c = getContext("2d"); c.reset()
        c.translate(20,16)
        if (pointsRight) c.scale(-1,1)
        c.beginPath(); c.moveTo(-17,0); c.lineTo(-3,-13); c.lineTo(-3,-6)
        c.lineTo(16,-6); c.lineTo(16,6); c.lineTo(-3,6); c.lineTo(-3,13); c.closePath()
        c.fillStyle = arrow.active ? "#42e5a2" : "#26362f"
        c.fill()
    }
}
