class TransactionInformationsController < ApplicationController
  before_action :checkUserSignedIn
  before_action :set_item
  before_action :set_card

  require 'payjp'

  def index
    @item_image = @item.item_images[0]

    if @card.blank?
      redirect_to new_card_path
    else
      Payjp.api_key = Rails.application.credentials[:payjp][:PAYJP_ACCESS_KEY]
      customer = Payjp::Customer.retrieve(@card.customer_id)
      @card_information = customer.cards.retrieve(@card.card_id)
      @month_year = @card_information.exp_month.to_s + " / " + @card_information.exp_year.to_s[1,2]

      @card_brand = @card_information.brand
      case @card_brand
      when "Visa"
        @card_src = "visa.svg"
      when "JCB"
        @card_src = "jcb.svg"
      when "MasterCard"
        @card_src = "master-card.svg"
      when "American Express"
        @card_src = "american_express.svg"
      when "Diners Club"
        @card_src = "dinersclub.svg"
      when "Discover"
        @card_src = "discover.svg"
      end
      
    end
  end

  def create
    Payjp.api_key = Rails.application.credentials[:payjp][:PAYJP_ACCESS_KEY]
    card_charge = Payjp::Charge.create(
                  amount: @item.price,
                  customer: @card.customer_id,
                  currency: 'jpy',
                  )
    # TODO: 処理が正常に行われたか確認できるようにしています。（最終的に表示方法や有無を決めたい）
    if card_charge.present?
      if @item.update(status: 1, buyer_id: current_user.id)
        flash[:notice] = "決済処理が完了しました"
      else
        flash[:notice] = "決済処理が正常に完了しませんでした"
      end
    end
    redirect_to item_path(@item)
  end

  private

  def set_card
    @card = Card.where(user_id: current_user.id).first
  end
end
