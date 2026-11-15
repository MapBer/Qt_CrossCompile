import QtQuick 2.15
import QtQuick.Controls 2.15

Button {
    id: control
    property bool active: false
    property bool primary: false
    implicitHeight: 38
    implicitWidth: Math.max(90, contentItem.implicitWidth + 32)
    hoverEnabled: true
    contentItem: Text {
        text: control.text; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
        color: control.primary && !control.active ? "white" : control.active ? "#66e9b0" : "#b7c2d3"
        font.pixelSize: 12; font.bold: control.primary
    }
    background: Rectangle {
        radius: 7
        color: control.down ? "#333d4e" : control.active ? "#19352e" : control.primary ? "#ef403e" : control.hovered ? "#252e3d" : "#1a212d"
        border.color: control.activeFocus ? "#81b8df" : control.active ? "#34765b" : control.primary ? "#ff645c" : "#303a4b"
    }
}
