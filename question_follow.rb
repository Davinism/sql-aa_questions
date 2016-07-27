require_relative 'questions_database'

class QuestionFollow
  attr_accessor :question_id, :follower_id

  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM question_follows")
    data.map { |datum| QuestionFollow.new(datum) }
  end

  def self.find_by_id(id)
    question_follows_arr = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        question_follows
      WHERE
        id = ?
    SQL
    return nil unless question_follows_arr.length > 0

    QuestionFollow.new(question_follows_arr.first)
  end

  def self.followers_for_question_id(question_id)
    users_arr = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        users.*
      FROM
        question_follows
        JOIN users
        ON question_follows.follower_id = users.id
      WHERE
        question_id = ?
    SQL
    return nil unless users_arr.length > 0

    users_arr.map { |datum| User.new(datum)}
  end

  def self.followed_questions_for_user_id(user_id)
    questions_arr = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        questions.*
      FROM
        question_follows
        JOIN questions
        ON question_follows.question_id = questions.id
      WHERE
        question_follows.follower_id = ?
    SQL
    return nil unless questions_arr.length > 0

    questions_arr.map { |datum| Question.new(datum)}
  end

  def self.most_followed_questions(n)
    questions_arr = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT
        questions.*
      FROM
        question_follows
        JOIN
          questions ON questions.id = question_follows.question_id
      GROUP BY
        question_follows.question_id
      ORDER BY
        COUNT(*) DESC
      LIMIT ?
    SQL
    return nil unless questions_arr.length > 0
    questions_arr.map { |datum| Question.new(datum) }
  end

  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @follower_id = options['follower_id']
  end

  def create
    raise "#{self} already in database" if @id
    QuestionsDatabase.instance.execute(<<-SQL, @question_id, @follower_id)
      INSERT INTO
        question_follows (question_id, follower_id)
      VALUES
        (?, ?)
    SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end

  def update
    raise "#{self} not in database" unless @id
    QuestionsDatabase.instance.execute(<<-SQL, @question_id, @follower_id, @id)
      UPDATE
        question_follows
      SET
        question_id = ?, follower_id = ?
      WHERE
        id = ?
    SQL
  end

  def save
    @id ? update : create
  end
end
