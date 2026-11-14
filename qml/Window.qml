import QtQuick
import QtQuick.Controls

ApplicationWindow {
    width: 360
    height: 640
    visible: true
    title: "Campus Second-hand Market"

    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: placeholderComponent
    }

    // 临时占位页：等 products / comments 字段确认后，
    // 把 initialItem 换成 signInPageComponent / browsePageComponent 即可
    Component {
        id: placeholderComponent

        Page {
            Column {
                anchors.centerIn: parent
                spacing: 12

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Campus Second-hand Market"
                    font.pixelSize: 20
                    font.bold: true
                    color: "#444"
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "M2 framework ready"
                    font.pixelSize: 14
                    color: "#888"
                }
            }
        }
    }

    /* 页面接入位置（字段确认后启用，并在 main.py 注册对应 Handler）
    Component {
        id: browsePageComponent
        BrowsePage {}
    }

    Component {
        id: itemDetailPageComponent
        ItemDetailPage {}
    }
    */
}
