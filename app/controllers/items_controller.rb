class ItemsController < ApplicationController
  before_action :set_item, only: [:myitem, :show, :destroy, :edit, :update]

  def index
    @ladys_items = Item.where(category_id: 1).order('id ASC').limit(10)
  end

  def new
  end

  def edit
    @brands = Brand.all
  end

  def update
    if @item.user_id == current_user.id
      # ブランドのif文
      if Brand.find_by(name: params[:brand_id]).present?
        xxx =Brand.find_by(name: params[:brand_id])
        params[:brand_id] ="#{xxx.id}"
            # ここまでは変更できてる
      else
        Brand.create(name: params[:barand_id])
        xxx =Brand.find_by(name: params[:brand_id])
        params[:brand_id] ="#{xxx.id}"
      end
    @item.update(item_params)
    end
    if @item.update(item_params)
      redirect_to root_path
    else
      render :edit
    end
  end


  def show
    @user_items = Item.where(user_id: "#{@item.user.id}").order('id ASC').limit(6).where.not(id: @item.id)
    @brand_items = Item.where(brand_id: "#{@item.brand.id}").order('id ASC').limit(6).where.not(id: @item.id)
  end

  def destroy
    @item.destroy  if @item.user_id == current_user.id
    if @item.destroy
      redirect_to root_path
    else
      render myitem
    end
  end

  def myitem
  end

  private

  def set_item
    @item = Item.find(params[:id])
  end

  def item_params
    params.require(:item).permit(:name,:description,:price,:region,:delivery_fee,:delivery_days,:shipping_method ,:brand_id,:category_id,item_images_attributes:[:image]).merge(user_id: current_user.id)
  end

end
