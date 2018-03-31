module Bot::DiscordCommands
  module Music
    extend Discordrb::Commands::CommandContainer
    command :clear do |event|
      event.respond 'I am not in voice.' if event.voice == nil
      next if event.voice == nil

      @masterqueue[event.server.id].clear
      event.voice.stop_playing

      emb = event.channel.send_embed() do |e|
        e.description = "Ok, cleared the queue."
        e.color = 0x7289DA
      end

      Thread.new do
        sleep(8) 
        emb.delete
      end

      nil
    end
  end
end
