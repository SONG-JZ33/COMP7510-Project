import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

// M3 发布页面：只负责收集资料，数据库和图片上传交给 Python handler。
Page {
    id: page
    objectName: "postItemPage"
    title: "Post Item"
    background: Rectangle { color: "#f4f6f5" }
    header: ToolBar {
        background: Rectangle { color: "white" }
        ToolButton {
            text: "Back"
            enabled: !page.postHandler || !page.postHandler.publishing
            onClicked: contentStack.pop()
        }
    }

    // handler 提供分类、加载与发布状态，以及带请求编号的 publishFinished 信号。
    property var postHandler: null
    property url imageUrl: ""
    property string localMessage: ""
    property bool pageReady: false
    property string pendingCategoryId: ""
    property int pendingPublishId: 0
    property string pendingPublishSnapshot: ""

    function formSnapshot() {
        var category = categoryBox.currentIndex >= 0 && categoryBox.currentIndex < categoryBox.model.length
                ? String(categoryBox.model[categoryBox.currentIndex].id) : ""
        return JSON.stringify([titleField.text, priceField.text, conditionBox.currentIndex,
                               category, descriptionField.text, page.imageUrl.toString()])
    }

    Connections {
        target: page.postHandler
        function onLoadingChanged() {
            // 分类列表被清空前，记住原选择；读取失败时保留这个意图供重试。
            if (page.postHandler.loading && categoryBox.currentIndex >= 0
                    && categoryBox.currentIndex < categoryBox.model.length)
                page.pendingCategoryId = String(categoryBox.model[categoryBox.currentIndex].id)
        }
        function onPublishFinished(requestId, success) {
            if (requestId !== page.pendingPublishId)
                return
            page.pendingPublishId = 0
            // 即使外部代码在等待中修改了表单，也不能清除新的输入。
            if (success && page.formSnapshot() === page.pendingPublishSnapshot) {
                titleField.clear()
                priceField.clear()
                descriptionField.clear()
                page.imageUrl = ""
                conditionBox.currentIndex = 0
            }
            page.pendingPublishSnapshot = ""
        }
    }

    function loadCategories() {
        if (postHandler)
            postHandler.loadCategories()
    }

    Component.onCompleted: {
        pageReady = true
        loadCategories()
    }
    onPostHandlerChanged: {
        pendingPublishId = 0
        pendingPublishSnapshot = ""
        // 如果主程序在页面创建后才注入 handler，也要加载分类。
        if (pageReady)
            loadCategories()
    }

    FileDialog {
        id: imageDialog
        title: "Choose Product Image"
        nameFilters: ["Image files (*.png *.jpg *.jpeg *.webp)"]
        onAccepted: {
            // 保留 Qt 返回的原始 URL，Python 负责转换成本机文件路径。
            page.imageUrl = selectedFile
            page.localMessage = ""
        }
    }

    ScrollView {
        id: scroll
        anchors.fill: parent
        clip: true
        contentWidth: availableWidth
        contentHeight: formCard.height + 24
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

        Rectangle {
            id: formCard
            width: Math.max(0, scroll.availableWidth - 24)
            height: formColumn.implicitHeight + 32
            x: 12
            y: 12
            radius: 10
            color: "white"
            border.color: "#eceeed"

            ColumnLayout {
                id: formColumn
                width: Math.max(0, parent.width - 32)
                x: 16
                y: 16
                spacing: 10

                Label {
                    Layout.fillWidth: true
                    Layout.minimumWidth: 0
                    text: "Post a Second-hand Item"
                    color: "#2c3e50"
                    font.pixelSize: 19
                    font.bold: true
                    wrapMode: Text.Wrap
                }

                Label { text: "Product Name" }
                TextField {
                    id: titleField
                    enabled: !page.postHandler || !page.postHandler.publishing
                    objectName: "postTitleField"
                    Layout.fillWidth: true
                    placeholderText: "e.g. Used textbook"
                    background: Rectangle {
                        radius: 6
                        color: "white"
                        border.color: titleField.activeFocus ? "#007bff" : "#dcdedd"
                    }
                }

                Label { text: "Price (HK$)" }
                TextField {
                    id: priceField
                    enabled: !page.postHandler || !page.postHandler.publishing
                    objectName: "postPriceField"
                    Layout.fillWidth: true
                    placeholderText: "e.g. 35.00"
                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                    background: Rectangle {
                        radius: 6
                        color: "white"
                        border.color: priceField.activeFocus ? "#007bff" : "#dcdedd"
                    }
                }

                Label { text: "Condition" }
                ComboBox {
                    id: conditionBox
                    enabled: !page.postHandler || !page.postHandler.publishing
                    objectName: "postConditionBox"
                    Layout.fillWidth: true
                    model: [
                        {key: "good", label: "Good"},
                        {key: "like_new", label: "Like New"},
                        {key: "new", label: "New"},
                        {key: "fair", label: "Fair"}
                    ]
                    textRole: "label"
                }

                Label { text: "Category" }
                Label {
                    Layout.fillWidth: true
                    Layout.minimumWidth: 0
                    text: "Select a category below. Refresh reloads the category list."
                    wrapMode: Text.Wrap
                }
                Button {
                    objectName: "reloadCategoriesButton"
                    Layout.fillWidth: true
                    text: page.postHandler && page.postHandler.loading ? "Loading categories..." : "Refresh Categories"
                    enabled: page.postHandler && !page.postHandler.loading && !page.postHandler.publishing && !page.postHandler.uncertain
                    onClicked: {
                        page.localMessage = ""
                        page.loadCategories()
                    }
                }
                ComboBox {
                    id: categoryBox
                    enabled: !page.postHandler || !page.postHandler.publishing
                    objectName: "postCategoryBox"
                    Layout.fillWidth: true
                    model: page.postHandler ? page.postHandler.categories : []
                    textRole: "name"
                    displayText: currentIndex >= 0 && currentIndex < model.length
                        ? model[currentIndex].name : "No categories available"
                    onModelChanged: {
                        if (!model.length || !page.pendingCategoryId)
                            return
                        var found = -1
                        for (var i = 0; i < model.length; ++i) {
                            if (String(model[i].id) === page.pendingCategoryId) {
                                found = i
                                break
                            }
                        }
                        currentIndex = found
                        page.pendingCategoryId = ""
                        if (found < 0)
                            page.localMessage = "This category is no longer available. Please choose another."
                    }
                    onActivated: {
                        if (page.localMessage === "This category is no longer available. Please choose another.")
                            page.localMessage = ""
                    }
                }

                Label { text: "Description" }
                TextArea {
                    id: descriptionField
                    enabled: !page.postHandler || !page.postHandler.publishing
                    objectName: "postDescriptionField"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 100
                    placeholderText: "Describe the condition and included accessories"
                    wrapMode: TextEdit.Wrap
                    background: Rectangle {
                        radius: 6
                        color: "white"
                        border.color: descriptionField.activeFocus ? "#007bff" : "#dcdedd"
                    }
                }

                Button {
                    objectName: "chooseImageButton"
                    enabled: !page.postHandler || !page.postHandler.publishing
                    Layout.fillWidth: true
                    text: "Choose Product Image"
                    onClicked: imageDialog.open()
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 170
                    color: "#f4f6f5"
                    border.color: "#eceeed"
                    radius: 8
                    clip: true

                    Image {
                        id: imagePreview
                        objectName: "postImagePreview"
                        anchors.fill: parent
                        anchors.margins: 5
                        source: page.imageUrl
                        fillMode: Image.PreserveAspectFit
                        asynchronous: true
                    }
                    Label {
                        anchors.centerIn: parent
                        visible: page.imageUrl.toString().length === 0 || imagePreview.status === Image.Error
                        text: page.imageUrl.toString().length === 0 ? "No image selected" : "Cannot preview image. Please choose another."
                    }
                }

                Label {
                    objectName: "postMessage"
                    Layout.fillWidth: true
                    visible: text.length > 0
                    wrapMode: Text.Wrap
                    text: page.localMessage || (page.postHandler ? page.postHandler.message : "")
                }

                Button {
                    objectName: "acknowledgeUncertainButton"
                    Layout.fillWidth: true
                    visible: page.postHandler && page.postHandler.uncertain
                    text: "I have checked. Enable publishing"
                    onClicked: page.postHandler.acknowledgeUncertain()
                }

                Button {
                    id: publishButton
                    objectName: "publishButton"
                    Layout.fillWidth: true
                    text: page.postHandler && page.postHandler.publishing ? "Publishing..." : "Post Item"
                    contentItem: Text {
                        text: publishButton.text
                        color: "white"
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    background: Rectangle {
                        radius: 8
                        color: !publishButton.enabled ? "#9cb8d7"
                               : publishButton.down ? "#0056b3" : "#007bff"
                    }
                    // 等分类读取完成再允许提交，避免加载期间显示过时的分类提示。
                    enabled: !page.postHandler || (!page.postHandler.loading && !page.postHandler.publishing && !page.postHandler.uncertain)
                    onClicked: {
                        if (page.postHandler && (page.postHandler.loading || page.postHandler.publishing || page.postHandler.uncertain))
                            return
                        if (!page.postHandler) {
                            page.localMessage = "Publishing is not connected. Please contact the team leader."
                            return
                        }
                        if (categoryBox.currentIndex < 0 || categoryBox.currentIndex >= categoryBox.model.length) {
                            page.localMessage = "Please select a category."
                            return
                        }
                        page.localMessage = ""
                        // 仅记录已启动的请求；真正成功后才清空相同的输入。
                        page.pendingPublishSnapshot = page.formSnapshot()
                        page.pendingPublishId = page.postHandler.publish(
                            titleField.text,
                            priceField.text,
                            conditionBox.model[conditionBox.currentIndex].key,
                            String(categoryBox.model[categoryBox.currentIndex].id),
                            descriptionField.text,
                            page.imageUrl.toString()
                        )
                        if (!page.pendingPublishId)
                            page.pendingPublishSnapshot = ""
                    }
                }
            }
        }
    }
}
