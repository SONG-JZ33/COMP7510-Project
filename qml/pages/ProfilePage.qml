import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

Page {
    background: Rectangle { color: "#f5f5f7" }

    // 顶部导航栏
    header: ToolBar {
        background: Rectangle { color: "#ffffff" }
        RowLayout {
            anchors.fill: parent
            Label { 
                text: "My Profile"; 
                font.bold: true; 
                font.pixelSize: 18;
                Layout.fillWidth: true; 
                horizontalAlignment: Text.AlignHCenter 
            }
        }
    }

    // 页面加载时，自动请求 Python 去数据库拉取数据
    Component.onCompleted: profileHandler.loadProfile()

    // 主内容区
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 30
        spacing: 20

        // 邮箱展示（不可修改）
        Label { text: "Email Address"; font.bold: true; color: "#666" }
        Label { 
            id: emailLabel
            text: "Loading..." 
            font.pixelSize: 18
            color: "#333" 
        } 

        MenuSeparator { Layout.fillWidth: true; Layout.topMargin: 10; Layout.bottomMargin: 10 }

        // 昵称修改区
        Label { text: "Nickname"; font.bold: true; color: "#666" }
        TextField {
            id: nicknameInput
            placeholderText: "Enter new nickname"
            Layout.fillWidth: true
            font.pixelSize: 16
            padding: 12
            background: Rectangle { 
                radius: 8
                color: "white"
                border.color: nicknameInput.activeFocus ? "#007bff" : "#ccc"
                border.width: 1 
            }
        }

        // 提交按钮
        Button {
            text: "Update Profile"
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            Layout.topMargin: 10
            
            background: Rectangle {
                color: parent.down ? "#0056b3" : "#007bff"
                radius: 8
            }
            contentItem: Text { 
                text: parent.text
                color: "white"
                font.bold: true
                font.pixelSize: 16
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter 
            }
            onClicked: profileHandler.updateNickname(nicknameInput.text)
        }
        
        // 状态提示信息
        Label { 
            id: msgLabel
            visible: text !== ""
            font.pixelSize: 14
            Layout.alignment: Qt.AlignHCenter
        }
    }

    // 监听 Python 端发来的信号
    Connections {
        target: profileHandler
        
        function onProfileLoaded(email, nickname) {
            emailLabel.text = email
            nicknameInput.text = nickname
        }
        
        function onUpdateSuccess(msg) {
            msgLabel.color = "green"
            msgLabel.text = msg
        }
        
        function onUpdateFailed(msg) {
            msgLabel.color = "red"
            msgLabel.text = msg
        }
    }
}