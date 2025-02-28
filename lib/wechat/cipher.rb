# frozen_string_literal: true

require 'openssl/cipher'
require 'base64'

module Wechat
  module Cipher
    BLOCK_SIZE = 32
    CIPHER = 'AES-256-CBC'
    extend self
    
    def encrypt(plain, encoding_aes_key)
      cipher = OpenSSL::Cipher.new(CIPHER)
      cipher.encrypt

      cipher.padding = 0
      key_data = Base64.decode64(encoding_aes_key + '=')
      cipher.key = key_data
      cipher.iv = [key_data].pack('H*')

      cipher.update(plain) + cipher.final
    end

    def decrypt(msg, encoding_aes_key)
      cipher = OpenSSL::Cipher.new(CIPHER)
      cipher.decrypt

      cipher.padding = 0
      key_data = Base64.decode64(encoding_aes_key + '=')
      cipher.key = key_data
      cipher.iv = [key_data].pack('H*')

      plain = cipher.update(msg) + cipher.final
      decode_padding(plain)
    end

    def program_decrypt(encrypted_data, session_key, iv)
      cipher = OpenSSL::Cipher.new('AES-128-CBC')
      cipher.decrypt
  
      cipher.key = Base64.decode64(session_key)
      cipher.iv = Base64.decode64(iv)
      decrypted_data = Base64.decode64(encrypted_data)
      JSON.parse(cipher.update(decrypted_data) + cipher.final)
    rescue Exception => e
      { errcode: 41003, errmsg: e.message }
    end

    def pack(content, app_id)
      random = SecureRandom.hex(8)
      text = content.force_encoding('ASCII-8BIT')
      msg_len = [text.length].pack('N')

      encode_padding("#{random}#{msg_len}#{text}#{app_id}")
    end

    def unpack(msg)
      msg = decode_padding(msg)
      msg_len = msg[16, 4].reverse.unpack('V')[0]
      content = msg[20, msg_len]
      app_id = msg[(20 + msg_len)..-1]

      [content, app_id]
    end

    private
    def encode_padding(data)
      length = data.bytes.length
      amount_to_pad = BLOCK_SIZE - (length % BLOCK_SIZE)
      amount_to_pad = BLOCK_SIZE if amount_to_pad == 0
      padding = ([amount_to_pad].pack('c') * amount_to_pad)
      data + padding
    end

    def decode_padding(plain)
      pad = plain.bytes[-1]
      # no padding
      pad = 0 if pad < 1 || pad > BLOCK_SIZE
      plain[0...(plain.length - pad)]
    end
    
  end
end
