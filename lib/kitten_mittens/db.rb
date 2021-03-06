require 'sqlite3'

class KittenMittens
  class DB
    attr_reader :db
    def initialize
      database_file = './db/kindle.db'
      if File.exists?( database_file )
        @db = SQLite3::Database.new( database_file )
      else
        FileUtils.mkdir_p('./db')
        @db = SQLite3::Database.new( database_file )
        initialize_database
      end
      @db.results_as_hash = true
    end

    def close
      db.close
    end

    def to_analyze
      db.execute('SELECT rowid, * FROM snaps where analyzed_at is null')
    end

    def with_similarity_more_than(similarity)
      db.execute(
        'SELECT rowid, * FROM snaps where similarity is not null and similarity > ?',
        similarity
      )
    end

    def get_previous_snap(rowid)
      db.get_first_row(
        'select rowid, * from snaps where rowid < ? order by rowid desc',
        rowid
      )
    end

    def update_similarity(rowid, similarity)
      db.execute(
        'UPDATE snaps set similarity = ?, analyzed_at = datetime("now") where  rowid = ?',
        similarity, rowid
      )
    end

    def delete_snap(rowid)
      db.execute('delete from snaps where rowid = ?', rowid)
    end

    def delete_all_snaps
      db.execute('delete from snaps')
    end

    def update_matrix(rowid, pixel_matrix)
      db.execute(
        'UPDATE snaps set pixel_matrix = ? where rowid = ?',
        pixel_matrix, rowid
      )
    end

    def insert_snap(file_name)
      db.execute(
        'INSERT into snaps(file_name, created_at) values(?, datetime("now"))',
        file_name
      )
    end

    def execute(*args)
      db.execute(args)
    end

    def initialize_database
      db.execute(
        'CREATE TABLE snaps(
          file_name TEXT,
          pixel_matrix TEXT,
          similarity text,
          created_at datetime,
          analyzed_at datetime
        )'
      )
    end
  end
end
