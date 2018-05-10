#!/usr/bin/env ruby

require 'rubygems'
require 'rubygems/package'

class Archiver
  def initialize(src_path, dest_path)
    @src_path = src_path
    @dest_path = dest_path

    raise ArgumentError, "File src_path '#{src_path}' - no such directory" unless File.directory?(src_path)
    raise ArgumentError, "File dest_path '#{dest_path}' - no such directory" unless File.directory?(dest_path)
  end

  def run
    archive_path = File.join(dest_path, archive_filename)
    archive_file = File.open(archive_path, 'wb')
    tar = Gem::Package::TarWriter.new(archive_file)
    date = Time.now - one_month
    files_added = 0

    list_src_path.each do |file|
      file_stat = File.stat(file)
      filename = get_relative_path(file)

      if file_stat.mtime >= date
        puts "Skipping: #{filename}"
      elsif file_stat.directory?
        tar.mkdir(filename, file_stat.mode)

        puts "Directory added: '#{filename}'"
      else
        tar.add_file(filename, file_stat.mode) do |io|
          io.write(File.open(file, 'rb').read)
        end

        files_added += 1
        puts "File added: '#{filename}'"
      end
    end

    tar.close
    archive_file.close

    if files_added > 0
      puts "Archive created '#{archive_path}'. Files added: #{files_added}. Size: #{archive_file_size(archive_path)}"
    else
      File.unlink(archive_path)
      puts "No files older than #{date.to_s}. Nothing to do."
    end
  end

  private

  attr_reader :src_path, :dest_path

  def list_src_path
    Dir[File.join(src_path, '**/*')]
  end

  def archive_filename
    "#{Time.now.strftime('%Y-%m-%d-%H-%M')}.tar"
  end

  def one_month
    30*24*60*60
  end

  def get_relative_path(file)
    src = File.join File.absolute_path(src_path), '/'
    file.sub Regexp::escape(src), ''
  end

  def archive_file_size(path)
    File.stat(path).size / 1024
  end
end

begin
  Archiver.new(*ARGV).run
rescue ArgumentError => ex
  puts <<EOF
  #{ex.message}

  Usage: #{$0} src_path dest_path
EOF
end
