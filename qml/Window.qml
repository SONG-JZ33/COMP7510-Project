import QtQuick
import QtQuick.Controls
import "pages"

ApplicationWindow {
    width: 360
    height: 640
    visible: true
    title: "Campus Second-hand Market"

    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: browsePageComponent
    }

    Component {
        id: browsePageComponent
        BrowsePage {}
    }

    Component {
        id: itemDetailPageComponent
        ItemDetailPage {}
    }
}
