import QtQuick
import QtQuick.Controls

ApplicationWindow {
    visible: true
    width: 400
    height: 700
    title: "Campus Trading"
    color: "#f5f5f7"

    StackView {
        id: stackView
        anchors.fill: parent
        // Set initial page to Sign In page
        initialItem: "pages/SignInPage.qml" 
    }
}