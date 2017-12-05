class Utils
  def self.merge_link(type, tail)
    case type
    when 'autocomplete'
      "http://stavklass.ru/images/autocomplete.json?term=#{CGI.escape(tail)}"
    when 'search'
      "http://stavklass.ru/images/search?utf8=%E2%9C%93&image%5Btext%5D=#{CGI.escape(tail)}"
    end
  end
end
