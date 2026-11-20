from PySide6.QtCore import QObject, Slot
from datetime import datetime, timezone
from core.SimpleModel import SimpleModel
from core.DataManager import dataManager


class ItemDetailPageHandler(QObject):
    commentModel = SimpleModel()
    data = None

    def __init__(self, engine):
        super().__init__()
        engine.rootContext().setContextProperty(self.__class__.__name__, self)
        engine.rootContext().setContextProperty('commentModel', self.commentModel)

    @Slot(str)
    def handleLoadData(self, product_id):
        try:
            response = dataManager.supabase.table('products').select(
                'id, seller_email, title, price, condition, description, '
                'image_url, created_at, categories!inner(name)'
            ).eq('id', product_id).execute()

            # 商品不存在时不清空旧数据，直接返回
            if len(response.data) == 0:
                return

            self.data = response.data[0]

            # seller_email 无外键，手动查卖家 nickname
            user_response = dataManager.supabase.table('users') \
                .select('email, nickname') \
                .eq('email', self.data['seller_email']).execute()
            if len(user_response.data) > 0:
                self.data['seller_name'] = user_response.data[0]['nickname']
            else:
                self.data['seller_name'] = self.data['seller_email']
        except Exception as error:
            # 网络异常时保留旧详情，不打断界面
            print('handleLoadData failed:', error)
            return

        self.handleLoadComments(product_id)

    @Slot(str)
    def handleLoadComments(self, product_id):
        try:
            response = dataManager.supabase.table('comments') \
                .select('id, user_email, content, created_at') \
                .eq('product_id', product_id) \
                .order('created_at').execute()
            comments = response.data

            # user_email 无外键，手动查留言人 nickname
            emails = [c['user_email'] for c in comments]
            nickname_map = {}
            if len(emails) > 0:
                user_response = dataManager.supabase.table('users') \
                    .select('email, nickname').in_('email', emails).execute()
                nickname_map = {u['email']: u['nickname'] for u in user_response.data}
        except Exception as error:
            print('handleLoadComments failed:', error)
            return

        data = []
        for comment in comments:
            local_time = dataManager.toLocalTime(comment['created_at']) \
                if comment['created_at'] else ''
            data.append(dict(
                user_name=nickname_map.get(comment['user_email'], comment['user_email']),
                content=comment['content'],
                created_text=local_time
            ))

        self.commentModel.setData(data)

    @Slot(result=str)
    def getTitle(self):
        return self.data['title'] if self.data else ''

    @Slot(result=str)
    def getImageUrl(self):
        if not self.data:
            return 'placeholder.svg'
        return self.data['image_url'] if self.data['image_url'] else 'placeholder.svg'

    @Slot(result=str)
    def getPrice(self):
        if not self.data:
            return ''
        price = float(self.data['price'])
        # 整数价格不带小数位，48.0 显示为 $48 而不是 $48.0
        return f"${int(price)}" if price == int(price) else f"${price:.2f}"

    @Slot(result=str)
    def getCondition(self):
        if not self.data:
            return '-'
        return self.data['condition'] or '-'

    @Slot(result=str)
    def getCategory(self):
        if not self.data:
            return '-'
        category = self.data.get('categories')
        return category['name'] if category else '-'

    @Slot(result=str)
    def getSeller(self):
        return self.data['seller_name'] if self.data else ''

    @Slot(result=str)
    def getDescription(self):
        if not self.data:
            return ''
        return self.data['description'] or 'No description'

    @Slot(result=bool)
    def isSignedIn(self):
        session = dataManager.supabase.auth.get_session()
        return session is not None and session.user is not None

    @Slot(str, str, result=str)
    def handleSendComment(self, product_id, content):
        content = content.strip()
        if len(content) == 0:
            return 'empty'

        # 留言必须登录，取当前登录用户的 email
        session = dataManager.supabase.auth.get_session()
        if session is None or session.user is None:
            return 'not_signed_in'

        data = dict(
            product_id=product_id,
            user_email=session.user.email,
            content=content,
            created_at=datetime.now(timezone.utc).isoformat()
        )

        try:
            dataManager.supabase.table('comments').insert(data).execute()
            self.handleLoadComments(product_id)
            return 'ok'
        except Exception as e:
            print(e)
            return 'error'
