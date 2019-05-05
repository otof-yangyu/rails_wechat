class Wechat::WechatsController < ApplicationController
  wechat_responder account_from_message: Proc.new{ |request| request.params[:id] }
  before_action :set_wechat_config, only: [:create]
  
  on :text do |message, content|
    set_wechat_user(message)
    
    if @wechat_user.user.nil?
      msg = '你没有权限！'
    elsif @wechat_user.user.disabled?
      msg = 'meiyouquanxian'
    elsif content.match? Regexp.new(@wechat_config.regexps)
      res = []
      @wechat_config.wechat_responses.each do |wr|
        if content.match? Regexp.new(wr.regexp)
          r = @wechat_user.wechat_feedbacks.create(wechat_config_id: @wechat_config.id, body: content, kind: wr.regexp)
          #res << "#{wr.regexp}：#{r.number_str}"
          res << wr.response
        end
      end
      
      msg = "工作计划提交成功，你的票号为： #{res.join(', ')}"
    else
      msg = @wechat_config.help
    end
    
    message.reply.text msg
  end
  
  on :text, with: '注册' do |message, content|
    @wechat_user = set_wechat_user(message)
    result_msg = [
      {
        title: '请注册',
        description: '注册信息',
        url: join_url(uid: @wechat_user.uid)
      }
    ]
  
    message.reply.news result_msg
  end

  on :event, with: 'subscribe' do |message, content|
    result_msg = [{
      title: '欢迎关注',
      description: '查看数据'
    }]

    if message[:EventKey] == 'qrscene_1'
      message.reply.text '签到成功'
    else
      message.reply.news(result_msg)
    end
  end

  on :event, with: 'scan' do |message|
    if message[:EventKey] == '1'
      message.reply.text '签到成功'
    end
  end

  on :click, with: 'join' do |message, key|
    @wechat_user = set_wechat_user(message)
  
    result_msg = [
      {
        title: '请注册',
        description: '注册信息',
        url: join_url(uid: @wechat_user.uid)
      }
    ]
    
    message.reply.news result_msg
  end
  
  private
  def set_wechat_config
    @wechat_config = WechatConfig.find_by account: params[:id]
  end
  
  def set_wechat_user(message)
    @wechat_user = WechatUser.find_or_initialize_by(uid: message[:FromUserName])
    @wechat_user.app_id = @wechat_config.appid
    @wechat_user.save
    @wechat_user
  end
  
end
