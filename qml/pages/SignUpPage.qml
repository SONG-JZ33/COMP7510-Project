import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Page {
    background: Rectangle {
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#e0eafc" }
            GradientStop { position: 1.0; color: "#cfdef3" }
        }
    }
    // 顶部返回按钮
    header: ToolBar {
        background: Rectangle { color: "#ffffff" }
        RowLayout {
            anchors.fill: parent
            ToolButton {
                text: "< Back"
                font.pixelSize: 16
                onClicked: stackView.pop() // 返回登录页
            }
            Label {
                text: "Create Account"
                font.pixelSize: 18
                font.bold: true
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }
            // 占位，让标题居中
            Item { Layout.preferredWidth: 50 } 
        }
    }

    ColumnLayout {
        anchors.centerIn: parent
        width: parent.width * 0.8
        spacing: 20

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
      
        }

        Button {
            id: signUpBtn
            text: "Sign Up"
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            font.pixelSize: 18
           background: Rectangle {
                // 蓝色系：正常 #007bff，按下 #0056b3，禁用 #a0c4ff
                color: signUpBtn.enabled ? (signUpBtn.down ? "#0056b3" : "#007bff") : "#a0c4ff"
                radius: 12 
                Behavior on color { ColorAnimation { duration: 150 } }
            }
            contentItem: Text {
                text: signUpBtn.text
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            
            onClicked: {
                signUpBtn.enabled = false
                signUpBtn.text = "Registering..."
                errorText.text = ""
                authHandler.handleSignUp(emailInput.text, passwordInput.text)
            }
        }

        Text {
            id: errorText
            color: "red"
            font.pixelSize: 14
            Layout.alignment: Qt.AlignHCenter
            text: ""
        }
    }

    Connections {
        target: authHandler
        
        function onSignUpSuccess(msg) {
            signUpBtn.enabled = true
            signUpBtn.text = "Sign Up"
            errorText.color = "green"
            errorText.text = msg
            
            // 延迟1.5秒后自动返回登录页
            timer.start()
        }
        
        function onSignUpFailed(errorMsg) {
            signUpBtn.enabled = true
            signUpBtn.text = "Sign Up"
            errorText.color = "red"
            errorText.text = errorMsg
        }
    }

    Timer {
        id: timer
        interval: 1500
        repeat: false
        onTriggered: stackView.pop()
    }
}