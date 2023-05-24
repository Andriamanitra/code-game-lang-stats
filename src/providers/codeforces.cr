class Codeforces < SiteStats
  @@url_regex = Regex.new("https?://codeforces[.]com/profile/(?<username>\\w+)")
  # https://codeforces.com/apiHelp
  @@api_url = "https://codeforces.com/api/user.status?handle=%s&from=1&count=10000"

  def self.fetch_lang_stats(username : String) : Hash(Langname, Int32)?
    stats = Hash(Langname, Int32).new(0)

    url = URI.parse(@@api_url % username)
    response = HTTP::Client.get(url)
    return nil unless response.success?

    obj = JSON.parse(response.body)
    return nil if obj.nil? || obj["status"] != "OK"

    obj["result"].as_a.each do |item|
      next if item["verdict"] != "OK"

      language = item["programmingLanguage"].as_s
      # Removes espaces for the JSON to work later on:
      #     PyPy 3-64 -> PyPy-3-64
      language = language.gsub(/ /, "-")
      stats[language] += 1
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
