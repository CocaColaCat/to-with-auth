class TodosController < ApplicationController

  def index
    @todos = Todo.all
    @todo = Todo.new
  end

  # todo local varible, scope
  # @todo instance varible, scope: controller, view @todos.each
  # Todo.create()
  # Todo.new()
  def create
    todo = Todo.new(todo_params)
    if todo.save
      redirect_to todos_path
    end
  end

  # params, rails 给定变量, { }, 从客户端传入的参数，url 参数，表格的参数
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
    # { title: "1st task", remark: "", is_ }
    #  rails strong paramters, security, web
  end
end
