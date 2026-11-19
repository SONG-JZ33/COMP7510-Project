from PySide6.QtCore import QAbstractListModel


class SimpleModel(QAbstractListModel):
    source: list[dict[str, any]] = []
    roleMap: dict[int, str] = None

    def __init__(self, parent=None):
        super().__init__(parent)

    def roleNames(self):
        roles = {}
        if len(self.source) > 0:
            keys = self.source[0].keys()
            self.roleMap = dict(enumerate(keys))
            roles = {i: k.encode('utf-8') for i, k in enumerate(keys)}

        return roles

    def rowCount(self, index):
        return len(self.source)

    def data(self, index, /, role=...):
        row = self.source[index.row()]
        key = self.roleMap[role]
        return row[key]

    def setData(self, source: list[dict[str, any]]):
        self.source = source  # 先赋值
        self.beginResetModel()
        self.endResetModel()

    def update(self, index, key, value):
        row = self.source[index]
        row[key] = value
        self.dataChanged(index, index, list(row.keys()).index(key))

    def clear(self):
        self.beginResetModel()
        self.source.clear()
        self.endResetModel()
