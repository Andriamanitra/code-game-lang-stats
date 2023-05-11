class CodeWarsStats < SiteStats
  # TODO: get stats from
  # https://www.codewars.com/api/v1/users/$USERNAME/code-challenges/completed
  @@url_regex = Regex.new("https?://(www\.)?codewars.com/users/(?<username>\\w+)")

  def self.from_profile_url(profile_url : String) : SiteStats?
    if username = @@url_regex.match(profile_url).try(&.["username"])
      stats = Hash(Langname, Int32).new
      self.new(username, profile_url, stats)
    end
  end
end
