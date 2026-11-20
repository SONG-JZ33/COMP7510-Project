import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects 
Page {
    background: Rectangle { color: "#f5f5f7" }

    // Top Navigation Bar
    header: ToolBar {
        background: Rectangle { color: "#ffffff" }
        RowLayout {
            anchors.fill: parent
            Label { 
                text: "My Listings"; 
                font.bold: true; 
                font.pixelSize: 18;
                Layout.fillWidth: true; 
                horizontalAlignment: Text.AlignHCenter 
            }
        }
    }

    // Automatically request data when the page loads
    Component.onCompleted: listingsHandler.loadMyListings()

    // Empty state (shown when the user has not posted anything)
    Label {
        anchors.centerIn: parent
        text: "You haven't posted anything yet."
        color: "#999"
        font.pixelSize: 16
        visible: listingsHandler.listings.length === 0
    }

    // Product List
    ListView {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 10
        clip: true 
        model: listingsHandler.listings 
        
        delegate: Rectangle {
            width: ListView.view.width
            height: 110
            color: "white"
            radius: 10
            
            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 15

                // Product Image (with rounded corners)
                Image {
                    source: modelData.image_url
                    Layout.preferredWidth: 90
                    Layout.preferredHeight: 90
                    fillMode: Image.PreserveAspectCrop
                    layer.enabled: true
                    layer.effect: OpacityMask {
                        maskSource: Rectangle { width: 90; height: 90; radius: 8 }
                    }
                }

                // Product Information
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 5
                    
                    Label { 
                        text: modelData.title; 
                        font.bold: true; 
                        font.pixelSize: 16; 
                        elide: Text.ElideRight; 
                        Layout.fillWidth: true 
                    }
                    Label { 
                        text: "$" + modelData.price; 
                        color: "#007bff"; 
                        font.bold: true; 
                        font.pixelSize: 15 
                    }
                    Label { 
                        text: "Status: " + (modelData.status === 'sold' ? 'SOLD' : 'Available'); 
                        color: modelData.status === 'sold' ? '#dc3545' : '#28a745'; 
                        font.pixelSize: 12 
                    }
                }

                // Action Buttons
                ColumnLayout {
                    spacing: 5
                    
                    // Mark as Sold button (hidden if already sold)
                    Button {
                        text: "Mark Sold"
                        visible: modelData.status !== 'sold'
                        Layout.preferredHeight: 35
                        Layout.preferredWidth: 90
                        background: Rectangle { color: "#ffc107"; radius: 6 }
                        contentItem: Text { 
                            text: "Mark Sold"; 
                            color: "#333"; 
                            font.pixelSize: 12; 
                            font.bold: true;
                            horizontalAlignment: Text.AlignHCenter; 
                            verticalAlignment: Text.AlignVCenter 
                        }
                        onClicked: listingsHandler.markAsSold(modelData.id)
                    }
                    
                    // Delete button
                    Button {
                        text: "Delete"
                        Layout.preferredHeight: 35
                        Layout.preferredWidth: 90
                        background: Rectangle { color: "#ffe6e6"; radius: 6 }
                        contentItem: Text { 
                            text: "Delete"; 
                            color: "#dc3545"; 
                            font.pixelSize: 12; 
                            font.bold: true;
                            horizontalAlignment: Text.AlignHCenter; 
                            verticalAlignment: Text.AlignVCenter 
                        }
                        onClicked: listingsHandler.deleteProduct(modelData.id)
                    }
                }
            }
        }
    }
}
