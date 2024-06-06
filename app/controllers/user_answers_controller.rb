class UserAnswersController < ApplicationController
  before_action :set_no_cache

  # 回答欄テーブルのデータ作成準備
  def new
    # 試験問題テーブルの使用可能な全問題数を取得
    @examination_count = Examination.get_examination_count
  end

  # 回答欄テーブルのデータ作成とレコード保存
  def create
    # セッションユーザーのID
    user_id = session[:user_id]
    user_answer_params = params.permit(:question_num_all)

    # 提出前のレコードの確認と作成
    is_saved, id, flash_messages = UserAnswer.review_and_create(user_id, user_answer_params[:question_num_all].to_i)

    # 保存の成否を確認
    if is_saved
      # 通知
      flash[:notice] << flash_messages if flash_messages.present?
      # 選択肢提示画面へリダイレクト
      redirect_to edit_user_answer_path(id)
    else
      # 通知
      flash.now[:error] << flash_messages if flash_messages.present?
      # 開始確認画面へ戻す
      render :new
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

    # 保存の成否を確認
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
end
