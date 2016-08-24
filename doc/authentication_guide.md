### 登录注册

#### 创建 user model

在 terminal（终端）中运行以下命令，创建 user.rb 文件 和向数据库中插入 users 表格
```sh
# 在 terminal 中执行
rails g model user username:string password_digest:string
rake db:migrate
```

#### 实现用户注册

首先是生成用户控制器，支持 new（获取注册表格）和 create（新添用户）actions。
在 terminal 中运行下面命令，注意 users 是复数
```sh
# 在 terminal 中执行
rails g controller users new create
```

打开 config/routes.rb，按照如下文件修改：

```ruby
# 文件地址: config/routes.rb

Rails.application.routes.draw do
  resources :todos

  # 配置 user 资源的路由，只支持 new 和 create
  resources :users, only: [:new, :create]
end
```

这个时候如果启动服务 `rails s`， 打开浏览器输入地址 `http://localhost:3000/users/new` 会发现页面显示如下信息。我们需要把这个页面改造成用户注册表单。
```
Users#new

Find me in app/views/users/new.html.erb
```

打开文件 `app/views/users/new.html.erb` 敲入如下代码（建议手动敲入，不要 ctrl+c ctrl+v)
```ruby
# 文件地址: app/views/users/new.html.erb

<div class="box post">
  <!-- 显示错误信息 -->
  <% if flash[:notice] %>
    <p class="box notice"> <%= flash[:notice] %> </p>
  <% elsif flash[:error] %>
    <p class="box error"> <%= flash[:error] %> </p>
  <% end %>

  <!-- 用户注册的表格 -->
  <div class="account">
    <h3>用户注册</h3>
    <%= form_for @user do |f| %>
    <p><label>　用户名: </label><%= f.text_field :username %></p>
    <p><label>　　密码: </label><%= f.password_field :password %></p>
    <p><label>确认密码: </label><%= f.password_field :password_confirmation %></p>
    <p><%= f.submit "注册" %></p>
    <p><%= link_to "已有账号？快来登陆", login_path %></p>
    <% end %>
  </div>
</div>
```

然后浏览器刷新页面 `http://localhost:3000/users/new`，页面会报错，如下信息：
注意阅读出错信息，先自己思考如何解决，后续会给出答案。

```
ArgumentError in Users#new
...
省略更多错误信息
...
```

初始化新用户。打开 `app/controller/users_controller.rb` 同时修改 `new` 方法如下。
```ruby
# 文件地址: app/controller/users_controller.rb
def new
  # 实例一个新用户，同时赋值给实例变量 @user。回忆为什么是实例变量？
  @user = User.new
end
```

然后刷新网页，你会看到如下出错信息，这是因为在程序执行的时候，碰到`app/views/users/new.html.erb`文件中的 17 行的 `login_path` 方法，发现这个路由方法没有定义，现在去定义。
```
undefined local variable or method `login_path' for #<#<Class:0x007fe40c00ed38>:0x007fe4057af8f0>
```

按照如下代码修改文件 `config/routes.rb`

```ruby
# 文件地址: config/routes.rb

Rails.application.routes.draw do
  resources :todos

  # 配置 user 资源的路由，只支持 new 和 create
  resources :users, only: [:new, :create]

  get '/login', to: 'sessions#new'
end
```

然后再刷新浏览器页面，现在应该看到用户注册表单了。填写注册表单，然后点击提交，这个时候浏览器会向后台发送一个 `post` （创建用户）的请求。
但是并没有用户被创建，同时页面跳转到了
```
Users#create
Find me in app/views/users/create.html.erb
```

这是因为没有实现 `create` 方法。现在实现。打开 `app/controller/users_controller.rb`，按照如下代码修改：
```ruby
class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    # 初始化用户
    @user = User.new
    # 根据注册表单传输过来的参数给新用户赋值
    @user.attributes = user_params

    # 保存用户信息到数据库
    if @user.save
      # 如果保存成功则重定向到登录页面
      redirect_to login_path, notice: "注册成功，请登陆"
    else
      # 反之则留在用户注册页面，同时输出错误提示
      flash[:error] = "用户信息填写有误"
      render :new
    end
  end

  private
  def user_params
    params.require(:user).permit(:username, :password, :password_confirmation)
  end

