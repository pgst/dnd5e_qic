class UserAnswersController < ApplicationController
  before_action :set_no_cache

  # 回答欄テーブルのデータ作成準備
  def new
    # 試験問題テーブルの使用可能な全問題数を取得
    @examination_count = Examination.get_examination_count
    # 問題数の初期値を設定
    @question_num_all = ENV['QUESTION_NUM_ALL'].to_i
    # 合格の最低点数を設定
    @passing_score_threshold = (@question_num_all * ENV['PASSING_SCORE_THRESHOLD'].to_f / 100).ceil
  end

  # 回答欄テーブルのデータ作成とレコード保存
  def create
    # セッションユーザーのID
    user_id = session[:user_id]

    # 問題数
    question_num_all = params[:question_num_all].to_i

    # 解答欄テーブルからセッションユーザーの受験回数を取得
    attempts_num = UserAnswer.get_attempts_num(user_id)

    # 提出前のレコード
    user_answers = UserAnswer.get_user_answers(user_id)

    # 提出前のレコードの有無を確認
    if user_answers.present?
      # 通知
      flash[:notice] = '答案提出前の問題があります。再表示しますので回答してください。'
      # 第1問目の画面へリダイレクト
      redirect_to edit_user_answer_path(user_answers.first.id)
    else
      # 回答欄データを新規作成して保存
      is_saved, id_first, err_messages = UserAnswer.set_user_answers(question_num_all, user_id, attempts_num)

      # 保存の成否
      if is_saved
        # 第1問目の画面へリダイレクト
        redirect_to edit_user_answer_path(id_first)
      else
        # 通知
        flash.now[:error] << err_messages
        # 最初の確認画面へ戻す
        render :new
      end
    end
  end

  # 回答欄テーブルのchoiced_ansカラムの更新準備
  def edit
    @user_answer = UserAnswer.get_by_id(params[:id])

    if @user_answer.nil? || !@user_answer.belongs_to_user?(session[:user_id])
      # セッションユーザーと回答者が異なる場合、トップページへリダイレクト
      flash.now[:error] = '他のユーザーの回答は編集できません。'
      redirect_to root_path
    else
      # すでに回答している問題の場合、その選択肢を選択済みにする
      @choiced_ans_yes, @choiced_ans_no = @user_answer.get_choiced_ans_flags
    end
  end

  # 回答欄テーブルのchoiced_ansカラムの更新
  def update
    @user_answer = UserAnswer.get_by_id(params[:id])
    if params[:user_answer].nil?
      flash.now[:error] = '「はい」か「いいえ」のどちらかを選択してください。'
      # 同じ問題番号の画面を再表示
      render :edit
      return
    end

    is_saved, e_messages = @user_answer.update_choiced_ans(params[:user_answer])

    if is_saved
      # 最終問題かを確認
      if @user_answer.is_last_question?(session[:user_id])
        flash[:notice] = '回答が完了したら提出してください。または、第1問目から選択しなおすこともできます。'
        # 提出確認画面へ
        redirect_to user_answers_submit_path
      else
        # 最終問題でなければ次の問題へ
        redirect_to edit_user_answer_path(@user_answer.id + 1)
      end
    else
      # 通知
      flash.now[:error] << e_messages
      # 同じ問題番号の画面を再表示
      render :edit
    end
  end

  # ここで答案を提出するか確認
  def submit
    # 問題の先頭番号を取得
    @id_first = UserAnswer.get_id_first(session[:user_id])
    # user_answers_results_pathから戻るボタン等で戻った時のエラー処理が必要
  end

  # ここで合否判定を行う
  def results
    @correct_num, @passed, is_saved = UserAnswer.results(session[:user_id])
    render :submit unless is_saved  # 保存に失敗してたら、提出画面を再表示
  end

  # 回答欄テーブルのレコード一覧を表示（予定）
  def index
  end

  private

  def set_no_cache
    response.headers["Cache-Control"] = "no-cache, no-store, must-revalidate"
  end

  def user_answer_params
    params.permit(:question_num_all)
  end
end
