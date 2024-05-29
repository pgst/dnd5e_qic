################################
# 次の段階では、                #
# ファットコントローラを解消して #
# コントローラの役割をシンプルに #
################################
class UserAnswersController < ApplicationController
  # 回答欄テーブルのデータ作成準備
  def new
    # 試験問題テーブルの使用可能な全問題数を取得
    @examination_count = Examination.where(can_use: true).pluck(:id).size
    # 問題数の初期値を設定
    @question_num_all = 10
  end

  # 回答欄テーブルのデータ作成とレコード保存
  def create
    # 全問題データを取得
    @questions = Examination.all
    # セッションユーザーのIDを取得
    user_id = session[:user_id]
    # セッションユーザーの受験回数を取得
    attempts_num = UserAnswer.where(user_id: user_id).maximum(:attempts_num)
    # 初回受験時はnilのため0を代入
    attempts_num ||= 0
    # 問題数
    question_num_all = params[:question_num_all].to_i

    # 回答欄テーブルからセッションユーザーの、clearedがnilでquestion_numが1以上のレコードを取得
    user_answers = UserAnswer.where(user_id: user_id, cleared: nil, question_num: 1..).order(:question_num)
    if user_answers.present?
      flash[:notice] = '答案提出前の問題があります。回答してください。'
      redirect_to edit_user_answer_path(user_answers.first.id)
    else  # なければ、以下の処理を実行
      # 使用可能な問題のIDをランダムにquestion_num_all個取得
      examination_ids_rand = Examination.where(can_use: true).order("RANDOM()").limit(question_num_all).pluck(:id)
      user_answers = []
      question_num_all.times do |i|
        user_answer = UserAnswer.new
        user_answer.user_id = user_id
        user_answer.examination_id = examination_ids_rand[i]
        user_answer.attempts_num = attempts_num + 1
        user_answer.question_num = i + 1
        user_answers << user_answer
      end

      begin
        if user_answers.all?(&:save!)
          flash[:notice] = '問題の準備ができました。回答してください。'
          redirect_to edit_user_answer_path(user_answers.first.id)
        end
      rescue ActiveRecord::RecordInvalid => e
        flash.now[:error] << e.record.errors.full_messages
        render :new
      end
    end
  end

  # 回答欄テーブルのchoiced_ansカラムの更新準備
  def edit
    @user_answer = UserAnswer.find(params[:id])

    # セッションユーザーと回答者が異なる場合、トップページへリダイレクト
    flash.now[:error] = '他のユーザーの回答は編集できません。'if @user_answer.user_id != session[:user_id]
    redirect_to root_path if @user_answer == nil || @user_answer.user_id != session[:user_id]

    # すでに回答している問題の場合、その選択肢を選択済みにする
    @choiced_ans_yes = @user_answer.choiced_ans == 'yes' ? true : false
    @choiced_ans_no = @user_answer.choiced_ans == 'no' ? true : false
  end

  # 回答欄テーブルのchoiced_ansカラムの更新
  def update
    @user_answer = UserAnswer.find(params[:id])
    if params[:user_answer] == nil
      flash.now[:error] = '「はい」か「いいえ」のどちらかを選択してください。'
      render :edit  # 同じ問題番号の画面を再表示
      return
    end
    @user_answer.choiced_ans = params[:user_answer][:choiced_ans]

    begin
      if @user_answer.save  # 保存に成功した場合
        question_num_all = UserAnswer.where(user_id: session[:user_id]).maximum(:question_num)
        if @user_answer.question_num == question_num_all  # 最終問題の場合
          flash[:notice] = '回答が完了したら、提出してください。'
          redirect_to user_answers_submit_path  # 提出確認画面へ
        else  # 最終問題でない場合
          redirect_to edit_user_answer_path(@user_answer.id + 1)  # 次の問題へ
        end
      end
    rescue ActiveRecord::RecordInvalid => e
      flash.now[:error] = e.record.errors.full_messages
      render :edit  # 同じ問題番号の画面を再表示
    end
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
