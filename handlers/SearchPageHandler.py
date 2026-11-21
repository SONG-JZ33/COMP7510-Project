from PySide6.QtCore import QObject, Slot

from core.DataManager import dataManager
from core.ProductListModel import ProductListModel


PLACEHOLDER_IMAGE = "placeholder.svg"


class SearchPageHandler(QObject):
    """Search products by title and expose their image URLs to the QML page."""

    def __init__(self, engine):
        super().__init__()
        self.searchModel = ProductListModel(self)
        engine.rootContext().setContextProperty("SearchPageHandler", self)
        engine.rootContext().setContextProperty("searchModel", self.searchModel)

    @Slot(str, result=bool)
    def handleSearch(self, keyword: str) -> bool:
        keyword = (keyword or "").strip()

        if not keyword:
            self.searchModel.clear()
            return False

        try:
            # image_url is the same products-table field used by BrowsePageHandler.
            response = (
                dataManager.supabase.table("products")
                .select("id, title, price, condition, seller_email, image_url")
                .ilike("title", f"%{keyword}%")
                .execute()
            )

            items = []
            for product in response.data or []:
                items.append({
                    "product_id": str(product.get("id") or ""),
                    "title": product.get("title") or "Untitled product",
                    "price": product.get("price"),
                    "condition": product.get("condition") or "",
                    "seller_email": product.get("seller_email") or "",
                    "image_url": product.get("image_url") or PLACEHOLDER_IMAGE,
                })

            self.searchModel.setItems(items)
            print(f"M4 search: {len(items)} product(s) matched {keyword!r}")
            return True

        except Exception as error:
            print("SearchPageHandler.handleSearch failed:", error)
            self.searchModel.clear()
            return False

    @Slot()
    def handleClear(self):
        self.searchModel.clear()
