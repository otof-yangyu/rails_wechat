module Wechat::Message
  class Push::Work < Push
    # see: https://work.weixin.qq.com/api/doc#90000/90135/90236/消息类型
    MSG_TYPE = [
      'text', 'markdown',  # content
      'voice', 'image', 'file',  # media_id
      'video',  # media_id, title*, description*
      'textcard',  # title, description, url, btntxt*
      'news',  # articles[], title, url, description*, picurl*
      'mpnews', # articles[], title, thumb_media_id, content, author*, content_source_url*, digest*
      'miniprogram_notice',
      'taskcard'
    ].freeze
  
    def restore
      case msgtype
      when 'news', 'mpnews'
        @message_hash[msgtype] = { articles: @message_hash.delete('articles') }
      end
      
      super
    end

    def to(*user)
      update(touser: user.join('|'))
    end

    def to_all
      update(touser: '@all')
    end
    
    def to_party(*party)
      update(toparty: party.join('|'))
    end
    
    def to_tag(*tag)
      update(totag: tag.join('|'))
    end

    def agent_id(agentid)
      update(AgentId: agentid)
    end

    def textcard(title, description, url, btntxt = nil)
      data = {
        title: title,
        description: description,
        url: url
      }
      data[:btntxt] = btntxt if btntxt.present?
      update(MsgType: 'textcard', TextCard: data)
    end

    def markdown(content)
      update(MsgType: 'markdown', Markdown: {
        content: content
      })
    end

    def ref_mpnews(media_id)
      update(MsgType: 'ref_mpnews', MpNews: { MediaId: media_id })
    end

    def mpnews(collection, &_block)
      if block_given?
        article = MpNewsArticleBuilder.new
        collection.take(8).each_with_index { |item, index| yield(article, item, index) }
        items = article.items
      else
        items = collection.collect do |item|
          camelize_hash_keys(item.symbolize_keys.slice(:thumb_media_id, :title, :content, :author, :content_source_url, :digest, :show_cover_pic).reject { |_k, v| v.nil? })
        end
      end
  
      update(MsgType: 'mpnews', Articles: items.collect { |item| camelize_hash_keys(item) })
    end

    def file(media_id)
      update(MsgType: 'file', File: { MediaId: media_id })
    end


  end
end
