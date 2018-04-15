module Bot::DiscordCommands
  module Games
    extend Discordrb::Commands::CommandContainer
    butt = MediaWiki::Butt.new('http://ftb.gamepedia.com/api.php', query_limit_default: 5000, use_continuation: true)
    embed = lambda do |searchresults, pagenum, event|
      search = searchresults[pagenum]
      stats = butt.get_statistics
      Discordrb::Webhooks::Embed.new title: search,
      # Reimplment description with https://github.com/nricciar/wikicloth/
      description: Nokogiri::HTML(open("https://ftb.gamepedia.com/#{search.gsub(' ', '_')}")).search('p').inner_text[0..2047],
      footer: Discordrb::Webhooks::EmbedFooter.new(text: "Pages: #{stats['pages'].to_s} | Articles: #{stats['articles'].to_s} | Edits: #{stats['edits'].to_s} | Images: #{stats['images'].to_s} | Users: #{stats['users'].to_s} | Active users: #{stats['activeusers'].to_s}"),
      thumbnail: Discordrb::Webhooks::EmbedThumbnail.new(url: event.bot.profile.avatar_url),
      url: "https://ftb.gamepedia.com/#{search.gsub(' ', '_')}",
      color: $normalcolor
    end

    command(:ftbwiki, type: :Games, description: 'Search FTB Wiki for [**X**].') do |event, *user_search|
      searchresults = butt.get_prefix_search(user_search.join(' '))
      pagenum = 0

      if searchresults[pagenum] == nil
        event.respond 'No search results found.'
        break
      end

      emb = event.channel.send_embed('Page 1:', embed.call(searchresults, pagenum, event))

      event.bot.add_await(:"leftarrow#{emb.id}", Discordrb::Events::ReactionAddEvent, emoji: $rightarrow, from: event.author, message: emb) do
        emb.delete_reaction(event.author, $rightarrow)
        if pagenum + 1 <= searchresults.size
          pagenum += 1
          emb.edit("Page #{pagenum + 1}:", embed.call(searchresults, pagenum, event))
        else
          emb.edit('You have hit the end of the search.', embed.call(searchresults, pagenum, event))
        end
        false
      end

      event.bot.add_await(:"rightarrow#{emb.id}", Discordrb::Events::ReactionAddEvent, emoji: $leftarrow, from: event.author, message: emb) do
        emb.delete_reaction(event.author, $leftarrow)
        if pagenum > 0
          pagenum -= 1
          emb.edit("Page #{pagenum + 1}:", embed.call(searchresults, pagenum, event))
        else
          emb.edit('You have hit the beginning of the search.', embed.call(searchresults, pagenum, event))
        end
        false
      end

      event.bot.add_await(:"trashcan#{emb.id}", Discordrb::Events::ReactionAddEvent, emoji: $trashcan, from: event.author, message: emb) do
        event.bot.awaits.except!(:"leftarrow#{emb.id}", :"rightarrow#{emb.id}", :"trashcan#{emb.id}")
        emb.delete
      end

      emb.react($leftarrow)
      emb.react($rightarrow)
      emb.react($trashcan)

      nil
    end
  end
end
