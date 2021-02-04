class Workspace
  IGNORE = %w[. .. .git].freeze

  def initialize(pathname)
    @pathname = pathname
  end

  # read the filesystem recursively
  def list_files(dir = @pathname)
    filenames = Dir.entries(@pathname) - IGNORE

    filenames.flat_map do |name|
      path = dir.join(name)

      if File.directory?(path)
        list_files(path)
      else
        path.relative_path_from(@pathname)
      end
    end

  end

  def read_file(path)
    File.read(@pathname.join(path))
  end

  def stat_file(path)
    File.stat(@pathname.join(path))
  end
end
