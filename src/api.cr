require "json"
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


server = HTTP::Server.new do |ctx|
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
end


address = server.bind_tcp 8080
puts "Listening on http://#{address}"
server.listen
