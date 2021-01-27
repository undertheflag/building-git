class Workspace
  IGNORE = %w[. .. .git].freeze

  def initialize(pathname)
    @pathname = pathname
  end

  def list_files
    Dir.entries(@pathname) - IGNORE
  end
end
