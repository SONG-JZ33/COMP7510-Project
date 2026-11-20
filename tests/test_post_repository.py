"""用本机替身检查 M3 分类读取和发布流程，不连接小组数据库。"""

from pathlib import Path
from tempfile import TemporaryDirectory
from types import SimpleNamespace
from unittest import TestCase
from unittest.mock import MagicMock

from postgrest.exceptions import APIError

from database.post_repository import PublicationUncertain, SupabasePostRepository


class PostRepositoryTests(TestCase):
    def setUp(self):
        directory = TemporaryDirectory()
        self.addCleanup(directory.cleanup)
        image = Path(directory.name) / "lamp.jpg"
        image.write_bytes(b"test image")
        self.form = ("White Desk Lamp", "65.00", "good", "1", "Classroom test item.", str(image))
        self.client = MagicMock()
        self.manager = SimpleNamespace(
            supabase=self.client,
            user=SimpleNamespace(id="seller-1", email="seller@example.invalid"),
        )
        self.repository = SupabasePostRepository(self.manager)
        self.bucket = self.client.storage.from_.return_value
        self.bucket.get_public_url.return_value = "https://example.invalid/lamp.jpg"
        self.insert = self.client.table.return_value.insert
        self.insert.return_value.execute.return_value.data = [{"id": "product-1"}]

    def test_load_categories_returns_ids_and_names(self):
        query = self.client.table.return_value.select.return_value.order.return_value
        query.execute.return_value.data = [{"id": 1, "name": "Electronic products"}]
        self.assertEqual(self.repository.load_categories(), [{"id": "1", "name": "Electronic products"}])
        self.client.table.assert_called_once_with("categories")

    def test_publish_uploads_picture_and_saves_hkd_and_current_seller(self):
        self.repository.publish_product(*self.form)
        self.client.storage.from_.assert_called_once_with("project-images")
        self.bucket.upload.assert_called_once()
        row = self.insert.call_args.args[0]
        self.assertEqual(row["price"], "65.00")
        self.assertEqual(row["seller_email"], "seller@example.invalid")
        self.assertEqual(row["category_id"], 1)
        self.assertEqual(row["status"], "available")
        self.assertEqual(row["image_url"], "https://example.invalid/lamp.jpg")
        self.assertTrue(row["storage_path"].startswith("seller-1/"))

    def test_invalid_price_stops_before_upload(self):
        for price in ("0", "65.123", "abc"):
            with self.subTest(price=price):
                form = list(self.form)
                form[1] = price
                with self.assertRaises(ValueError):
                    self.repository.publish_product(*form)
        self.client.storage.from_.assert_not_called()
        self.client.table.assert_not_called()

    def test_logged_out_user_cannot_publish(self):
        self.manager.user = None
        with self.assertRaises(PermissionError):
            self.repository.publish_product(*self.form)
        self.client.storage.from_.assert_not_called()
        self.client.table.assert_not_called()

    def test_database_rejection_cleans_uploaded_picture(self):
        self.insert.return_value.execute.side_effect = APIError(
            {"message": "rejected", "code": "42501", "hint": "", "details": ""}
        )
        with self.assertRaisesRegex(ValueError, "database rejected"):
            self.repository.publish_product(*self.form)
        object_path = self.bucket.upload.call_args.args[0]
        self.bucket.remove.assert_called_once_with([object_path])

    def test_unknown_result_keeps_uploaded_picture_for_checking(self):
        self.insert.return_value.execute.side_effect = TimeoutError()
        with self.assertRaises(PublicationUncertain):
            self.repository.publish_product(*self.form)
        self.bucket.remove.assert_not_called()
