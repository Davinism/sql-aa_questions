require_relative 'questions_database'
require_relative 'modelbase'

class User < ModelBase
  attr_accessor :fname, :lname
  attr_accessor :id

  # def self.all
  #   data = QuestionsDatabase.instance.execute("SELECT * FROM users")
  #   data.map { |datum| User.new(datum) }
  # end

  # def self.find_by_id(id)
  #   user_id_arr = QuestionsDatabase.instance.execute(<<-SQL, id)
  #     SELECT
  #       *
  #     FROM
  #       users
  #     WHERE
  #       id = ?
  #   SQL
  #   return nil unless user_id_arr.length > 0
  #
  #   User.new(user_id_arr.first)
  # end


    def self.find_by_name(fname, lname)
      users_arr = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
        SELECT
          *
        FROM
          users
        WHERE
          fname = ? AND lname = ?
      SQL
      return nil unless users_arr.length > 0

      User.new(users_arr.first)
    end

    def initialize(options)
      @id = options['id']
      @fname = options['fname']
      @lname = options['lname']
    end

    def authored_questions
      Question.find_by_author_id(@id)
    end

    def authored_replies
      Reply.find_by_user_id(@id)
    end

    def followed_questions
      QuestionFollow.followed_questions_for_user_id(@id)
    end

    # def create
    #   raise "#{self} already in database" if @id
    #   QuestionsDatabase.instance.execute(<<-SQL, @fname, @lname)
    #     INSERT INTO
    #       users (fname, lname)
    #     VALUES
    #       (?, ?)
    #   SQL
    #   @id = QuestionsDatabase.instance.last_insert_row_id
    # end

    # def update
    #   raise "#{self} not in database" unless @id
    #   QuestionsDatabase.instance.execute(<<-SQL, @fname, @lname, @id)
    #     UPDATE
    #       users
    #     SET
    #       fname = ?, lname = ?
    #     WHERE
    #       id = ?
    #   SQL
    # end
    #
    # def save
    #   @id ? update : create
    # end

    def liked_questions
      QuestionLike.liked_questions_for_user_id(@id)
    end

    def average_karma
      count_arr = QuestionsDatabase.instance.execute(<<-SQL, @id)
      SELECT
        CAST(COUNT(question_likes.question_id) AS FLOAT) / COUNT(DISTINCT(questions.id))
      FROM
        questions
      LEFT OUTER JOIN
        question_likes ON questions.id = question_likes.question_id
      WHERE
        questions.author_id = ?
      SQL
      count_arr[0].values.first
    end
end
