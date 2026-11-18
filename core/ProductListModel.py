from PySide6.QtCore import QAbstractListModel, QModelIndex, Qt


class ProductListModel(QAbstractListModel):
    """简单的商品列表模型，供搜索页和收藏页共用。"""

    ROLE_NAMES = {
        Qt.UserRole + 1: 'product_id',
        Qt.UserRole + 2: 'title',
        Qt.UserRole + 3: 'price',
        Qt.UserRole + 4: 'condition',
        Qt.UserRole + 5: 'seller_email',
    }

    def __init__(self, parent=None):
        super().__init__(parent)
        self._items = []

    def roleNames(self):
        return {role: name.encode('utf-8') for role, name in self.ROLE_NAMES.items()}

    def rowCount(self, parent=QModelIndex()):
        if parent.isValid():
            return 0
        return len(self._items)

    def data(self, index, role=Qt.DisplayRole):
        if not index.isValid():
            return None
        if index.row() < 0 or index.row() >= len(self._items):
            return None
        key = self.ROLE_NAMES.get(role)
        if key is None:
            return None
        return self._items[index.row()].get(key)

    def setItems(self, items):
        self.beginResetModel()
        self._items = [dict(item) for item in items]
        self.endResetModel()

    def clear(self):
        self.beginResetModel()
        self._items = []
        self.endResetModel()
