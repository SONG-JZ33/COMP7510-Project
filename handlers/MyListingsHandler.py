from PySide6.QtCore import QObject, Signal, Slot, Property
from core.DataManager import DataManager

class MyListingsHandler(QObject):
    # Define an empty list to store data and use a Signal to notify QML of changes
    _listings = []
    listingsChanged = Signal()

    def get_listings(self):
        return self._listings

    # Expose the Python list to QML's ListView
    listings = Property("QVariantList", get_listings, notify=listingsChanged)

    @Slot()
    def loadMyListings(self):
        user = DataManager.get_current_user()
        if not user: 
            return
        
        db = DataManager.get_db()
        try:
            # Core logic: query products where seller_email matches the current logged-in user
            res = db.table('products').select('*').eq('seller_email', user.email).execute()
            self._listings = res.data
            self.listingsChanged.emit() # Refresh the UI
        except Exception as e:
            print(" Failed to load my listings:", e)

    @Slot(str)
    def deleteProduct(self, product_id):
        db = DataManager.get_db()
        try:
            # Delete the product
            db.table('products').delete().eq('id', product_id).execute()
            self.loadMyListings() # Reload the list after deletion
            print(f" Deleted product {product_id}")
        except Exception as e:
            print(" Delete failed:", e)

    @Slot(str)
    def markAsSold(self, product_id):
        db = DataManager.get_db()
        try:
            # Update status to 'sold'
            db.table('products').update({'status': 'sold'}).eq('id', product_id).execute()
            self.loadMyListings() # Reload the list after update
            print(f" Marked product {product_id} as sold")
        except Exception as e:
            print(" Failed to mark as sold:", e)