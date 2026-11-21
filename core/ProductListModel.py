from PySide6.QtCore import QAbstractListModel, QModelIndex, Qt


class ProductListModel(QAbstractListModel):
    """List model with fixed QML roles, including when the result set is empty."""

    ROLE_NAMES = (
        "product_id",
        "title",
        "price",
        "condition",
        "seller_email",
        "image_url",
    )

    def __init__(self, parent=None):
        super().__init__(parent)
        self._items = []
        self._roles = {
            Qt.ItemDataRole.UserRole + index + 1: name
            for index, name in enumerate(self.ROLE_NAMES)
        }

    def roleNames(self):
        return {
            role: name.encode("utf-8")
            for role, name in self._roles.items()
        }

    def rowCount(self, parent=QModelIndex()):
        if parent.isValid():
            return 0
        return len(self._items)

    def data(self, index, role=Qt.ItemDataRole.DisplayRole):
        if not index.isValid() or not (0 <= index.row() < len(self._items)):
            return None

        role_name = self._roles.get(role)
        if role_name is None:
            return None

        return self._items[index.row()].get(role_name)

    def setItems(self, items):
        self.beginResetModel()
        self._items = list(items or [])
        self.endResetModel()

    def clear(self):
        self.setItems([])
