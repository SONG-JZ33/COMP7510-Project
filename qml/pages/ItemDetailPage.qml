import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Page {
    property string productId: ''

    background: Rectangle {
        color: '#f4f6f5'
    }

    ScrollView {
        id: detailScrollView
        anchors.fill: parent
        clip: true

        ColumnLayout {
            width: detailScrollView.availableWidth
            spacing: 12

            // 商品大图
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 240
                color: '#e8eaea'
                clip: true

                Image {
                    anchors.fill: parent
                    source: ItemDetailPageHandler.getImageUrl()
                    fillMode: Image.PreserveAspectCrop
                }

                // 浮动返回按钮
                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.margins: 12
                    width: 36
                    height: 36
                    radius: 18
                    color: '#80000000'

                    Image {
                        anchors.centerIn: parent
                        width: 18
                        height: 18
                        source: "../back.svg"
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: stackView.pop()
                    }
                }
            }

            // 信息卡片
            Rectangle {
                Layout.fillWidth: true
                Layout.margins: 12
                implicitHeight: infoColumn.implicitHeight + 32
                color: 'white'
                radius: 10
                border.width: 1
                border.color: '#eceeed'

                ColumnLayout {
                    id: infoColumn
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12

                    Text {
                        Layout.fillWidth: true
                        text: ItemDetailPageHandler.getTitle()
                        wrapMode: Text.WordWrap
                        color: "#2c3e50"
                        font.pixelSize: 14
                        font.bold: true
                    }
                    Text {
                        Layout.fillWidth: true
                        text: ItemDetailPageHandler.getPrice()
                        color: '#e67e22'
                        font.pixelSize: 14
                        font.bold: true
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        color: '#f0f1f2'
                    }

                    Repeater {
                        model: [
                            {label: "Seller",    value: ItemDetailPageHandler.getSeller()},
                            {label: "Category",  value: ItemDetailPageHandler.getCategory()},
                            {label: "Condition", value: ItemDetailPageHandler.getCondition()}
                        ]
                        RowLayout {
                            required property var modelData
                            Layout.fillWidth: true
                            spacing: 12
                            Text {
                                text: modelData.label
                                color: "#95a5a6"
                                font.pixelSize: 12
                                Layout.preferredWidth: 80
                            }
                            Text {
                                text: modelData.value
                                color: "#2c3e50"
                                font.pixelSize: 12
                                font.bold: true
                                Layout.fillWidth: true
                            }
                        }
                    }

                    // 收藏按钮
                    Button {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 34
                        text: "Add to Favorites"
                        font.pixelSize: 12
                        onClicked: {
                            if (!ItemDetailPageHandler.isSignedIn()) {
                                showHint('not_signed_in')
                                return
                            }
                            showHint(FavoritesPageHandler.handleAddFavorite(productId)
                                     ? 'favorite_added'
                                     : 'favorite_failed')
                        }
                    }
                }
            }

            // 描述卡片
            Rectangle {
                Layout.fillWidth: true
                Layout.margins: 12
                implicitHeight: descColumn.implicitHeight + 32
                color: 'white'
                radius: 10
                border.width: 1
                border.color: '#eceeed'

                ColumnLayout {
                    id: descColumn
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 8

                    Text {
                        text: "Description"
                        color: "#2c3e50"
                        font.pixelSize: 14
                        font.bold: true
                    }
                    Text {
                        Layout.fillWidth: true
                        text: ItemDetailPageHandler.getDescription()
                        wrapMode: Text.WordWrap
                        color: "#555555"
                        font.pixelSize: 12
                    }
                }
            }

            // 留言标题
            Text {
                Layout.fillWidth: true
                Layout.leftMargin: 14
                text: "Comments"
                color: "#2c3e50"
                font.pixelSize: 14
                font.bold: true
            }

            // 留言列表（外层统一滚动，内层不单独滚动）
            ListView {
                id: commentListView
                Layout.fillWidth: true
                Layout.leftMargin: 12
                Layout.rightMargin: 12
                Layout.preferredHeight: contentHeight
                interactive: false
                spacing: 10

                model: commentModel

                Text {
                    anchors.centerIn: parent
                    visible: commentListView.count === 0
                    text: "No comments yet. Be the first to reply!"
                    color: "#9aa0a6"
                    font.pixelSize: 12
                }

                delegate: Rectangle {
                    required property string user_name
                    required property string content
                    required property string created_text

                    width: commentListView.width
                    height: commentBody.implicitHeight + 16
                    color: 'white'
                    radius: 10
                    border.width: 1
                    border.color: '#eceeed'

                    RowLayout {
                        id: commentBody
                        anchors.margins: 12
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        spacing: 10

                        // 圆形头像（取昵称首字母）
                        Rectangle {
                            width: 38
                            height: 38
                            radius: 19
                            color: '#007bff'
                            Layout.alignment: Qt.AlignTop
                            Text {
                                anchors.centerIn: parent
                                text: user_name.charAt(0).toUpperCase()
                                color: "white"
                                font.pixelSize: 14
                                font.bold: true
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 3
                            Row {
                                spacing: 8
                                Text {
                                    text: user_name
                                    font.pixelSize: 12
                                    font.bold: true
                                    color: "#2c3e50"
                                }
                                Text {
                                    text: created_text
                                    font.pixelSize: 12
                                    color: "#9aa0a6"
                                }
                            }
                            Text {
                                Layout.fillWidth: true
                                text: content
                                wrapMode: Text.WordWrap
                                color: "#555555"
                                font.pixelSize: 12
                            }
                        }
                    }
                }
            }
        }
    }

    // 发送失败时在底部弹出的提示
    Rectangle {
        id: hintBubble
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 68
        width: hintLabel.implicitWidth + 24
        height: hintLabel.implicitHeight + 14
        radius: 6
        color: '#cc2c3e50'
        visible: hintTimer.running
        z: 10

        Text {
            id: hintLabel
            anchors.centerIn: parent
            text: ''
            color: 'white'
            font.pixelSize: 12
        }
    }

    Timer {
        id: hintTimer
        interval: 2500
        repeat: false
    }

    function showHint(result) {
        if (result === 'empty') {
            hintLabel.text = 'Please write a comment'
        } else if (result === 'not_signed_in') {
            hintLabel.text = 'Please sign in first'
        } else if (result === 'favorite_added') {
            hintLabel.text = 'Added to favorites'
        } else if (result === 'favorite_failed') {
            hintLabel.text = 'Could not add to favorites'
        } else {
            hintLabel.text = 'Failed to post, please try again'
        }
        hintTimer.restart()
    }

    footer: ToolBar {
        background: Rectangle { color: 'white' }

        RowLayout {
            anchors.fill: parent
            anchors.margins: 8
            spacing: 8

            TextField {
                id: commentField
                Layout.fillWidth: true
                placeholderText: "Write a comment..."
                leftPadding: 12
                background: Rectangle {
                    radius: 18
                    color: '#f1f3f2'
                    border.width: 1
                    border.color: '#e2e4e3'
                }
                onAccepted: sendButton.clicked()
            }
            RoundButton {
                id: sendButton
                width: 40
                height: 40
                text: ""
                flat: false
                highlighted: true
                Image {
                    anchors.centerIn: parent
                    width: 18
                    height: 18
                    source: "../send.svg"
                }
                onClicked: {
                    var result = ItemDetailPageHandler.handleSendComment(
                        productId, commentField.text)
                    if (result === 'ok') {
                        commentField.text = ''
                    } else {
                        showHint(result)
                    }
                }
            }
        }
    }
}
