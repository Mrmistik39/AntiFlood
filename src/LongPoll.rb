require './Info'
require './Utils/Utils'
require 'json'
require './Utils/Api'
require './Utils/Config'

class LongPoll

  def initialize
    super
    @ts
    @printing = {}
  end

  def run
    self.get_session
    self.update
    vald = Thread.new{
      while true
        sleep(0.5)
        @printing.each do |data|
          if Time.now.to_i - @printing[data]['time'] >= 10
            @printing.delete(data)
            puts @printing
          end
        end
      end
    }
    self.tick
  end

  def get_session
    pk = "https://api.vk.com/method/messages.getLongPollServer?access_token=#{Info::TOKEN}&lp_version=3&need_pts=1&v=#{Info::VERSION}"
    pk = Utils.curl_get(pk)
    @ts = JSON.parse(pk)
  end

  def update
    pk = "https://#{@ts['response']['server']}?act=a_check&key=#{@ts['response']['key']}&wait=25&ts=#{@ts['response']['ts']}"
    pk = JSON.parse(Utils.curl_get(pk))
    if pk.count == 0
      self.get_session
    else
      pk
    end
  end

  def var_dump(var)
    i = 0
    text = "{\n"
    var.each do |key, value|
      text += "   [#{key}]\n"
    end
    text += '}'
    puts text
  end

  def tick
    while true
      pk = self.update
      @ts["response"]["ts"] = pk["ts"]
      pk['updates'].each { |data|
        if data[0] == 4 # message_new
          peer_id = data[3]
          message_id = data[1]
          if data[6] == ''
            message = ''
          else
            message = data[6]
            if peer_id > 2000000000
              user_id = data[6]['from'];
            else
              user_id = data[3];
            end
            args = message.split(' ')
	    puts args[0]
            if args[0] == '..test'
                Api::send_message(peer_id, 'antiprint - on')
	   end
            if user_id == 427122186
              config = Config.new("./config/#{peer_id}.json")
              if args[0] == 'add_event'
                if args[1] == 'printing'
                  config.set('printing', args[2])
                  config.save
                  Api::send_message(peer_id, "Теперь при печатание текста больше #{args[2]} сек, будет вызвано действие кик")
                else
                  Api::send_message(peer_id, 'Событие не найдено')
                end
              end
              if message == 'peer_id'
                Api::send_message(peer_id, peer_id) # Time.now.to_i
              end
            end
          end
        elsif data[0] == 62 and data[2] == 59 # state_print_text
          peer_id = 2000000000 + data[2]
          if @printing[data[1]].nil?
            @printing[data[1]] = {
                :time => Time.now.to_i,
                :warn => 0,
                :global_warn => 0
            }
          else
              @printing[data[1]]['time'] = Time.now.to_i
              @printing[data[1]][:warn] += 1
              if @printing[data[1]][:warn] >= 5
                @printing[data[1]][:global_warn] += 1
                Api::send_message(peer_id, "[id#{data[1]}|Пользователь] получил [#{@printing[data[1]][:global_warn]}/3] предупреждений за долгое печатание текста")
                if @printing[data[1]][:global_warn] >= 3
                  @printing.delete(data[1])#Кик по причине Подозрительная активность
		  Api::send_message(peer_id, "!ban #{data[1]} 30 m")
                ends
            end
            puts @printing
          end
        end
      }
    end
  end

end

start = LongPoll.new
start.run
