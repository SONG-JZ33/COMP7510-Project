from PySide6.QtCore import QObject, Slot

from core.DataManager import dataManager
from core.ProductListModel import ProductListModel


class FavoritesPageHandler(QObject):
    """Load, add, and remove favorites using the actual favorites schema."""

    USER_COLUMN = "user_email"
    PRODUCT_COLUMN = "product_id"

    def __init__(self, engine):
        super().__init__()
        self.favoritesModel = ProductListModel(self)
        engine.rootContext().setContextProperty("FavoritesPageHandler", self)
        engine.rootContext().setContextProperty("favoritesModel", self.favoritesModel)

    @staticmethod
    def _current_user_email():
        user = getattr(dataManager, "user", None)
        user_id = getattr(user, "id", None)
        email = getattr(user, "email", None)

        # Do not use DataManager's demo@demo.com placeholder before sign-in.
        if not user_id or not email:
            return None
        return str(email).strip()

    @Slot(result=bool)
    def handleLoadFavorites(self) -> bool:
        email = self._current_user_email()
        if not email:
            self.favoritesModel.clear()
            print("Favorites: no authenticated user is signed in.")
            return False

        try:
            # favorites.product_id is a UUID foreign key to products.id.
            # PostgREST resolves the products relationship through that FK.
            response = (
                dataManager.supabase.table("favorites")
                .select(
                    "product_id, products!inner(id, title, price, condition, seller_email)"
                )
                .eq(self.USER_COLUMN, email)
                .execute()
            )

            items = []
            for favorite in response.data or []:
                product = favorite.get("products")

                # A many-to-one relationship is normally returned as a dict.
                # This also tolerates a list-shaped response.
                if isinstance(product, list):
                    product = product[0] if product else None
                if not product:
                    continue

                items.append({
                    "product_id": str(
                        product.get("id") or favorite.get("product_id") or ""
                    ),
                    "title": product.get("title") or "Untitled product",
                    "price": product.get("price"),
                    "condition": product.get("condition") or "",
                    "seller_email": product.get("seller_email") or "",
                })

            self.favoritesModel.setItems(items)
            print(f"Favorites: loaded {len(items)} product(s) for {email}")
            return True

        except Exception as error:
            print("FavoritesPageHandler.handleLoadFavorites failed:", error)
            self.favoritesModel.clear()
            return False

    @Slot(str, result=bool)
    def handleAddFavorite(self, product_id: str) -> bool:
        email = self._current_user_email()
        product_id = (product_id or "").strip()

        if not email or not product_id:
            return False

        try:
            # Avoid adding the same product twice for the same email.
            existing = (
                dataManager.supabase.table("favorites")
                .select("id")
                .eq(self.USER_COLUMN, email)
                .eq(self.PRODUCT_COLUMN, product_id)
                .limit(1)
                .execute()
            )

            if not existing.data:
                dataManager.supabase.table("favorites").insert({
                    "user_email": email,
                    "product_id": product_id,
                }).execute()

            self.handleLoadFavorites()
            return True

        except Exception as error:
            print("FavoritesPageHandler.handleAddFavorite failed:", error)
            return False

    @Slot(str, result=bool)
    def handleRemoveFavorite(self, product_id: str) -> bool:
        email = self._current_user_email()
        product_id = (product_id or "").strip()

        if not email or not product_id:
            return False

        try:
            (
                dataManager.supabase.table("favorites")
                .delete()
                .eq(self.USER_COLUMN, email)
                .eq(self.PRODUCT_COLUMN, product_id)
                .execute()
            )

            self.handleLoadFavorites()
            return True

        except Exception as error:
            print("FavoritesPageHandler.handleRemoveFavorite failed:", error)
            return False
