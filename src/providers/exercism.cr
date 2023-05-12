class ExercismStats < SiteStats
  # TODO: get stats from
  # https://exercism.org/api/v2/profiles/$USERNAME/solutions
  @@url_regex = Regex.new("https?://(www[.])?exercism[.]org/profiles/(?<username>\\w+)")

  def self.from_profile_url(profile_url : String) : SiteStats?
    if username = @@url_regex.match(profile_url).try(&.["username"])
      stats = Hash(Langname, Int32).new
      self.new(username, profile_url, stats)
    end
  end
end
