require_relative 'questions_database'

class QuestionLike
  attr_accessor :user_id, :question_id

  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM question_likes")
    data.map { |datum| QuestionLike.new(datum) }
  end

  def self.find_by_id(id)
    question_likes_arr = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        question_likes
      WHERE
        id = ?
    SQL
    return nil unless question_likes_arr.length > 0

    QuestionLike.new(question_likes_arr.first)
  end

  def self.likers_for_question_id(question_id)
    users_arr = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        users.*
      FROM
        question_likes
        JOIN users
        ON question_likes.user_id = users.id
      WHERE
        question_likes.question_id = ?
    SQL
    return nil unless users_arr.length > 0
    users_arr.map { |datum| User.new(datum) }
  end

  def self.num_likes_for_question_id(question_id)
    count_arr = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        COUNT(*)
      FROM
        question_likes
      WHERE
        question_likes.question_id = ?
    SQL
    count_arr[0].values.first
  end

  def self.liked_questions_for_user_id(user_id)
    questions_arr = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        questions.*
      FROM
        question_likes
        JOIN questions
        ON question_likes.question_id = questions.id
      WHERE
        question_likes.user_id = ?
    SQL
    return nil unless questions_arr.length > 0
    questions_arr.map { |datum| Question.new(datum) }
  end

  def self.most_liked_questions(n)
    questions_arr = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT
        questions.*
      FROM
        question_likes
        JOIN
          questions ON questions.id = question_likes.question_id
      GROUP BY
        question_likes.question_id
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
    @user_id = options['user_id']
  end

  def create
    raise "#{self} already in database" if @id
    QuestionsDatabase.instance.execute(<<-SQL, @question_id, @user_id)
      INSERT INTO
        question_likes (question_id, user_id)
      VALUES
        (?, ?)
    SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end

  def update
    raise "#{self} not in database" unless @id
    QuestionsDatabase.instance.execute(<<-SQL, @question_id, @user_id, @id)
      UPDATE
        question_likes
      SET
        question_id = ?, user_id = ?
      WHERE
        id = ?
    SQL
  end

  def save
    @id ? update : create
  end

end
