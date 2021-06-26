require 'json'

class Config

  def initialize(file)
    @file = file
    if File.exist?(file)
      @json = JSON.parse(
          File.open(file, 'r').read
      )
    else
      @json = {}
    end
  end

  def set(get, set)
    @json[get] = set
  end

  def get_all
    @json
  end

  def get_plus(get_s, get_p)
    @json[get_s] = @json[get_s].to_i + get_p
  end

  def get(get_)
    @json[get_]
  end

  def save
    file = File.open(@file, 'w+')
    file.write(JSON.dump(@json))
    file.close
  end

end
