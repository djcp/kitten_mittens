require 'fileutils'
require 'cocaine'
require './lib/kitten_mittens/db'
require './lib/kitten_mittens/snap_command_finder'
require 'similar_text'

class KittenMittens
  attr_reader :db, :snap_command, :similarity_threshold, :storage_dir

  STREAMER = %w|streamer -s 1280x1024 -c /dev/video0 -b 128 -o|
  PIXEL_MATRIX_COMMAND = %w(convert -scale 24x -depth 3 - text:)

  def initialize(similarity_threshold = 95, storage_dir = './images')
    FileUtils.mkdir_p(storage_dir)
    @db = DB.new
    @snap_command = SnapCommandFinder.find
    @similarity_threshold = similarity_threshold
    @storage_dir = storage_dir
  end

  def analyze_all
    snaps = db.to_analyze
    snaps.each do |snap|
      pixel_matrix = Cocaine::CommandLine.new(
        [PIXEL_MATRIX_COMMAND, '<', snap['file_name']].flatten
      ).run
      snap['pixel_matrix'] = pixel_matrix
      db.update_matrix(snap['rowid'], pixel_matrix)

      previous_image = db.get_previous_snap(snap['rowid'])
      if previous_image
        db.update_similarity(
          snap['rowid'],
          snap['pixel_matrix'].similar(previous_image['pixel_matrix'])
        )
      end
    end
  end

  def reset
    db.delete_all_snaps
    FileUtils.rm Dir.glob("#{storage_dir}/*.jpeg")
  end

  def remove_similar_images
    snaps = db.with_similarity_more_than(similarity_threshold)
    snaps.each do |snap|
      File.unlink(snap['file_name'])
      db.delete_snap(snap['rowid'])
    end
  end

  def snap
    file_name = "#{storage_dir}/#{Time.now.to_i}.jpeg"
    begin
      Cocaine::CommandLine.new(
        [snap_command, file_name].flatten, '', swallow_stderr: true
      ).run
      db.insert_snap(file_name)
    rescue Cocaine::ExitStatusError => e
      $stderr.puts e.inspect
    end
  end
end
