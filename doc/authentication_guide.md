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
