import QtQuick
import QtQuick.Window

Window {
    width: 640
    height: 480
    visible: true
    title: "Hello World"
    color: "white"

    Text {
        anchors.centerIn: parent
        text: "hello world!"
        font.pixelSize: 32
        color: "#202020"
    }
}
