class LineController < ApplicationController

	def callback
		# リクエストの内容を取得
	  body = request.body.read

	  # LINEからのリクエストが正しいかどうかの確認
	  signature = request.env['HTTP_X_LINE_SIGNATURE']
	  unless client.validate_signature(body, signature)
	    error 400 do 'Bad Request' end
	  end

	  events = client.parse_events_from(body)
	  events.each { |event|
	    case event
	    when Line::Bot::Event::Message
	      case event.type
	      when Line::Bot::Event::MessageType::Text
	        message = {
	          type: 'text',
	          text: event.message['text']
	        }
	        client.reply_message(event['replyToken'], message)
	    end
	  }
	end

private
	def client
	  @client ||= Line::Bot::Client.new { |config|
	    config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
	    config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
	  }
	end
end
