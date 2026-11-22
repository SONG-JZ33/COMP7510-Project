import QtQuick
import QtQuick.Controls

ApplicationWindow {
    visible: true
    width: 400
    height: 700
    title: "Campus Trading"
    color: "#f5f5f7"
    onClosing: function(close) {
        if (m3PostHandler.publishing)
            close.accepted = false
    }

    StackView {
        id: stackView
        anchors.fill: parent
        // Set initial page to Sign In page
        initialItem: "pages/SignInPage.qml" 
    }
    Connections {
    target: authHandler
    function onLogoutSuccess() {
        stackView.replace("pages/SignInPage.qml") // 强制退回登录页
    }
}
}
