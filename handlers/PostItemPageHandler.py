"""M3 发布页控制器：接收 QML 表单并交给注入的数据服务。"""

from decimal import Decimal, InvalidOperation
from typing import Any

from PySide6.QtCore import QObject, Property, QRunnable, QThreadPool, QUrl, Signal, Slot

from database.post_repository import PublicationUncertain


class _CategorySignals(QObject):
    finished = Signal(object, bool)


class _CategoryTask(QRunnable):
    """后台只读取分类；异常不传给页面，以免泄露连接信息。"""

    def __init__(self, repository: Any) -> None:
        super().__init__()
        self.repository = repository
        self.signals = _CategorySignals()

    def run(self) -> None:
        try:
            self.signals.finished.emit(self.repository.load_categories(), True)
        except Exception:
            self.signals.finished.emit([], False)


class _PublishSignals(QObject):
    finished = Signal(int, str, str)


class _PublishTask(QRunnable):
    """只持有仓库和输入快照；不捕获页面或控制器。"""

    def __init__(self, repository: Any, request_id: int, args: tuple) -> None:
        super().__init__()
        self.repository, self.request_id, self.args = repository, request_id, args
        self.signals = _PublishSignals()

    def run(self) -> None:
        try:
            self.repository.publish_product(*self.args)
        except PublicationUncertain:
            self.signals.finished.emit(self.request_id, "uncertain", "")
        except (ValueError, PermissionError) as error:
            self.signals.finished.emit(self.request_id, "rejected", str(error))
        except Exception:
            # 未知错误不展示异常细节，也不能假定远端一定没有写入。
            self.signals.finished.emit(self.request_id, "uncertain", "")
        else:
            self.signals.finished.emit(self.request_id, "success", "")


class PostItemPageHandler(QObject):
    """对页面提供分类、提示和发布结果；不管理组长的应用导航。"""

    categoriesChanged = Signal()
    messageChanged = Signal()
    loadingChanged = Signal()
    publishingChanged = Signal()
    uncertainChanged = Signal()
    published = Signal()
    publishFinished = Signal(int, bool)

    def __init__(self, repository: Any, parent: QObject | None = None,
                 success_message: str = "Item published successfully.") -> None:
        super().__init__(parent)
        self._repository = repository
        self._success_message = success_message
        self._categories: list[dict] = []
        self._message = ""
        self._loading = False
        self._category_task: _CategoryTask | None = None
        self._publishing = False
        self._uncertain = False
        self._request_id = 0
        self._publish_task: _PublishTask | None = None

    @Property("QVariantList", notify=categoriesChanged)
    def categories(self) -> list[dict]:
        return self._categories

    @Property(str, notify=messageChanged)
    def message(self) -> str:
        return self._message

    @Property(bool, notify=loadingChanged)
    def loading(self) -> bool:
        return self._loading

    @Property(bool, notify=publishingChanged)
    def publishing(self) -> bool:
        return self._publishing

    @Property(bool, notify=uncertainChanged)
    def uncertain(self) -> bool:
        return self._uncertain

    def _set_message(self, value: str) -> None:
        self._message = value
        self.messageChanged.emit()

    @Slot()
    def loadCategories(self) -> None:
        if self._loading or self._publishing or self._uncertain:
            return  # 一次只发送一个请求，避免较旧的结果覆盖较新的结果。
        self._loading = True
        self.loadingChanged.emit()
        self._categories = []
        self.categoriesChanged.emit()
        self._set_message("Loading categories...")
        task = _CategoryTask(self._repository)
        self._category_task = task  # 保留引用直至主线程收到结果。
        task.signals.finished.connect(self._categories_loaded)
        QThreadPool.globalInstance().start(task)

    @Slot(object, bool)
    def _categories_loaded(self, categories: object, ok: bool) -> None:
        self._categories = categories if ok else []
        self.categoriesChanged.emit()
        self._set_message("" if ok else "Failed to load categories. Check your connection or contact the team leader.")
        self._loading = False
        self.loadingChanged.emit()
        self._category_task = None

    @Slot()
    def acknowledgeUncertain(self) -> None:
        """用户核对商品和图片后，才允许手动再次发布。"""
        if self._uncertain and not self._publishing:
            self._uncertain = False
            self.uncertainChanged.emit()
            self._set_message("Check the product and image before deciding whether to retry.")

    @Slot(str, str, str, str, str, str, result=int)
    def publish(self, title: str, price: str, condition: str, categoryId: str,
                description: str, imageUrl: str) -> int:
        """返回请求编号；0 表示未启动，结果由 publishFinished 通知。"""
        if self._loading or self._publishing or self._uncertain:
            return 0
        if not title.strip() or not description.strip() or not categoryId.strip():
            self._set_message("Please enter a product name and description and select a category.")
            return 0
        try:
            amount = Decimal(price.strip())
            if not amount.is_finite() or amount <= 0 or amount.as_tuple().exponent < -2:
                raise ValueError
        except (InvalidOperation, ValueError):
            self._set_message("Price must be greater than zero with at most two decimal places.")
            return 0
        # QUrl 正确处理 file:///、空格、中文和 Windows 路径；拒绝远程 URL。
        url = QUrl(imageUrl)
        if not url.isLocalFile() or not url.toLocalFile():
            self._set_message("Please select an image from your computer.")
            return 0
        self._request_id += 1
        request_id = self._request_id
        self._publishing = True
        self.publishingChanged.emit()
        self._set_message("Publishing item, please wait...")
        task = _PublishTask(self._repository, request_id,
                            (title, price, condition, categoryId, description, url.toLocalFile()))
        self._publish_task = task
        task.signals.finished.connect(self._publish_finished)
        QThreadPool.globalInstance().start(task)
        return request_id

    @Slot(int, str, str)
    def _publish_finished(self, request_id: int, result: str, message: str) -> None:
        self._publish_task = None
        if result == "uncertain":
            self._uncertain = True
            self.uncertainChanged.emit()
            self._set_message("Publication could not be confirmed. Check the product list and image before retrying. Contact the team leader if needed.")
        elif result == "rejected":
            self._set_message(message)
        else:
            self._set_message(self._success_message)
        # 先让提交页面按快照处理完成结果，再允许列表刷新改变分类模型。
        self.publishFinished.emit(request_id, result == "success")
        self._publishing = False
        self.publishingChanged.emit()
        if result == "success":
            self.published.emit()  # 刷新列表仅在仓库确认成功后触发。
