class CodeWarsStats < SiteStats
  @@url_regex = Regex.new("https?://(www\\.)?codewars\\.com/users/(?<username>\\w+)")
  @@codewars_api_url = "https://www.codewars.com/api/v1/users/%s/code-challenges/completed"
  MAX_PAGES = 20

  private def self.fetch_lang_stats_page(username : String, pagenum : Int32) : HTTP::Client::Response
    url = URI.parse(@@codewars_api_url % username)
    url.query = "page=#{pagenum - 1}" # page is zero-based
    HTTP::Client.get(url)
  end

  def self.fetch_lang_stats(username : String) : Hash(Langname, Int32)?
    stats = Hash(Langname, Int32).new(0)

    (1..MAX_PAGES).each do |pagenum|
      response = fetch_lang_stats_page(username, pagenum)
      return nil unless response.success?

      obj = JSON.parse(response.body)
      obj["data"].as_a.each do |challenge|
        challenge["completedLanguages"].as_a.each do |lang|
          stats[lang.as_s] += 1
        end
      end

      break if pagenum >= obj["totalPages"].as_i
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
