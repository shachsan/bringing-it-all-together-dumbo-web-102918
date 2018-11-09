class Dog
  attr_accessor :id, :name, :breed

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs")
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, name, breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self

    end
  end

  def self.create(hash)
    Dog.new(hash).save
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?
    SQL

    dog_row = DB[:conn].execute(sql, id)[0]
    new_dog = Dog.new(id:dog_row[0], name:dog_row[1], breed:dog_row[2])
  end

  def self.find_or_create_by(hash)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ? AND breed = ?
    SQL
    dog_row = DB[:conn].execute(sql, hash[:name], hash[:breed])[0]
    if dog_row.empty?
      new_dog = self.create(hash)
    else
      new_dog = Dog.new(id:dog_row[0], name:dog_row[1], breed:dog_row[2])
      # binding.pry
    end
    new_dog

  end

  def self.new_from_db(row)
    Dog.new(row[0],row[1],row[2])
  end

end
