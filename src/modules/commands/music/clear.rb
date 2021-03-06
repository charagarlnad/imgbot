module Bot::DiscordCommands
  module Music
    extend Discordrb::Commands::CommandContainer
    command(:clear, requirements: [:in_voice, :playing], type: :Music, description: 'Clear the music queue.') do |event|
      Bot.masterqueue[event.server.id].clear
      event.voice.stop_playing

      event.send_timed_embed do |e|
        e.description = 'Ok, cleared the queue.'
      end
    end
  end
end
