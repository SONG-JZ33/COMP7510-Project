"""M3 商品发布的数据访问；使用组长提供的已登录 Supabase 客户端。"""

from decimal import Decimal, InvalidOperation
from pathlib import Path
from uuid import uuid4
from postgrest.exceptions import APIError
from storage3.exceptions import StorageApiError


class PublicationUncertain(RuntimeError):
    """请求已经发出但结果无法确认；调用方应提醒用户先检查再重试。"""


class SupabasePostRepository:
    """只负责分类读取、图片上传和商品插入，不创建客户端或改变数据库结构。"""

    _MIME_TYPES = {".png": "image/png", ".jpg": "image/jpeg", ".jpeg": "image/jpeg", ".webp": "image/webp"}
    _ALLOWED_CONDITIONS = ("new", "like_new", "good", "fair")
    _MAX_IMAGE_BYTES = 5 * 1024 * 1024
    # 只在 PostgreSQL 明确拒绝单次 INSERT 时清理图片，如违反字段约束或没有权限。
    _INSERT_REJECTIONS = {"23502", "23503", "23505", "23514", "42501"}

    def __init__(self, data_manager):
        # 复用小组主程序的连接和登录用户，无需另建客户端或登录页面。
        if data_manager.supabase is None:
            raise ValueError("Initialize the team Supabase client first.")
        self._data_manager = data_manager
        self._client = data_manager.supabase

    def load_categories(self) -> list[dict]:
        """读取分类供 QML 下拉框选择；返回 id、name 两个字段。"""
        rows = self._client.table("categories").select("id,name").order("name").execute().data
        return [{"id": str(row["id"]), "name": str(row["name"])} for row in rows]

    def publish_product(self, title: str, price: str, condition: str, category_id: str,
                        description: str, image_path: str) -> None:
        """先上传图片再插入商品；任何结果不确定时保留图片供人工核对。"""
        title, description, category_id = title.strip(), description.strip(), category_id.strip()
        if not title or not description or not category_id:
            raise ValueError("Please enter a product name and description and select a category.")
        if condition not in self._ALLOWED_CONDITIONS:
            raise ValueError("Please select a valid item condition.")
        try:
            amount = Decimal(price.strip())
            if not amount.is_finite() or amount <= 0 or amount.as_tuple().exponent < -2:
                raise ValueError("Price must be greater than zero with at most two decimal places.")
        except InvalidOperation as error:
            raise ValueError("Please enter a valid price, such as 35.00.") from error

        image = Path(image_path)
        mime = self._MIME_TYPES.get(image.suffix.lower())
        if not mime or not image.is_file():
            raise ValueError("Please select a PNG, JPG or WebP image.")
        if image.stat().st_size > self._MAX_IMAGE_BYTES:
            raise ValueError("The image exceeds the allowed size.")
        image_bytes = image.read_bytes()  # 上传前读取，避免写入一半才发现本地文件不可读。

        # 每次发布时读取当前登录账号，用户退出后就不能继续发布。
        if self._client is not self._data_manager.supabase:
            raise PermissionError("The sign-in connection has changed. Reopen the publishing page.")
        user = self._data_manager.user
        if not getattr(user, "email", None) or not getattr(user, "id", None):
            raise PermissionError("Please sign in with a team account first.")
        user_id = str(user.id)

        row = {
            "title": title, "description": description,
            "price": str(amount),  # 小组统一按港元保存，例如 58.50。
            "condition": condition,
            "category_id": int(category_id) if category_id.isdecimal() else category_id,
            "seller_email": user.email, "status": "available",
        }

        object_path = f"{user_id}/{uuid4().hex}{image.suffix.lower()}"
        bucket = self._client.storage.from_("project-images")
        try:
            bucket.upload(object_path, image_bytes, {"content-type": mime, "upsert": "false"})
        except StorageApiError as error:
            if str(error.status) in {"401", "403"}:
                raise PermissionError("Image upload was denied. Check your account and upload permissions.") from error
            raise PublicationUncertain("Image upload could not be confirmed. Check the image bucket first.") from error
        except Exception as error:
            raise PublicationUncertain("Image upload could not be confirmed. Check the image bucket first.") from error
        try:
            row["storage_path"] = object_path
            row["image_url"] = bucket.get_public_url(object_path)
            if not row["image_url"]:
                raise ValueError("No image URL was returned")
        except Exception as error:
            raise PublicationUncertain("Image uploaded, but its public URL could not be obtained. Check the image bucket.") from error

        try:
            result = self._client.table("products").insert(row).execute()
        except APIError as error:
            # 网关 502 或不明错误也会包装为 APIError；此时商品可能已保存。
            if error.code not in self._INSERT_REJECTIONS:
                raise PublicationUncertain("Publication could not be confirmed. Check the product list before retrying.") from error
            try:
                bucket.remove([object_path])
            except Exception as cleanup_error:
                raise ValueError("The database rejected the item and image cleanup failed. Contact the team leader.") from cleanup_error
            raise ValueError("The database rejected the item. Image cleanup was requested. Check fields and permissions.") from error
        except Exception as error:
            # 服务器可能已插入，只是响应丢失；不删除可能被商品引用的图片。
            raise PublicationUncertain("Publication could not be confirmed. Check the product list and contact the team leader about the image.") from error
        if not result.data:
            raise PublicationUncertain("No publication confirmation was received. Check the product list before retrying.")