end
```

所有情况下用户输入的密码都不能明文保存在数据库中，需要完成加密才能存入数据库。因此需要依赖 `gem`, `bcrypt`。更新 `Gemfile`，把 `#gem 'bcrypt', '~> 3.1.7'` 这行的注释符号去掉 `#`，变成下面的代码。保存文件然后运行 `bundle install`。
```ruby
# 文件地址: Gemfile

gem 'bcrypt', '~> 3.1.7'
```

然后还需要修改 `user.rb` 文件，按照如下代码键入修改：
```ruby
# 文件地址: app/models/user.rb

class User < ApplicationRecord
  has_secure_password
end
```

重启服务器后刷新浏览器，这个时候再填写用户注册表单点击提交就能实现用户注册了。但是界面会显示如下错误。这是因为系统在抱怨找不到登录的控制器 `SessionsController`，这个我们下一个小结讲解实现。
```
uninitialized constant SessionsController
```

怎么知道用户已经创建了呢？可以通过访问数据库来查找。
```sh
# terminal 中打开 rails console
rails c

# 查找最后一个创建的用户，并输出用户的 username
user = User.last
user.username
```
完成以上操作如果输出的用户名和你之前注册的用户名一样，那么就说明这个功能完成了。

#### 实现用户登录
浏览器中打开页面 `http://localhost:3000/users/new` ，点击页面上的链接`已有账号？快来登陆`，这个时候输入框的路由会变成 `http://localhost:3000/login`，同时页面出错
```
uninitialized constant SessionsController
```

这是因为获取登录页面的时候，系统找到了路由，但是没有找到匹配的控制器 `SessionsController`。
在这里要着重介绍登录功能的实现。一般情况一个控制器会对应一个模型（model），这样的模式相当于资源（模型）和对资源的操作（控制器）。但是登录不需要资源，那么如何知道用户是否登录了呢？
这可以通过一个叫做 `session` 的对象来保存用户登录的状态。这里的 `session` 可以看成是一个存储器，如果用户成功登陆后，它负责保存用户的 id。这个 `session` 会存在浏览器中。每次浏览器给服务器发送请求的时候，都会把 `session` 中的数据一并传过来。整个过程可以简化为下面的过程

```
        请求敏感信息（没有 session）
浏览器 ------------------------> Web 应用（Rails)
      <-----------------------
        没有权限，请先登录


        登录（传用户名，密码）
浏览器 ------------------------> Web 应用（Rails)
      <-----------------------
        登录成功（返回带有用户 id session 的信息）


        请求敏感信息（传送 session）
浏览器 ------------------------> Web 应用（Rails)
      <-----------------------
        验权通过，返回敏感信息
```

现来创建 SessionsController 控制器。在 terminal 中输入以下命令

```sh
# 在 terminal 中执行
rails g controller sessions new create destroy
```

按照如下代码修改文件 `config/routes.rb`。这是配置登录功能相关的路由

```ruby
# 文件地址: config/routes.rb

Rails.application.routes.draw do
  resources :todos

  # 配置 user 资源的路由，只支持 new 和 create
  resources :users, only: [:new, :create]

  get '/login', to: 'sessions#new'           # 获取登录表路由
  post '/login', to: 'sessions#create'       # 登录路由
  delete '/logout', to: 'sessions#destroy'   # 登出路由
end
```

这个时候刷新浏览器，页面会变成如下。
```
Sessions#new

Find me in app/views/sessions/new.html.erb
```

但是我们要的是登录表格。所以键入以下登录表格的代码（不到偷懒复制粘贴哟），然后刷新浏览器。如果用之前注册的用户信息去登录是不会成功的，还需要实现 `SessionsController` 的 `create` action。
```ruby
<% if flash[:notice] %>
  <p class="box notice"> <%= flash[:notice] %> </p>
<% elsif flash[:error] %>
  <p class="box error"> <%= flash[:error] %> </p>
<% end %>

<div class="account">
  <h3>用户登陆</h3>
  <%= form_tag login_path do |f| %>
  <p><label>　用户名: </label><%= text_field_tag :username %></p>
  <p><label>　　密码: </label><%= password_field_tag :password %></p>
  <p><%= submit_tag "登陆" %></p>
  <p><%= link_to "还没账号？快来注册", new_user_path %></p>
  <% end %>
</div>
```

