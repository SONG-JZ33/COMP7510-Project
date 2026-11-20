import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Page {
    id: root

    function runSearch() {
        var keyword = keywordField.text.trim()

        if (keyword.length === 0) {
            SearchPageHandler.handleClear()
            statusText.text = "Please enter a product name or keyword."
            return
        }

        var success = SearchPageHandler.handleSearch(keyword)
        statusText.text = success
                ? "Search completed. If no cards appear, no products matched or the products table is empty."
                : "Search failed. Check the connection, products columns, and Supabase RLS policies."
    }

    header: ToolBar {
        RowLayout {
            anchors.fill: parent
            spacing: 4

            ToolButton {
                icon.source: "back.svg"
                onClicked: {
                    stackView.pop()
                    ListPageHandler.handleLoadData()
                }
            }

            TextField {
                id: keywordField
                Layout.fillWidth: true
                placeholderText: "Search products..."
                onAccepted: root.runSearch()
            }

            ToolButton {
                text: "Search"
                onClicked: root.runSearch()
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 8

        Text {
            id: statusText
            Layout.fillWidth: true
            text: "Enter a keyword to search products."
            color: "#666666"
            wrapMode: Text.WordWrap
        }

        ListView {
            id: resultList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 8
            model: searchModel

            delegate: Rectangle {
                required property string product_id
                required property string title
                required property var price
                required property string condition
                required property string seller_email
                required property string image_url

                width: resultList.width
                height: 136
                radius: 8
                color: "white"
                border.color: "#dddddd"

                // Use the same image layout and crop mode as BrowsePage.qml.
                Rectangle {
                    id: imageWrap
                    width: 108
                    height: 108
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    radius: 8
                    clip: true
                    color: "#f0f0f0"

                    Image {
                        anchors.fill: parent
                        source: image_url
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                    }
                }

                ColumnLayout {
                    anchors {
                        left: imageWrap.right
                        top: parent.top
                        right: parent.right
                        bottom: parent.bottom
                        leftMargin: 12
                        topMargin: 9
                        rightMargin: 10
                        bottomMargin: 9
                    }
                    spacing: 3

                    Text {
                        Layout.fillWidth: true
                        text: title
                        font.bold: true
                        font.pixelSize: 15
                        color: "#2c3e50"
                        elide: Text.ElideRight
                        maximumLineCount: 1
                    }

                    Text {
                        Layout.fillWidth: true
                        text: price === null || price === undefined
                              ? "Price: Not provided"
                              : "Price: " + price
                        color: "#333333"
                        elide: Text.ElideRight
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
                        text: "Add to Favorites"
                        Layout.alignment: Qt.AlignLeft
                        onClicked: {
                            var success = FavoritesPageHandler.handleAddFavorite(product_id)
                            statusText.text = success
                                    ? "Added to favorites (or it was already saved)."
                                    : "Could not add favorite. Check sign-in and favorites RLS policies."
                        }
                    }
                }
            }
        }
    }
}
