# frozen_string_literal: true

class Wechat::Api::Common < Wechat::Api::Base
  WXA_BASE = 'https://api.weixin.qq.com/wxa/'
  API_BASE = 'https://api.weixin.qq.com/cgi-bin/'
  OAUTH2_BASE = 'https://api.weixin.qq.com/sns/'
  DATACUBE_BASE = 'https://api.weixin.qq.com/datacube/'
  
  def initialize(app)
    @client = Wechat::HttpClient.new(API_BASE)
    @access_token = Wechat::AccessToken::Public.new(@client, app)
    @jsapi_ticket = Wechat::JsapiTicket::Public.new(@client, app, @access_token)
  end
  
  def groups
    get 'groups/get'
  end
  
  def group_create(group_name)
    post 'groups/create', JSON.generate(group: { name: group_name })
  end
  
  def group_update(groupid, new_group_name)
    post 'groups/update', JSON.generate(group: { id: groupid, name: new_group_name })
  end
  
  def group_delete(groupid)
    post 'groups/delete', JSON.generate(group: { id: groupid })
  end
  
  def users(nextid = nil)
    params = { params: { next_openid: nextid } } if nextid.present?
    get('user/get', params || {})
  end
  
  def user(openid)
    get 'user/info', params: { openid: openid }
  end
  
  def user_batchget(openids, lang = 'zh-CN')
    post 'user/info/batchget', JSON.generate(user_list: openids.collect { |v| { openid: v, lang: lang } })
  end
  
  def user_group(openid)
    post 'groups/getid', JSON.generate(openid: openid)
  end
  
  def user_change_group(openid, to_groupid)
    post 'groups/members/update', JSON.generate(openid: openid, to_groupid: to_groupid)
  end
  
  def user_update_remark(openid, remark)
    post 'user/info/updateremark', JSON.generate(openid: openid, remark: remark)
  end
  
  def qrcode_create_scene(scene_id_or_str, expire_seconds = 2592000)
    case scene_id_or_str
    when 0.class
      post 'qrcode/create', JSON.generate(expire_seconds: expire_seconds,
                                          action_name: 'QR_SCENE',
                                          action_info: { scene: { scene_id: scene_id_or_str } })
    else
      post 'qrcode/create', JSON.generate(expire_seconds: expire_seconds,
                                          action_name: 'QR_STR_SCENE',
                                          action_info: { scene: { scene_str: scene_id_or_str } })
    end
  end
  
  def qrcode_create_limit_scene(scene_id_or_str)
    case scene_id_or_str
    when 0.class
      post 'qrcode/create', JSON.generate(action_name: 'QR_LIMIT_SCENE',
                                          action_info: { scene: { scene_id: scene_id_or_str } })
    else
      post 'qrcode/create', JSON.generate(action_name: 'QR_LIMIT_STR_SCENE',
                                          action_info: { scene: { scene_str: scene_id_or_str } })
    end
  end
  
  def shorturl(long_url)
    post 'shorturl', { action: 'long2short', long_url: long_url }.to_json
  end
  
  def message_mass_sendall(message, tag_id)
    message = { content: message } if message.is_a? String
    
    push = Wechat::Message::Push::Public.new(message)
    push.to_mass(tag_id)
    
    post 'message/mass/sendall', push.to_json
  end
  
  def message_mass_send(message, *openid)
    message = { content: message } if message.is_a? String
  
    push = Wechat::Message::Push::Public.new(message)
    push.to(openid)
    
    post 'message/mass/send', push.to_json
  end
  
  def message_mass_delete(msg_id)
    post 'message/mass/delete', { msg_id: msg_id }.to_json
  end
  
  def message_mass_preview(message)
    post 'message/mass/preview', message.to_json
  end
  
  def message_mass_get(msg_id)
    post 'message/mass/get', { msg_id: msg_id }.to_json
  end
  
  def wxa_get_wxacode(path, width = 430)
    post 'getwxacode', JSON.generate(path: path, width: width), base: WXA_BASE
  end
  
  def wxa_create_qrcode(path, width = 430)
    post 'wxaapp/createwxaqrcode', JSON.generate(path: path, width: width)
  end
  
  def menu
    get 'menu/get'
  end
  
  def menu_delete
    get 'menu/delete'
  end
  
  def menu_create(menu)
    # 微信不接受7bit escaped json(eg \uxxxx), 中文必须UTF-8编码, 这可能是个安全漏洞
    post 'menu/create', menu.to_json
  end
  
  def menu_addconditional(menu)
    # Wechat not accept 7bit escaped json(eg \uxxxx), must using UTF-8, possible security vulnerability?
    post 'menu/addconditional', menu.to_json
  end
  
  def menu_trymatch(user_id)
    post 'menu/trymatch', { user_id: user_id }.to_json
  end
  
  def menu_delconditional(menuid)
    post 'menu/delconditional', JSON.generate(menuid: menuid)
  end
  
  def material(media_id)
    get 'material/get', params: { media_id: media_id }, as: :file
  end
  
  def material_count
    get 'material/get_materialcount'
  end
  
  def material_list(type = 'news', offset = 0, count = 20)
    post 'material/batchget_material', { type: type, offset: offset, count: count }.to_json
  end
  
  def material_add(type, file)
    post_file 'material/add_material', file, params: { type: type }
  end
  
  def material_delete(media_id)
    post 'material/del_material', JSON.generate(media_id: media_id)
  end
  
  def custom_message_send(message)
    post 'message/custom/send', message.is_a?(Wechat::Message) ? message.to_json : JSON.generate(message), content_type: :json
  end
  
  def customservice_getonlinekflist
    get 'customservice/getonlinekflist'
  end
  
  def tags
    get 'tags/get'
  end
  
  def tag_create(tag_name, tag_id = nil)
    if tag_id.present?
      r = post 'tags/update', { tag: { id: tag_id, name: tag_name } }.to_json
      if r['errcode'] == 0
        { 'tag' => { 'id' => tag_id, 'name' => tag_name } }
      else
        r
      end
    else
      post 'tags/create', { tag: { name: tag_name } }.to_json
    end
  rescue Wechat::ResponseError => e
    if e.error_code == 45157
      { 'tag' => tags['tags'].find { |i| i['name'] == tag_name } }
    end
  end
  
  def tag_delete(tagid)
    post 'tags/delete', { tag: { id: tagid } }.to_json
  end
  
  def tag_add_user(tagid, *openids)
    post 'tags/members/batchtagging', { openid_list: openids, tagid: tagid }.to_json
  end
  
  def tag_del_user(tagid, *openids)
    post 'tags/members/batchuntagging', { openid_list: openids, tagid: tagid }.to_json
  end
  
  def tag(tagid, next_openid = '')
    post 'user/tag/get', { tagid: tagid, next_openid: next_openid }.to_json
  end
  
  def getusersummary(begin_date, end_date)
    post 'getusersummary', JSON.generate(begin_date: begin_date, end_date: end_date), base: DATACUBE_BASE
  end
  
  def getusercumulate(begin_date, end_date)
    post 'getusercumulate', JSON.generate(begin_date: begin_date, end_date: end_date), base: DATACUBE_BASE
  end
  
  def web_access_token(code)
    params = {
      appid: access_token.appid,
      secret: access_token.secret,
      code: code,
      grant_type: 'authorization_code'
    }
    client.get 'oauth2/access_token', params: params, base: OAUTH2_BASE
  end
  
  def web_auth_access_token(web_access_token, openid)
    client.get 'auth', params: { access_token: web_access_token, openid: openid }, base: OAUTH2_BASE
  end
  
  def web_refresh_access_token(user_refresh_token)
    params = {
      appid: access_token.appid,
      grant_type: 'refresh_token',
      refresh_token: user_refresh_token
    }
    client.get 'oauth2/refresh_token', params: params, base: OAUTH2_BASE
  end
  
  def web_userinfo(web_access_token, openid, lang = 'zh_CN')
    client.get 'userinfo', params: { access_token: web_access_token, openid: openid, lang: lang }, base: OAUTH2_BASE
  end

end