更新 `sessions_controller` 中的 `action` 方法。
```ruby
# 文件地址: app/controllers/sessions_controller.rb

def create
  # 通过用户名去数据库中查找用户
  user = User.find_by(username: params[:username])

  # 如果用户找到，同时密码匹配
  if user && user.authenticate(params[:password])
    # 如果成功，则跳转到 login_as 方法，下面会给出实现
    login_as user

    # 设置登陆成功提示信息，同时跳转到 todos 页面
    flash[:notice] = "登陆成功"
    redirect_to todos_path
  else

    # 登陆不成功，设置出错提示信息，同时渲染登录页面
    flash[:error] = "用户名或密码错误"
    render :new
  end
end
```

更新 `application_controller.rb` 文件，添加 login_as 方法。完成以上代码后，如果你能登录并跳转到 todos 页面，那么就说明登录功能完成实现了。
```ruby
# 文件地址: app/controllers/application_controller.rb

def login_as(user)
  # 把当前用户的 id 存在 session 中，session 会被返回给浏览器
  session[:user_id] = user.id

  # 把 user 的信息赋值给 instance variable（带有 @)，这是为了方便后面引用
  @current_user = user
end
```

#### 实现私有 todo list
首先需要修改 todo 的列表页面，只显示当前用户创建的 todo 任务。数据库层层面，表和表数据之前的关联关系是通过外键（foreign key）实现的。比如说用户表和 todo 任务表的关系是用户有多个
todo 任务，一个 todo 任务属于一个用户。那么在 todo 表里面就保存从属用户 id，因此在获取 todo 任务信息的时候，user id 就能作为索引值在用户表中查找对应的用户信息。

**Todos Table**

 id | title | remark | user_id
----|------|----|----
1 | 学习 ruby 基础知识 | 完成《ruby 基础》1-7章节 | 1
2 | 学习 ruby 基础知识 | 完成《ruby 基础》8-11章节 | 1
3 | 完成 rails tutorial  | - | 1
4 | 学习 Git 和 command line | -  | 2
5 | 学习 ruby 基础知识 | 完成《ruby 基础》1-7章节 | 2

**Users Table**

 id | username | password
----|------|----
1 | Lily| ******
2 | Iris | ******
3 | 楠 | ******
4 | 金 | ******

综上，首先要修改 todo 表结构，增加 user_id 栏。这里的 user_id:references 是说把 user_id 作为外键添加到 todo 表结构中。Rails 和数据库会知道怎么做，感兴趣的同学可以
在搜索一下什么是外键。执行完后记得运行 rake db:migrate。
```sh
# 在 terminal 中执行
rails g migration AddUserToTodos user:references
```

然后修改 user.rb 和 todo.rb 来定义从属关系（光有外键还不足够，因为这只是在数据库层声明了数据间的关系，但是在 Rails 并不知道）

```ruby
# 文件地址: app/models/todo.rb

class Todo < ApplicationRecord
  belongs_to :user
end
```

```ruby
# 文件地址: app/models/user.rb

class User < ApplicationRecord
  has_secure_password

  has_many :todos
end
```

同时还需要修改控制层的代码。这里需要控制 todo 列表的访问权限：只有登录的用户才能访问。按如下代码修改 `TodosController`

```ruby
# 文件地址: app/controllers/todos_controller.rb

class TodosController < ApplicationController
  # 定义前置操作，限制此控制器内的 actions 都要执行这个方法：认证用户
  before_action :authenticate!

  def index
    # 获取当前用户的 todos
    @todos = @current_user.todos
    @todo= Todo.new
  end

  private
  def authenticate!
    # 先通过 session 中的 user_id 来查找用户，同时赋值给实例变量
    @current_user = User.find_by(id: session[:user_id])

    # 如果没找到用户，那么就重定向到登录页面
    if @current_user.blank?
      redirect_to login_path and return
    end
  end

end
```

修改完代码后尝试新添一个 todo，但并不会成功，这是因为新建 todo 没有设置 todo 的 user_id。修改 `TodosController` 中的 `create` 方法如下。

```ruby
# 文件地址: app/controllers/todos_controller.rb

def create
  todo = Todo.new(todo_params)

  # 设定 todo 的 user_id 就是当前用户的 id
  todo.user_id = @current_user.id
  if todo.save!
    redirect_to todos_path
  end
end
```

