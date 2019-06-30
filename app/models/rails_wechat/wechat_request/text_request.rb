module RailsWechat::WechatRequest::TextRequest
  
  def response
    res = "#{wechat_config.help}"
    return res unless body.match? Regexp.new(wechat_config.match_values)
    res = wechat_config.text_responses.map do |wr|
      if body.match?(Regexp.new(wr.match_value))
        wr.invoke_effect(self)
      end
    end.compact
    
    "#{wechat_config.help_feedback}#{res.join(', ')}"
  end
  
end
