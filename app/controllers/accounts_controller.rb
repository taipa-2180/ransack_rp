class AccountsController < ApplicationController
  authorize_resource
  #before_action :verify_admin, only: [:index, :destroy]
  before_action :load_account, except: [:create]

  def index
    @search = Account.ransack params[:q]
    @accounts = @search.result.paginate page: params[:page],  per_page: Settings.size.page
  end
 
  def show
  end

  def new
    @account = Account.new
  end

  def create
    @account = Account.new account_params
    @account.active_status = 1
    if @account.save
      log_in @account
      flash[:success] = t("addsuccess")
      redirect_to root_url
    else
      render :new
    end
  end

  def edit;
    @account = @account = Account.find(params[:id])
    account_owner(@account.id)
  end

  def update
    @account = Account.find_by id: (params[:id])
    if @account.update_attributes(edit_account_params)
      flash[:success] = t("editsuccess")
      redirect_to @account
    else
      render "edit"
    end
  end

  def destroy
    @account = Account.find(params[:id])
    if @account.destroy
      flash[:success] = t("deletedsuccess")
      redirect_to accounts_path
    else
      flash[:danger] = t("fail")
      redirect_to accounts_path
    end
  end

  private

  def account_params
    params.require(:account).permit(:name, :email, :password, :phone_number,
                                 :password_confirmation)
  end

  def edit_account_params
    params.require(:account).permit(:name, :active_status)
  end

  def load_account
    @account = Account.find_by(params[:id])
    return if @account
    flash[:error] = t(".content_error")
    redirect_to :index
  end
end
