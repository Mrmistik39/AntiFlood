require './Info'
require './Utils/Utils'

class Api

  def self.send_message(peer_id, message)
    data = "https://api.vk.com/method/messages.send?v=#{Info::VERSION}&peer_id=#{peer_id}&message=#{message}&access_token=#{Info::TOKEN}&random_id=0"
    Utils.curl_get(data)
  end

  def self.kick(user_id, chat_id)
    data = "https://api.vk.com/method/messages.removeChatUser?chat_id=#{chat_id}&member_id=#{user_id}&access_token=#{Info::TOKEN}&v=#{Info::VERSION}"
    Utils.curl_get(data)
  end

end
