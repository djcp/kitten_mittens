require 'fileutils'
require 'cocaine'
require './lib/kitten_mittens/db'
require 'similar_text'

class KittenMittens
  attr_reader :db
  STREAMER = %w|streamer -s 1280x1024 -c /dev/video0 -b 128 -o|
  PIXEL_MATRIX_COMMAND = %w(| convert -scale 24x -depth 3 - text:)

  def initialize
    @db = DB.new
  end

  def analyze_all
    snaps = db.to_analyze
    snaps.each do |snap|
      pixel_matrix = Cocaine::CommandLine.new(
        ['cat', snap['file_name'], PIXEL_MATRIX_COMMAND].flatten
      ).run
      snap['pixel_matrix'] = pixel_matrix
      db.update_matrix(snap['rowid'], pixel_matrix)

      previous_image = db.get_previous_snap(snap['rowid'])
      if previous_image
        db.update_delta(
          snap['rowid'],
          snap['pixel_matrix'].similar(previous_image['pixel_matrix'])
        )
      end
    end
  end

  def snap
    file_name = "./images/#{Time.now.to_i}.jpeg"
    FileUtils.mkdir_p('./images')
    begin
      Cocaine::CommandLine.new([STREAMER, file_name].flatten).run
      db.insert_snap(file_name)
    rescue Cocaine::ExitStatusError => e
      $stderr.puts e.inspect
    end
  end
end
