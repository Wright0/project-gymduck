require_relative('../db/sql_runner')

class MembershipTier

  attr_accessor :name
  attr_reader :id

  def initialize(options)
    @id = options['id'].to_i if options['id']
    @name = options['name']
  end

  def save() #CREATE
    sql = "INSERT INTO membership_tiers
    (
      name
    )
    VALUES
    (
      $1
    )
    RETURNING id"
    values = [@name]
    result = SqlRunner.run(sql, values)
    id = result.first['id']
    @id = id.to_i
  end

  def self.all()
    sql = "SELECT * FROM membership_tiers"
    tier_data = SqlRunner.run(sql)
    return map_membershiptiers(tier_data)
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM membership_tiers WHERE id = $1"
    values = [id]
    membership_data = SqlRunner.run(sql, values).first
    return MembershipTier.new(membership_data)
  end

  #Helper methods

  def self.map_membershiptiers(tier_data)
    return tier_data.map{ |tier| MembershipTier.new(tier)}
  end

end
