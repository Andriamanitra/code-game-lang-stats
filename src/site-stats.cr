class SiteStats
  include JSON::Serializable

  alias Langname = String

  def initialize(
    @username : String,
    @profile_url : String,
    @solved_by_language : Hash(Langname, Int32),
  )
  end
end
