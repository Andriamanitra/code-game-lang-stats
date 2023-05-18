class AtCoderStats < SiteStats
  @@url_regex = Regex.new("https?://(www[.])?atcoder.jp/users/(?<username>\\w+)")
  # https://github.com/kenkoooo/AtCoderProblems/blob/master/doc/api.md
  @@kenko_api_url = "https://kenkoooo.com/atcoder/atcoder-api/v3/user/language_rank?user="

  def self.fetch_lang_stats(username : String) : Hash(Langname, Int32)?
    stats = Hash(Langname, Int32).new(0)

    response = HTTP::Client.get(@@kenko_api_url + username)
    return nil unless response.success?

    obj = JSON.parse(response.body)
    return nil if obj.nil?

    obj.as_a.each do |item|
      language = item["language"].as_s
      count = item["count"].as_i
      stats[language] = count
    end

    stats
  end

  def self.from_profile_url(profile_url : String) : SiteStats?
    if username = @@url_regex.match(profile_url).try(&.["username"])
      stats = fetch_lang_stats(username)
      return nil if stats.nil?
      self.new(username, profile_url, stats)
    end
  end
end
