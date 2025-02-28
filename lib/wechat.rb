# frozen_string_literal: true

require 'wechat/api'
require 'wechat/helpers'
require 'wechat/errors'

module Wechat
  autoload :Message, 'wechat/message'
  autoload :Responder, 'wechat/responder'
  autoload :Cipher, 'wechat/cipher'
  autoload :ControllerApi, 'wechat/controller_api'
  
  def self.config(id = nil)
    if id
      r = WechatApp.valid.find(id)
    else
      r = WechatApp.default
    end
    return r if r
    
    raise AppNotFound, 'Can not find wechat config'
  end

  def self.api(id = nil)
    app = config(id)
    app_api(app)
  end
  
  def self.app_api(app)
    case app.type
    when 'WechatPublic', 'WechatRead'
      Wechat::Api::Public.new(app)
    when 'WechatProgram'
      Wechat::Api::Program.new(app)
    when 'WechatWork'
      Wechat::Api::Work.new(app)
    else
      raise 'Account is missing'
    end
  end
  
end


