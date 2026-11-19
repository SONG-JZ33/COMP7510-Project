from PySide6.QtCore import QObject, Slot

from core.DataManager import dataManager
from core.ProductListModel import ProductListModel


class SearchPageHandler(QObject):
    """Search products by title using the actual public.products schema."""

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
            # Confirmed columns from the team's screenshot:
            # products.id (uuid), seller_email, title, price, condition.
            response = (
                dataManager.supabase.table("products")
                .select("id, title, price, condition, seller_email")
                .ilike("title", f"%{keyword}%")
                .execute()
            )

            items = []
            for product in response.data or []:
                items.append({
                    # Expose the UUID as a string role named product_id in QML.
                    "product_id": str(product.get("id") or ""),
                    "title": product.get("title") or "Untitled product",
                    "price": product.get("price"),
                    "condition": product.get("condition") or "",
                    "seller_email": product.get("seller_email") or "",
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
