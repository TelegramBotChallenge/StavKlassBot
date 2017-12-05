class Bot
  require 'telegram/bot'
  require 'httpclient'
  require 'nokogiri'
  require_relative 'utils'

  token = File.read('token.txt')
  request_client = HTTPClient.new

  Telegram::Bot::Client.run(token) do |bot|
    bot.listen do |message|
      case message
        when Telegram::Bot::Types::InlineQuery
          if message.query.empty?
            output = [1].map do |_|
              Telegram::Bot::Types::InlineQueryResultArticle.new(
                  id: '1',
                  title: 'Random',
                  input_message_content: Telegram::Bot::Types::InputTextMessageContent.new(
                      message_text: 'http://stavklass.ru/images/random.jpg?n=' + Random.rand(10...1_512_481_609).to_s)
              )
            end
            bot.api.answer_inline_query(inline_query_id: message.id, results: output)
          else
            results = request_client.get_content(Utils.merge_link('autocomplete', message.query))[2...-2].split('","')
            response = request_client.get_content(Utils.merge_link('search', message.query))
            doc = Nokogiri::HTML(response)
            img_links = doc.css('img').map {|i| i['src']}
            indices = (1..img_links.size).to_a
            out = indices.zip(results, img_links)
            output = out.map do |s|
              Telegram::Bot::Types::InlineQueryResultArticle.new(
                  id: s[0],
                  title: s[1].split.take(5) * ' ',
                  input_message_content: Telegram::Bot::Types::InputTextMessageContent.new(
                      message_text: s[2])
              )
            end
            bot.api.answer_inline_query(inline_query_id: message.id, results: output)
          end
        when Telegram::Bot::Types::Message
          if message.text == '/random' || message.text == '/random@stav_klass_bot'
            bot.api.send_message(chat_id: message.chat.id,
                                 text: 'http://stavklass.ru/images/random.jpg?n=' + Random.rand(10...1_512_481_609).to_s)
          end
      end
    end
  end
end
