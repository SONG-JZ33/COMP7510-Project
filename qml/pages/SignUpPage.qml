import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Page {
    background: Rectangle { color: "#f5f5f7" }

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

        TextField {
            id: emailInput
            placeholderText: "Enter email"
            Layout.fillWidth: true
            font.pixelSize: 16
            padding: 12
        }

        TextField {
            id: passwordInput
            placeholderText: "Enter password (min 6 chars)"
            echoMode: TextInput.Password
            Layout.fillWidth: true
            font.pixelSize: 16
            padding: 12
        }

        Button {
            id: signUpBtn
            text: "Sign Up"
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            font.pixelSize: 18
            background: Rectangle {
                color: signUpBtn.down ? "#1e7e34" : "#28a745"
                radius: 8
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