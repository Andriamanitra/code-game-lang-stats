class CodeGolfStats < SiteStats
  # stats come from massive (~15M) json available at
  # https://code.golf/scores/all-holes/all-langs/all
  @@url_regex = Regex.new("https?://code[.]golf/golfers/(?<username>[\\w\\-]+)")
  alias Username = String
  @@cached_lang_stats = Hash(Username, Hash(Langname, Int32)).new do |h, k|
    h[k] = Hash(Langname, Int32).new(0)
  end

  # TODO: this needs to be periodically updated
  read_stats_from_json("code-golf-sols.json")

  def self.read_stats_from_json(fname : String)
    File.open(fname) do |f|
      stats = JSON.parse(f).as_a
      stats.each do |sol|
        if sol["scoring"]? == "chars"
          username = sol["login"].as_s
          lang = sol["lang"].as_s
          @@cached_lang_stats[username.downcase][lang] += 1
        end
      end
    end
  end

  def self.from_profile_url(profile_url : String) : SiteStats?
    if username = @@url_regex.match(profile_url).try(&.["username"])
      stats = @@cached_lang_stats.fetch(username.downcase, nil)
      return nil if stats.nil?
      self.new(username, profile_url, stats)
    end
  end
end
