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
    question_num_all = user_answer_params[:question_num_all].to_i
    # 解答欄テーブルからセッションユーザーの受験回数を取得
    attempts_num = UserAnswer.get_attempts_num(user_id)

    # 提出前のレコードの有無を確認
    user_answers = UserAnswer.get_user_answers(user_id)
    if user_answers.present?
      # 通知
      flash[:notice] = '答案提出前の問題があります。再表示しますので回答してください。'
      redirect_to edit_user_answer_path(user_answers.first.id)
    else
      # 回答欄データを作成して保存
      is_saved, first_id, e_message = UserAnswer.set_user_answers(question_num_all, user_id, attempts_num)

      if is_saved
        redirect_to edit_user_answer_path(first_id)
      else
        flash.now[:error] << e_message
        render :new
      end
    end
  end

  # 回答欄テーブルのchoiced_ansカラムの更新準備
  def edit
    @user_answer = UserAnswer.get_user_answer(params[:id])

    # セッションユーザーと回答者が異なる場合、トップページへリダイレクト
    flash.now[:error] = '他のユーザーの回答は編集できません。'if @user_answer.user_id != session[:user_id]
    redirect_to root_path if @user_answer == nil || @user_answer.user_id != session[:user_id]

    # すでに回答している問題の場合、その選択肢を選択済みにする
    @choiced_ans_yes = @user_answer.choiced_ans == 'yes' ? true : false
    @choiced_ans_no = @user_answer.choiced_ans == 'no' ? true : false
  end

  # 回答欄テーブルのchoiced_ansカラムの更新
  def update
    @user_answer = UserAnswer.get_user_answer(params[:id])
    if params[:user_answer] == nil
      flash.now[:error] = '「はい」か「いいえ」のどちらかを選択してください。'
      # 同じ問題番号の画面を再表示
      render :edit
      return
    end
    @user_answer.choiced_ans = params[:user_answer][:choiced_ans]

    begin
      if @user_answer.save  # 保存に成功した場合
        # 最大、すなわち最終問題かを確認
        if @user_answer.question_num == UserAnswer.get_question_num_all(session[:user_id], :question_num)
          flash[:notice] = '回答が完了したら提出してください。または、第1問目から選択しなおすこともできます。'
          # 提出確認画面へ
          redirect_to user_answers_submit_path
        else  # 最終問題でない場合
          # 次の問題へ
          redirect_to edit_user_answer_path(@user_answer.id + 1)
        end
      end
    rescue ActiveRecord::RecordInvalid => e
      flash.now[:error] = e.record.errors.full_messages
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
