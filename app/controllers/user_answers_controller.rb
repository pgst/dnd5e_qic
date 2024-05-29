class UserAnswersController < ApplicationController
  # 回答欄テーブルのデータ作成準備
  def new
    # 試験問題テーブルの使用可能な全問題数を取得
    @examination_count = Examination.where(can_use: true).pluck(:id).size
    # 問題数の初期値を設定
    @question_num_all = 10
  end

  def create
  end

  def edit
  end

  def update
  end

  def submit
  end

  def results
  end

  def index
  end

  def show
  end
end