这样就能任意为当前用户添加和删除 todo 任务了。那如何切换用户的 todo 任务呢？答案是登出，然后再登录当前用户。

#### 切换账号

切换账号要求登录的用户可以登出。修改 `application.html.erb`。在这里新增了两个方法 `logined?` 和 `current_user`，后续会解释。

```html
# 文件地址: app/views/layouts/application.html.erb

<body>
  <div class="page">
    <div class="user_info">
      <% if logined? %>
        <span class="username"><%= current_user.username %></span> <%= link_to "退出", logout_path, method: :delete %>
      <% else %>
        <%= link_to "登陆", login_path %> <%= link_to "注册", new_user_path %>
      <% end %>
    </div>
    <div class="header box">
      <h1><a href="/">Todo List</a></h1>
    </div> <!-- header end -->

    <%= yield %>

    <div class="foot">
      Copyright &copy; <a href="http://codingirls.club" target="_blank">CGC <%= image_tag("rails.png") %></a>
    </div> <!-- footer end -->
  </div> <!-- page end -->
</body>
```

按照上面的代码键入后，刷新页面会报错。这是因为以上提到的两个方法还没有定义。修改 `ApplicationController` 定义此方法。

```ruby
# 文件地址: app/controllers/application_controller.rb

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  # 定义两个 helper 方法，可以在 view 中引用
  helper_method :current_user, :logined?

  def login_as(user)
    session[:user_id] = user.id
    @current_user = user
  end

  # 如果 current_user 方法返回 nil，则说明没有登录
  def logined?
    current_user != nil
  end

  def current_user
    @current_user
  end
end
```

修改好后刷新页面会看到顶部多了一个 `登出` 的连接。点击链接跳转到登录页面，然后注册新用户进入到 todo 页面，如果此时新用户的 todo 页面是空空如也，那么就说明切换用户的功能成功实现。

#### 页面美化

把一下代码另存为 `todo.css`，并放在 `app/assets/stylesheets` 文件目录下。
```css
body { background:#EEE; }
.box { margin-bottom:20px; }
.clear { clear:both; }
.float_left { float:left; }
.float_right { float:right; }
.left { text-align:left; }
.right { text-align:right; }
.tips { color:#CCC; }
.v_top { vertical-align:top; }
.tips { color:#666; }
.long_txt { width:98%; }
.must_be { color:red !important; }
textarea { line-height:1.5em; }

image { border:none; }
p { line-height:1.5em; }

a { color:#3366CC; text-decoration:underline; }
a:hover { color:#FF3300; }

.page { width:700px; margin:10px auto; background:#FFF; padding:10px 20px; border:1px solid #CCC; border-radius:5px; }

.header { padding-top:10px; border-bottom:1px solid #CCC; }
.header h1 { font-size:50px; }
.header a { color:#333; text-decoration:none; }

.user_info { float: right; margin: 5px; }
.user_info a { text-decoration: none; color: #555; }
.user_info a:hover { text-decoration: underline; }
.username { color: #aaa; }

.box h2 { padding-bottom:5px; margin-bottom:10px; font-weight:400; color:#c52f24; font-size:28px;}

.account {
  margin: 0 auto;
  text-align: center;
  width: 250px;
  padding: 20px 50px;
}
.account a {
  font-size: 12px;
}
.account h3 {
  margin-bottom: 35px;
  font-size: 24px;
  color: #c52f24;
}
.account label {
  margin-right: 5px;
}

.notice { background-color: #d9edf7; padding: 15px; }
.error { background-color: #f2dede; padding: 15px; }

.todos ul { padding-left: 0; }
.todos ul li { list-style-type:none; margin-bottom:10px; padding-bottom:10px; border-bottom:1px dotted #CCC; }
.todos ul li.finished { color:#666; }
.todos ul li a { color:#666; }

.timeinfo { font-size: .5em; color: #ccc }

.post p { margin-bottom:10px; }
.post .submit { line-height:normal; -padding:0; }

.foot { border-top:1px solid #CCC; color:#666; padding-top:10px; font-size:11px; }
.foot a { line-height: 16px; text-decoration: none; }
.foot img { vertical-align:top; }
```

下载图片 https://github.com/CocaColaCat/to-with-auth/blob/master/app/assets/images/rails.png 并存在 `app/assets/images` 文件目录下。
