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

  def destroy
    session[:user_id] = nil
  end

  private
  def user_params
    params.require(:user).permit(:username, :password, :password_confirmation)
  end

end
