from PySide6.QtCore import QObject, Slot
from core.SimpleModel import SimpleModel
from core.DataManager import dataManager

PLACEHOLDER_IMAGE = 'placeholder.svg'


class BrowsePageHandler(QObject):
    categoryModel = SimpleModel()
    listModel = SimpleModel()

    def __init__(self, engine):
        super().__init__()
        engine.rootContext().setContextProperty(self.__class__.__name__, self)
        engine.rootContext().setContextProperty('categoryModel', self.categoryModel)
        engine.rootContext().setContextProperty('listModel', self.listModel)

    @Slot()
    def handleLoadCategories(self):
        try:
            response = dataManager.supabase.table('categories') \
                .select('id, name').order('id').execute()
        except Exception as error:
            # 网络异常时保留原有分类数据，不打断界面
            print('handleLoadCategories failed:', error)
            return

        # 最前面加一个“全部”选项，用 id = 0 表示不按分类筛选
        data = [dict(id=0, name='All')]
        for category in response.data:
            data.append(dict(id=category['id'], name=category['name']))

        self.categoryModel.setData(data)

    @Slot(int)
    def handleLoadData(self, category_id):
        try:
            # 同时取 available 与 sold：已售商品不隐藏，只在界面上灰化并沉到列表末尾
            query = dataManager.supabase.table('products') \
                .select('id, seller_email, title, price, image_url, created_at, status')

            # category_id 为 0（All）时不加筛选，否则只查该分类
            if category_id != 0:
                query = query.eq('category_id', category_id)

            response = query.order('created_at', desc=True).execute()
            products = response.data
            # 已售商品统一沉到列表末尾，其余仍按创建时间倒序
            products.sort(key=lambda item: item.get('status') != 'available')

            # seller_email 没有外键约束，分两次查询，手动拼卖家 nickname
            emails = [p['seller_email'] for p in products]
            nickname_map = {}
            if len(emails) > 0:
                user_response = dataManager.supabase.table('users') \
                    .select('email, nickname').in_('email', emails).execute()
                nickname_map = {u['email']: u['nickname'] for u in user_response.data}
        except Exception as error:
            # 网络异常时保留原列表，不打断界面
            print('handleLoadData failed:', error)
            return

        data = []
        for product in products:
            seller = nickname_map.get(product['seller_email'], product['seller_email'])
            local_time = dataManager.toLocalTime(product['created_at']) \
                if product['created_at'] else ''
            price = float(product['price'])
            # 整数价格不带小数位，48.0 显示为 $48 而不是 $48.0
            price_text = f"${int(price)}" if price == int(price) else f"${price:.2f}"
            data.append(dict(
                id=product['id'],
                title=product['title'],
                price_text=price_text,
                content=f"{seller}  {local_time}",
                image_url=product['image_url'] if product['image_url'] else PLACEHOLDER_IMAGE,
                status=product.get('status') or 'available'
            ))

        self.listModel.setData(data)
