import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

Page {
    // 1. 漂亮的渐变背景
    background: Rectangle {
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#e0eafc" }
            GradientStop { position: 1.0; color: "#cfdef3" }
        }
    }

    // 主容器
    ColumnLayout {
        anchors.centerIn: parent
        width: parent.width * 0.85
        spacing: 25

        // 顶部 Logo 和标题
       // 顶部 Logo
        Image {
            // 路径是从当前 qml 文件 (SignInPage.qml) 出发的相对路径
            source: "../assets/hkbu_logo.png" 
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 100  // 根据你的图片实际比例调整宽度
            Layout.preferredHeight: 100
            fillMode: Image.PreserveAspectFit // 保持宽高比，防止图片变形
            Layout.bottomMargin: 10
        }
        Text {
            text: "Campus Trading"
            font.pixelSize: 28
            font.bold: true
            color: "#1a1a1a"
            Layout.alignment: Qt.AlignHCenter
        }
        Text {
            text: "Buy and sell on your campus"
            font.pixelSize: 14
            color: "#666"
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 10
        }

        // 邮箱输入框
        TextField {
            id: emailInput
            placeholderText: "Email address"
            Layout.fillWidth: true
            font.pixelSize: 16
            leftPadding: 45 // 给左边的图标留位置
            padding: 15
            
            // 输入框左边的图标
            Text {
                text: "✉️"
                anchors.left: parent.left
                anchors.leftMargin: 15
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 18
                opacity: 0.6
            }

            // 自定义背景：圆角 + 动态边框颜色
            background: Rectangle {
                color: "#ffffff"
                radius: 12
                border.color: emailInput.activeFocus ? "#007bff" : "transparent"
                border.width: 2
                // 简单的阴影效果
                layer.enabled: true
            }
            onTextChanged: errorText.text = "" // 输入时清除错误提示
        }

        // 密码输入框
        TextField {
            id: passwordInput
            placeholderText: "Password"
            echoMode: TextInput.Password
            Layout.fillWidth: true
            font.pixelSize: 16
            leftPadding: 45
            padding: 15

            Text {
                text: "🔒"
                anchors.left: parent.left
                anchors.leftMargin: 15
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 18
                opacity: 0.6
            }

            background: Rectangle {
                color: "#ffffff"
                radius: 12
                border.color: passwordInput.activeFocus ? "#007bff" : "transparent"
                border.width: 2
            }
            onTextChanged: errorText.text = ""
            onAccepted: loginBtn.clicked() // 按回车直接登录
        }

        // 错误提示文本
        Text {
            id: errorText
            color: "#dc3545"
            font.pixelSize: 14
            Layout.alignment: Qt.AlignHCenter
            text: ""
            visible: text !== ""
        }

        // 登录按钮
        Button {
            id: loginBtn
            text: "Sign In"
            Layout.fillWidth: true
            Layout.preferredHeight: 55
            font.pixelSize: 18
            font.bold: true
            
            background: Rectangle {
                color: loginBtn.enabled ? (loginBtn.down ? "#0056b3" : "#007bff") : "#a0c4ff"
                radius: 12
                Behavior on color { ColorAnimation { duration: 150 } }
            }
            contentItem: Text {
                text: loginBtn.text
                color: "white"
                font: loginBtn.font
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            
            onClicked: {
                if (!emailInput.text || !passwordInput.text) {
                    errorText.text = "Please fill in all fields."
                    return
                }
                
                loginBtn.enabled = false
                loginBtn.text = "Signing in..."
                
                // 调用 Python Handler
                authHandler.handleLogin(emailInput.text, passwordInput.text)
            }
        }

        // 注册跳转按钮
        Button {
            text: "Don't have an account? Sign Up"
            Layout.alignment: Qt.AlignHCenter
            flat: true
            contentItem: Text {
                text: parent.text
                color: "#555"
                font.pixelSize: 14
                horizontalAlignment: Text.AlignHCenter
            }
            onClicked: {
                stackView.push("SignUpPage.qml")
            }
        }
    }

    // 监听 Python 信号
    Connections {
        target: authHandler
        
        function onLoginSuccess() {
            loginBtn.enabled = true
            loginBtn.text = "Sign In"
            // 登录成功后跳转到主页
            stackView.replace("HomePage.qml") 
        }
        
        function onLoginFailed(errorMsg) {
            loginBtn.enabled = true
            loginBtn.text = "Sign In"
            errorText.text = errorMsg
        }
    }
}