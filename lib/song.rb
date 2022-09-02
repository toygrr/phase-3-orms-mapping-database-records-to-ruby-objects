class Song

  attr_accessor :name, :album, :id

  def initialize(name:, album:, id: nil)
    @id = id
    @name = name
    @album = album
  end

  # DELETES table and all contents - CAUTION!
  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS songs
    SQL

    DB[:conn].execute(sql)
  end

  #Create songs table
  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS songs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        album TEXT
      )
    SQL

    DB[:conn].execute(sql)
  end

 #Create new row in database
 def self.create(name:, album:)
  song = Song.new(name: name, album: album)
  song.save
end

#Create new ruby instance from a row in the database
def self.new_from_db(row)
  # self.new is equivalent to Song.new
  self.new(id: row[0], name: row[1], album: row[2])
end

# allows us to select all the songs within the database and select them, returning an array of songs.
def self.all
  sql = <<-SQL
    SELECT *
    FROM songs
  SQL
# iterating over all those songs and calling self.new_from_db method to initialize a new ruby version of the table row.
  DB[:conn].execute(sql).map do |row|
    self.new_from_db(row)
  end
end

# name is our peram, passed to the question mark
def self.find_by_name(name)
  sql = <<-SQL
    SELECT *
    FROM songs
    WHERE name = ?
    LIMIT 1
  SQL

  DB[:conn].execute(sql, name).map do |row|
    self.new_from_db(row)
  end.first
end

  #save an instance to the table
  def save
    sql = <<-SQL
      INSERT INTO songs (name, album)
      VALUES (?, ?)
    SQL

    # insert the song
    DB[:conn].execute(sql, self.name, self.album)

    # get the song ID from the database and save it to the Ruby instance
    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM songs")[0][0]

    # return the Ruby instance
    self
  end

end
