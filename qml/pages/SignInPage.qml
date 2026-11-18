import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Page {
    background: Rectangle { color: "#f5f5f7" }

    ColumnLayout {
        anchors.centerIn: parent
        width: parent.width * 0.8
        spacing: 20

        Text {
            text: "Welcome Back"
            font.pixelSize: 28
            font.bold: true
            Layout.alignment: Qt.AlignHCenter
            color: "#333"
        }

        TextField {
            id: emailInput
            placeholderText: "Enter email (e.g., m1@test.com)"
            Layout.fillWidth: true
            font.pixelSize: 16
            padding: 12
        }

        TextField {
            id: passwordInput
            placeholderText: "Enter password"
            echoMode: TextInput.Password
            Layout.fillWidth: true
            font.pixelSize: 16
            padding: 12
        }

        Button {
            id: loginBtn
            text: "Sign In"
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            font.pixelSize: 18
            background: Rectangle {
                color: loginBtn.down ? "#0056b3" : "#007bff"
                radius: 8
            }
            contentItem: Text {
                text: loginBtn.text
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            
            onClicked: {
                // Prevent double clicking, show loading state
                loginBtn.enabled = false
                loginBtn.text = "Signing in..."
                errorText.text = ""
                
                // Call Python Handler
                authHandler.handleLogin(emailInput.text, passwordInput.text)
            }
        }

        Text {
            id: errorText
            color: "red"
            font.pixelSize: 14
            Layout.alignment: Qt.AlignHCenter
            text: ""
        }
        Button {
            text: "Don't have an account? Sign Up"
            Layout.alignment: Qt.AlignHCenter
            flat: true
            onClicked: stackView.push("SignUpPage.qml")
        }
    }

    // Listen to signals from Python
    Connections {
        target: authHandler
        
       function onLoginSuccess() {
            console.log("QML Received: Login Success")
            loginBtn.enabled = true
            loginBtn.text = "Sign In"
            
            // 修改这里：去掉前面的 pages/，因为当前就在 pages 目录下
            stackView.push("PlaceholderPage.qml")
        }
        
        function onLoginFailed(errorMsg) {
            console.log("QML Received: Login Failed", errorMsg)
            loginBtn.enabled = true
            loginBtn.text = "Sign In"
            errorText.text = errorMsg
        }
    }
}