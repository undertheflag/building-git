require 'fileutils'
require 'pathname'
require '../bin/workspace'
require '../bin/blob'
require '../bin/database'
require '../bin/entry'
require '../bin/tree'

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
  entries = workspace.list_files.map do |path|
    data = workspace.read_file(path)
    blob = Blob.new(data)

    database.store(blob)

    Entry.new(path, blob.oid)
  end

  tree = Tree.new(entries)
  database.store(tree)

  puts "tree: #{tree.oid}"
else
  warn "jit: '#{command}' is not a jit command"
end
