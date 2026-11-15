import QtQuick 2.15
import QtQuick.Controls 2.15

Slider {
    id: control
    implicitHeight: 26
    stepSize: 1
    background: Rectangle {
        x: control.leftPadding
        y: control.topPadding + control.availableHeight / 2 - height / 2
        width: control.availableWidth; height: 5; radius: 2
        color: "#30394a"
        Rectangle { width: control.visualPosition * parent.width; height: parent.height; radius: 2; color: "#ef4945" }
    }
    handle: Rectangle {
        x: control.leftPadding + control.visualPosition * (control.availableWidth - width)
        y: control.topPadding + control.availableHeight / 2 - height / 2
        width: 14; height: 14; radius: 7
        color: control.pressed ? "#ff8c85" : "#f4f5f8"
        border.width: control.activeFocus ? 2 : 0; border.color: "#81b8df"
    }
}
