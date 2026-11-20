import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Page {
    background: Rectangle {
        color: "#f4f6f5"
    }

    // 顶部返回栏
    Rectangle {
        id: header
        width: parent.width
        height: 44
        color: "#dfe9fb"

        Row {
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8

            Rectangle {
                width: 26
                height: 26
                radius: 13
                color: "white"
                border.color: "#b9d0f5"
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: "<"
                    font.pixelSize: 14
                    font.bold: true
                    color: "#007bff"
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: stackView.pop()
                }
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "Sell an Item"
                font.pixelSize: 14
                font.bold: true
                color: "#1a1a1a"
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: 20
        anchors.topMargin: header.height + 20
        radius: 10
        color: "white"
        border.color: "#eceeed"
        border.width: 1

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 8

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "Publishing form is being integrated"
                font.pixelSize: 14
                color: "#2c3e50"
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "Placeholder page, to be replaced by the publish form."
                font.pixelSize: 12
                color: "#9aa0a6"
            }
        }
    }
}
