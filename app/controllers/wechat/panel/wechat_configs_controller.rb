class Wechat::Panel::WechatConfigsController < Wechat::Panel::BaseController
  before_action :set_wechat_config, only: [:show, :edit, :update, :destroy]

  def show
    @wechat_config = current_organ.wechat_config
  end

  def edit
    @wechat_config = current_organ.wechat_config
  end

  def update
    @wechat_config.assign_attributes(wechat_config_params)

    respond_to do |format|
      if @wechat_config.save
        format.html.phone
        format.html { redirect_to admin_wechat_configs_url }
        format.js { redirect_back fallback_location: admin_wechat_configs_url }
        format.json { render :show }
      else
        format.html.phone { render :edit }
        format.html { render :edit }
        format.js { redirect_back fallback_location: admin_wechat_configs_url }
        format.json { render :show }
      end
    end
  end

  def destroy
    @wechat_config.destroy
    redirect_to admin_wechat_configs_url
  end

  private
  def set_wechat_config
    @wechat_config = WechatConfig.find(params[:id])
  end

  def wechat_config_params
    params.fetch(:wechat_config, {}).permit(
      :environment,
      :account,
      :enabled,
      :appid,
      :secret,
      :corpid,
      :corpsecret,
      :agentid,
      :encrypt_mode,
      :encoding_aes_key,
      :token,
      :access_token,
      :jsapi_ticket,
      :skip_verify_ssl,
      :timeout,
      :trusted_domain_fullname,
      :created_at
    )
  end

end
