require_relative 'questions_database'
require_relative 'user'

class ModelBase

  TABLE = {'User' => 'users',
          'Question' => 'questions',
          'QuestionFollow' => 'question_follows',
          'Reply' => 'replies',
          'QuestionLike' => 'question_likes'
          }

  def self.find_by_id(id)
    return_arr = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM #{TABLE[self.class.to_s]}
      WHERE
        id = ?
    SQL
    return nil unless return_arr.length > 0

    self.class.new(return_arr.first)
  end

  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM " + Table[self.class.to_s])
    data.map { |datum| self.class.new(datum) }
  end

  def initialize
  end

  def create
    raise "#{self} already in database" if self.id
    inst_one = self.instance_variables.map { |var| self.instance_variable_get(var) }.drop(1)
    inst_two = self.instance_variables.map(&:to_s).drop(1).join('').split('@').drop(1).join(', ')
    injections = Array.new(inst_arr.size) { '?' }.join(', ')
    QuestionsDatabase.instance.execute(<<-SQL, *inst_one)
      INSERT INTO #{TABLE[self.class.to_s]} (#{inst_two})
      VALUES
        (#{injections})
    SQL
    self.id = QuestionsDatabase.instance.last_insert_row_id
  end

  def update
    raise "#{self} not in database" unless self.id
    inst_one = self.instance_variables.map { |var| self.instance_variable_get(var) }.rotate
    inst_two = self.instance_variables.map(&:to_s).drop(1).join('').split('@').drop(1).join(' = ?, ')
    QuestionsDatabase.instance.execute(<<-SQL, *inst_one)
      UPDATE #{TABLE[self.class.to_s]}
      SET #{inst_two} = ?
      WHERE
        id = ?
    SQL
  end

  def save
    self.id ? update : create
  end

  def id
  end

  def id=(val)
  end

end
