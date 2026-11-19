import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

Page {
    id: homePage
    background: Rectangle { color: "#f5f5f7" } // 统一的浅灰背景

    // ================= 顶部导航栏 =================
    header: ToolBar {
        background: Rectangle { color: "#ffffff" }
        RowLayout {
            anchors.fill: parent
            ToolButton {
                text: "☰" 
                font.pixelSize: 22
                onClicked: drawer.open() // 点击打开左侧抽屉
            }
            Label {
                text: "Campus Trading"
                font.pixelSize: 18
                font.bold: true
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }
            Item { Layout.preferredWidth: 40 } // 右侧占位，保证标题居中
        }
    }

    // ================= 左侧抽屉菜单 (Sidebar) =================
    Drawer {
        id: drawer
        width: Math.min(homePage.width * 0.75, 300)
        height: homePage.height

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15

            // 用户信息区 (这里暂时写死，后续可以传真实的邮箱过来)
            Label {
                text: "Welcome!"
                font.pixelSize: 24
                font.bold: true
                color: "#1a1a1a"
            }
        

            MenuSeparator { Layout.fillWidth: true }

            // 2. 导航按钮区（紧凑化处理）
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 5 // 按钮之间的间距，越小越紧凑

                // 浏览商品
                Button {
                    text: "Browse Items"
                    flat: true
                    Layout.fillWidth: true
                    Layout.preferredHeight: 45 // 固定高度，防止被拉伸
                    contentItem: Text {
                        text: parent.text
                        font.pixelSize: 16
                        color: "#333"
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        contentStack.replace("BrowsePage.qml") 
                        drawer.close()
                    }
                }

                // 个人资料
                Button {
                    text: "My Profile"
                    flat: true
                    Layout.fillWidth: true
                    Layout.preferredHeight: 45
                    contentItem: Text {
                        text: parent.text
                        font.pixelSize: 16
                        color: "#333"
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        contentStack.replace("ProfilePage.qml")
                        drawer.close()
                    }
                }

                // 我的发布
                Button {
                    text: "My Listings"
                    flat: true
                    Layout.fillWidth: true
                    Layout.preferredHeight: 45
                    contentItem: Text {
                        text: parent.text
                        font.pixelSize: 16
                        color: "#333"
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        contentStack.replace("MyListingsPage.qml")
                        drawer.close()
                    }
                }
            }
           // 3. 弹簧（把退出按钮推到底部）
            Item { Layout.fillHeight: true } 

           // 退出登录按钮 (带边框设计)
            Button {
                text: "Sign Out"
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                Layout.bottomMargin: 20 // 距离底部留一点空隙

                background: Rectangle {
                    // 点击时背景变成浅红色，平时透明
                    color: parent.down ? "#ffe6e6" : "transparent" 
                    border.color: "#dc3545" // 红色边框
                    border.width: 2
                    radius: 12 // 和登录按钮一样的圆角
                    Behavior on color { ColorAnimation { duration: 150 } }
                }

                contentItem: Text {
                    text: parent.text
                    color: "#dc3545" // 红色文字
                    font.pixelSize: 16
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: {
                    authHandler.handleLogout()
                    drawer.close()
                }
            }
        }
    }

    // ================= 内部页面容器 =================
    StackView {
        id: contentStack
        anchors.fill: parent
        
        // 默认显示一个内置的欢迎页，防止找不到文件报错
        initialItem: Item {
            ColumnLayout {
                anchors.centerIn: parent
                spacing: 10
                Label {
                    text: "🎉 login successfully！"
                    font.pixelSize: 24
                    font.bold: true
                    Layout.alignment: Qt.AlignHCenter
                }
               
            }
        }
    }
}