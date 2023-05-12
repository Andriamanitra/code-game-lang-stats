class ExercismStats < SiteStats
  @@url_regex = Regex.new("https?://(www[.])?exercism[.]org/profiles/(?<username>\\w+)")
  @@exercism_api_url = "https://exercism.org/api/v2/profiles/%s/solutions"
  MAX_PAGES = 50

  private def self.fetch_solutions_page(username : String, pagenum : Int32) : HTTP::Client::Response
    url = URI.parse(@@exercism_api_url % username)
    url.query = "page=#{pagenum}"
    HTTP::Client.get(url)
  end

  def self.fetch_lang_stats(username : String) : Hash(Langname, Int32)?
    stats = Hash(Langname, Int32).new(0)

    (1..MAX_PAGES).each do |pagenum|
      response = fetch_solutions_page(username, pagenum)
      return nil unless response.success?

      obj = JSON.parse(response.body)
      obj["results"].as_a.each do |solution|
        if solution["published_iteration_head_tests_status"] == "passed"
          lang = solution["language"].as_s
          stats[lang] += 1
        end
      end

      break if pagenum >= obj.dig("meta", "total_pages").as_i
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
