import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

Page {
    id: myListingsPage
    background: Rectangle { color: "#f5f5f7" }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 12

        Label {
            text: "My Listings"
            font.pixelSize: 18
            font.bold: true
            color: "#1a1a1a"
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 140
            radius: 10
            color: "white"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 8

                Label {
                    text: "No listings yet"
                    font.pixelSize: 14
                    color: "#1a1a1a"
                }

                Label {
                    text: "Items you publish will appear here."
                    font.pixelSize: 12
                    color: "#9aa0a6"
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }
            }
        }

        Item { Layout.fillHeight: true }
    }
}
