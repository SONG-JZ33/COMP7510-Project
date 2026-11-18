import QtQuick
import QtQuick.Controls

ApplicationWindow {
    visible: true
    width: 400
    height: 700
    title: "Campus Second-hand Trading"
    color: "#f5f5f7"

    StackView {
        id: stackView
        anchors.fill: parent
        // Set initial page to Sign In page
        initialItem: "pages/SignInPage.qml" 
    }
}