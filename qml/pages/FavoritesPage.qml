import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Page {
    id: root

    header: ToolBar {
        RowLayout {
            anchors.fill: parent

            ToolButton {
                text: "Back"
                onClicked: stackView.pop()
            }

            Text {
                Layout.fillWidth: true
                text: "My Favorites"
                font.bold: true
                font.pixelSize: 16
                verticalAlignment: Text.AlignVCenter
            }

            ToolButton {
                text: "Refresh"
                onClicked: {
                    var success = FavoritesPageHandler.handleLoadFavorites()
                    statusText.text = success
                            ? "Favorites refreshed."
                            : "Could not load favorites. Check sign-in and RLS policies."
                }
            }
        }
    }

    Component.onCompleted: {
        var success = FavoritesPageHandler.handleLoadFavorites()
        statusText.text = success
                ? "Your saved products are shown below."
                : "Could not load favorites. Please sign in and check the database."
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 8

        Text {
            id: statusText
            Layout.fillWidth: true
            text: "Loading favorites..."
            color: "#666666"
            wrapMode: Text.WordWrap
        }

        ListView {
            id: favoriteList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 8
            model: favoritesModel

            delegate: Rectangle {
                required property string product_id
                required property string title
                required property var price
                required property string condition
                required property string seller_email

                width: favoriteList.width
                height: 126
                radius: 8
                color: "white"
                border.color: "#dddddd"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 4

                    Text {
                        Layout.fillWidth: true
                        text: title
                        font.bold: true
                        font.pixelSize: 15
                        elide: Text.ElideRight
                    }

                    Text {
                        Layout.fillWidth: true
                        text: price === null || price === undefined
                              ? "Price: Not provided"
                              : "Price: " + price
                        color: "#333333"
                    }

                    Text {
                        Layout.fillWidth: true
                        text: condition === "" ? "Condition: Not provided" : "Condition: " + condition
                        color: "#777777"
                        elide: Text.ElideRight
                    }

                    Text {
                        Layout.fillWidth: true
                        text: "Seller: " + seller_email
                        color: "#777777"
                        elide: Text.ElideRight
                    }

                    Button {
                        text: "Remove from Favorites"
                        onClicked: {
                            var success = FavoritesPageHandler.handleRemoveFavorite(product_id)
                            statusText.text = success
                                    ? "Favorite removed."
                                    : "Could not remove favorite."
                        }
                    }
                }
            }
        }
    }
}
