class TodosController < ApplicationController
  # 定义前置操作，限制此控制器内的 actions 都要执行这个方法：认证用户
  before_action :authenticate!

  def index
    # 获取当前用户的 todos
    @todos = @current_user.todos
    @todo= Todo.new
  end

  def create
    todo = Todo.new(todo_params)
    todo.user = @current_user
    if todo.save!
      redirect_to todos_path
    end
  end

  def update
    todo = Todo.find(params[:id])
    todo.update(todo_params)
    redirect_to todos_path
  end

  def destroy
    todo = Todo.find(params[:id])
    todo.destroy
    redirect_to todos_path
  end

  def edit
    @todo = Todo.find(params[:id])
  end

  private
  def todo_params
    params.require(:todo).permit(:title, :remark, :is_finished)
  end

  def authenticate!
    # 先通过 session 中的 user_id 来查找用户，同时赋值给实例变量
    @current_user = User.find_by(id: session[:user_id])

    # 如果没找到用户，那么就重定向到登录页面
    if @current_user.blank?
      redirect_to login_path and return
    end
  end
end
