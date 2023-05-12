class CodingameStats < SiteStats
  # TODO: get stats from (request body should be [$USER_ID])
  # https://www.codingame.com/services/Puzzle/countSolvedPuzzlesByProgrammingLanguage
  @@url_regex = Regex.new("https?://(www[.])?codingame[.]com/profile/(?<uid>[a-f0-9]+)")

  def self.from_profile_url(profile_url : String) : SiteStats?
    if public_id = @@url_regex.match(profile_url).try(&.["uid"])
      stats = Hash(Langname, Int32).new
      self.new("codingamer", profile_url, stats)
    end
  end
end
