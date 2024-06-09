module UserAnswerHelper
  def question_num_all
    return ENV['QUESTION_NUM_ALL'].to_i
  end

  # 合格の最低点数を設定
  def passing_score_threshold
    return (question_num_all * ENV['PASSING_SCORE_THRESHOLD'].to_f / 100).ceil
  end
end
