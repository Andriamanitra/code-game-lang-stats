class CodingameStats < SiteStats
  record CodinGamer, user_id : Int32, pseudo : String

  @@url_regex = Regex.new("https?://(www[.])?codingame[.]com/profile/(?<uid>[a-f0-9]+)")
  @@codingame_api_url = "https://www.codingame.com/services/Puzzle/countSolvedPuzzlesByProgrammingLanguage"
  @@headers = HTTP::Headers{"Content-Type" => "application/json;charset=UTF-8"}
  @@codingamer_cache = Hash(String, CodinGamer).new

  private def self.codingamer_from_public_handle(public_handle : String) : CodinGamer?
    if codingamer = @@codingamer_cache[public_handle]?
      return codingamer
    end

    url = "https://www.codingame.com/services/CodinGamer/findCodingamePointsStatsByHandle"
    body = "[\"#{public_handle}\"]"
    response = HTTP::Client.post(url, @@headers, body)
    return nil unless response.success?

    obj = JSON.parse(response.body).as_h?
    return nil if obj.nil?

    user_id = obj.dig("codingamer", "userId").as_i
    pseudo = obj.dig("codingamer", "pseudo").as_s
    @@codingamer_cache[public_handle] = CodinGamer.new(user_id, pseudo)
  end

  def self.from_profile_url(profile_url : String) : SiteStats?
    if public_handle = @@url_regex.match(profile_url).try(&.["uid"])
      codingamer = codingamer_from_public_handle(public_handle)
      return nil unless codingamer

      stats = Hash(Langname, Int32).new

      body = "[#{codingamer.user_id}]"
      response = HTTP::Client.post(@@codingame_api_url, @@headers, body)
      return nil unless response.success?

      obj = JSON.parse(response.body)
      obj.as_a.each do |lang_obj|
        lang_obj = lang_obj.as_h
        lang = lang_obj["programmingLanguageId"].as_s
        solved_count = lang_obj["puzzleCount"].as_i
        stats[lang] = solved_count
      end

      profile_url = profile_url.sub("www.codingame.com", "codingame.com")
      self.new(codingamer.pseudo, profile_url, stats)
    end
  end
end
