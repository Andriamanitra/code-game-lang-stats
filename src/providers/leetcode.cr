class LeetcodeStats < SiteStats
  @@url_regex = Regex.new("https?://(www[.])?leetcode[.]com/(u/)?(?<username>\\w+)")
  @@leetcode_api_url = "https://leetcode.com/graphql/"
  @@headers = HTTP::Headers{"Content-Type" => "application/json"}

  def self.fetch_lang_stats(username : String) : Hash(Langname, Int32)?
    stats = Hash(Langname, Int32).new(0)

    body = {
      "query": <<-GRAPHQL,
        query languageStats($username: String!) {
          matchedUser(username: $username) {
            languageProblemCount {
              languageName
              problemsSolved
            }
          }
        }
      GRAPHQL
      "variables":     {"username": username},
      "operationName": "languageStats",
    }
    response = HTTP::Client.post(@@leetcode_api_url, @@headers, body.to_json)
    return nil unless response.success?

    obj = JSON.parse(response.body).dig?("data", "matchedUser", "languageProblemCount")
    return nil if obj.nil?

    obj.as_a.each do |lang|
      lang_name = lang["languageName"].as_s
      solved_count = lang["problemsSolved"].as_i
      stats[lang_name] += solved_count
    end

    stats
  end

  def self.from_profile_url(profile_url : String) : SiteStats?
    if username = @@url_regex.match(profile_url).try(&.["username"])
      stats = self.fetch_lang_stats(username)
      return nil if stats.nil?
      self.new(username, profile_url, stats)
    end
  end
end
