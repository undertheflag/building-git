require 'fileutils'

class Lockfile
  MissingParent = Class.new(StandardError)
  NoPermission = Class.new(StandardError)
  StaleLock = Class.new(StandardError)

  def initialize(path)
    @file_path = path
    @lock_path = path.sub_ext('.lock')

    @lock = nil
  end

  def hold_for_update
    unless @lock
      # magic here, don't use File.exist? checking
      # two processes may both running File.exist?
      # concurrently, then both go ahead.
      #
      # if File.exist?(@lock_path)
      #   return false
      # else
      #   @lock = File.open(@lock_path)
      #   return true
      # end
      flags = File::RDWR | File::CREAT | File::EXCL
      @lock = File.open(@lock_path, flags)
    end
    true
  rescue Errno::EEXIST
    false
  rescue Errno::ENOENT => error
    raise MissingParent, error.message
  rescue Errno::EACCES => error
    raise NoPermission, error.message
  end

  def write(string)
    raise_on_stale_lock
    @lock.write(string)
  end

  def commit
    raise_on_stale_lock

    @lock.close
    File.rename(@lock_path, @file_path)
    @lock = nil
  end

  private

  def raise_on_stale_lock
    unless @lock
      raise StaleLock, "Not holding lock on file: #{@lock_path}"
    end
  end

end