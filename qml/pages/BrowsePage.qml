import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Page {
    property int selectedCategory: 0

    background: Rectangle {
        color: '#f4f6f5'
    }

    // 品牌头部
    Rectangle {
        id: brandHeader
        width: parent.width
        height: 44
        color: '#27ae60'

        // 搜索与收藏入口
        Row {
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8

            Rectangle {
                width: searchLabel.implicitWidth + 18
                height: 26
                radius: 13
                color: "white"

                Text {
                    id: searchLabel
                    anchors.centerIn: parent
                    text: "Search"
                    color: "#27ae60"
                    font.pixelSize: 12
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: stackView.push("SearchPage.qml")
                }
            }

            Rectangle {
                width: favoriteLabel.implicitWidth + 18
                height: 26
                radius: 13
                color: "white"

                Text {
                    id: favoriteLabel
                    anchors.centerIn: parent
                    text: "Favorites"
                    color: "#27ae60"
                    font.pixelSize: 12
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: stackView.push("FavoritesPage.qml")
                }
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12

        anchors.topMargin: brandHeader.height + 12

        // 分类筛选（横向可滚动，选中态高亮）
        ScrollView {
            Layout.fillWidth: true
            Layout.preferredHeight: 36
            clip: true

            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            ScrollBar.vertical.policy: ScrollBar.AlwaysOff

            Row {
                spacing: 6

                Repeater {
                    model: categoryModel

                    Rectangle {
                        required property int id
                        required property string name

                        height: 34
                        width: pillText.implicitWidth + 22
                        radius: 17
                        color: id === selectedCategory ? '#27ae60' : 'white'
                        border.width: 1
                        border.color: id === selectedCategory ? '#27ae60' : '#dcdedd'

                        Text {
                            id: pillText
                            anchors.centerIn: parent
                            text: name
                            font.pixelSize: 12
                            font.bold: id === selectedCategory
                            color: id === selectedCategory ? 'white' : '#666666'
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                selectedCategory = id
                                BrowsePageHandler.handleLoadData(id)
                            }
                        }
                    }
                }
            }
        }

        // 商品列表
        ListView {
            id: productListView
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 12
            clip: true

            model: listModel

            Text {
                anchors.centerIn: parent
                visible: productListView.count === 0
                text: "No products yet"
                color: "#9aa0a6"
                font.pixelSize: 12
            }

            delegate: Rectangle {
                required property string id
                required property string title
                required property string price_text
                required property string content
                required property string image_url

                width: ListView.view.width
                height: 118
                color: 'white'
                radius: 10
                border.width: 1
                border.color: '#eceeed'

                // 商品图片（圆角裁剪）
                Rectangle {
                    id: imageWrap
                    width: 96
                    height: 96
                    anchors.left: parent.left
                    anchors.leftMargin: 11
                    anchors.verticalCenter: parent.verticalCenter
                    radius: 8
                    clip: true
                    color: '#f0f0f0'

                    Image {
                        anchors.fill: parent
                        source: image_url
                        fillMode: Image.PreserveAspectCrop
                    }
                }

                ColumnLayout {
                    anchors {
                        left: imageWrap.right
                        top: parent.top
                        right: parent.right
                        bottom: parent.bottom
                        leftMargin: 12
                        topMargin: 14
                        rightMargin: 12
                        bottomMargin: 14
                    }
                    spacing: 6

                    Text {
                        Layout.fillWidth: true
                        text: title
                        color: "#2c3e50"
                        font.pixelSize: 14
                        font.bold: true
                        elide: Text.ElideRight
                        maximumLineCount: 1
                    }

                    // 价格标签
                    Rectangle {
                        width: priceLabel.implicitWidth + 16
                        height: priceLabel.implicitHeight + 6
                        radius: 6
                        color: '#fdf0e3'
                        Text {
                            id: priceLabel
                            anchors.centerIn: parent
                            text: price_text
                            color: '#e67e22'
                            font.pixelSize: 14
                            font.bold: true
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        verticalAlignment: Text.AlignBottom
                        text: content
                        color: "#95a5a6"
                        font.pixelSize: 12
                        elide: Text.ElideRight
                        maximumLineCount: 1
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        ItemDetailPageHandler.handleLoadData(id)
                        stackView.push(itemDetailPageComponent, {productId: id})
                    }
                }
            }
        }
    }

    // 详情页组件（供列表点击跳转使用）
    Component {
        id: itemDetailPageComponent
        ItemDetailPage {}
    }

    Component.onCompleted: {
        BrowsePageHandler.handleLoadCategories()
    }

    // 页面成为栈顶时加载/刷新：首次进入和从详情页返回都会触发
    StackView.onActivated: {
        BrowsePageHandler.handleLoadData(selectedCategory)
    }
}
