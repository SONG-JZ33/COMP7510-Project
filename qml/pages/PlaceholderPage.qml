import QtQuick
import QtQuick.Controls

Page {
    header: ToolBar {
        Text { text: "主页占位"; anchors.centerIn: parent }
    }
    Text {
        text: "登录成功！\n这是 M2 将来写商品列表的地方。"
        anchors.centerIn: parent
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: 20
    }
}