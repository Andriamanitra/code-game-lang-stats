require "json"
require "http/client"
require "http/server"

require "./site-stats"
require "./providers/*"

def stats_from_profile_url(url : String) : SiteStats?
  {% for type in SiteStats.subclasses %}
    if stats = {{type.id}}.from_profile_url(url)
      return stats
    end
  {% end %}
  nil
end

server = HTTP::Server.new([
  HTTP::StaticFileHandler.new("./website", directory_listing: false),
]) do |ctx|
  case ctx.request.path
  when "/"
    ctx.response.redirect("/index.html")
  when "/api"
    if profile_url = ctx.request.query_params["profile_url"]?
      if stats = stats_from_profile_url(profile_url)
        ctx.response.content_type = "application/json"
        stats.to_json(ctx.response)
      else
        ctx.response.respond_with_status 404
      end
    else
      ctx.response.respond_with_status 400
    end
  else
    ctx.response.respond_with_status 404
  end
end

port = 8080
address = server.bind_tcp port
puts "Listening on http://localhost:#{port}"
server.listen
