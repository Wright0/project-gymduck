require_relative('../db/sql_runner')

class Member

  attr_accessor :name, :age, :membership_type, :membership_status
  attr_reader :id

  def initialize(options)
    @id = options['id'].to_i if options['id']
    @name = options['name']
    @age = options['age']
    @membership_type = options['membership_type']
    @membership_status = options['membership_status']
  end

  def save() #Create
    sql = "INSERT INTO members
    (
      name,
      age,
      membership_type,
      membership_status
    )
    VALUES
    (
      $1, $2, $3, $4
    )
    RETURNING id"
    values = [@name, @age, @membership_type, @membership_status]
    result = SqlRunner.run(sql, values)
    id = result.first['id']
    @id = id.to_i
  end

  def self.all() #Read
    sql = "SELECT * FROM members"
    member_data = SqlRunner.run(sql)
    members = map_members(member_data)
    return members
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM members WHERE id = $1"
    values = [id]
    member_data = SqlRunner.run(sql, values).first
    return Member.new(member_data)
  end

  def update() #Update
    sql = "UPDATE members
    SET
    (
      name,
      age,
      membership_type
    ) =
    (
      $1, $2, $3
    ) WHERE id = $4"
    values = [@name, @age, @membership_type, @id]
    SqlRunner.run(sql, values)
  end

  def update_status() #Update only the status
    sql = "UPDATE members
    SET membership_status = $1 WHERE id = $2"
    values = [@membership_status, @id]
    SqlRunner.run(sql, values)
  end

  def self.delete_all #Delete
    sql = "DELETE FROM members"
    SqlRunner.run(sql)
  end


  def lessons() #returns the classes a specific member is signed up for
    sql =" SELECT l.* FROM lessons l
    INNER JOIN bookings b ON b.lesson_id = l.id
    WHERE b.member_id = $1"
    values = [@id]
    results = SqlRunner.run(sql, values)
    return Lesson.map_lessons(results)
  end

  def set_membership_status
    if membership_status == "active"
      self.membership_status = "inactive"
    else
      self.membership_status = "active"
    end
    self.update_status()
  end

# Helper methods
  def self.map_members(member_data)
    return member_data.map{ |member| Member.new(member)}
  end

end
