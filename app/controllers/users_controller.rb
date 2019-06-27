class UsersController < ApplicationController

  before_action :authenticate_user, {only: [:index, :show, :edit, :update]}
  before_action :forbid_login_user, {only: [:new, :create, :login_form, :login]}
  before_action :ensure_correct_user, {only: [:edit, :update]}

  def index
    @users = User.all.order(created_at: :desc)
  end
  def show
    @user = User.find_by(id: params[:id])
  end
  def new
    @user = User.new
  end
  
  def create
   #デフォルトのイメージでユーザー登録
   @user = User.new(
                    name: params[:name], 
                    email: params[:email],
                    image_name: "default_user.jpg"
                    )
   @user.password = params[:password]
   if @user.save
       session[:user_id] = @user.id
       flash[:notice] = "ユーザー登録が完了しました"
       redirect_to("/users/#{@user.id}")
   else
       @user.name = params[:name]
       @user.email = params[:email]
       render("users/new")
   end
  end

  def edit
    @user = User.find_by(id: params[:id])
  end
  
  def update
   @user = User.find_by(id: params[:id])
   @user.name = params[:name]
   @user.email = params[:email]

   if @user.save
     #イメージが見つかった
     if params[:image]
       #ユーザーidのイメージを新規作成
       @user.image_name = "#{@user.id}.jpg"
       image = params[:image]
       #ユーザーidイメージに選択イメージを書き込む
       File.binwrite("public/user_images/#{@user.image_name}", image.read)
     end
       flash[:notice] = "ユーザー情報を編集しました"
       redirect_to("/users/#{@user.id}")
   else
       render("users/edit")
   end
  end

  def login_form
  end

  def login
    @user = User.find_by(email: params[:email])
    if @user && @user.authenticate(params[:password])
      session[:user_id] = @user.id
      flash[:notice] = "ログインしました"
      redirect_to("/posts/index")
    else
      @error_message = "メールアドレスまたはパスワードが間違っています"
      @email = params[:email]
      @password = params[:password]
      render("users/login_form")
    end
  end

  def logout
    session[:user_id] = nil
    flash[:notice] = "ログアウトしました"
    redirect_to("/login")
  end

  def likes
    @user = User.find_by(id: params[:id])
    @likes = Like.where(user_id: @user.id)
  end

  def ensure_correct_user # 正しいユーザーかを確かめるという意味
    #詳細ページのユーザーとログイン中のユーザーが一致するかを判定
    if @current_user.id != params[:id].to_i
      #フラッシュを表示するための処理
      flash[:notice] = "権限がありません"
      #リダイレクト
      redirect_to("/posts/index")
    end
  end

end
