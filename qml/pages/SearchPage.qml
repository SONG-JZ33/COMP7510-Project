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
                text: "Back"
                onClicked: stackView.pop()
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

                width: resultList.width
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
                        text: "Add to Favorites"
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
