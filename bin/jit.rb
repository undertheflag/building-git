# frozen_string_literal: true

require 'fileutils'
require 'pathname'

command = ARGV.shift

case command
when 'init'
  path = ARGV.fetch(0, Dir.getwd)

  root_path = Pathname.new(File.expand_path(path))
  git_path = root_path.join('.git')

  %w[objects refs].each do |dir|
    begin
      FileUtils.mkdir_p(git_path.join(dir))
    rescue Error => e
      warn "fatal: #{e.message}"
      exit 1
    end
  end

  puts "Initialized empty Jit repository in #{git_path}"
  exit 0
else
  warn "jit: '#{command}' is not a jit command"
end
