# frozen_string_literal: true

require 'fileutils'
require 'pathname'
require '../bin/Workspace'
require '../bin/Database'
require '../bin/Blob'

command = ARGV.shift

case command
when 'init'
  path = ARGV.fetch(0, Dir.getwd)

  root_path = Pathname.new(File.expand_path(path))
  git_path = root_path.join('.git')

  %w[objects refs].each do |dir|
    begin
      FileUtils.mkdir_p(git_path.join(dir))
    rescue StandardError => e
      warn "fatal: #{e.message}"
      exit 1
    end
  end

  puts "Initialized empty Jit repository in #{git_path}"
  exit 0

when 'commit'
  root_path = Pathname.new(Dir.getwd)
  git_path = root_path.join('.git')
  db_path = git_path.join('objects')

  workspace = Workspace.new(root_path)
  database = Database.new(db_path)
  workspace.list_files.each do |path|
    data = workspace.read_file(path)
    blob = Blob.new(data)

    database.store(blob)
  end
else
  warn "jit: '#{command}' is not a jit command"
end
