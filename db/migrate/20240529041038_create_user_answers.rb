class CreateUserAnswers < ActiveRecord::Migration[7.1]
  def change
    create_table :user_answers do |t|
      t.references :user, null: false, foreign_key: true
      t.references :examination, null: false, foreign_key: true
      t.string :choiced_ans
      t.boolean :cleared, default: false
      t.integer :attempts_num
      t.integer :question_num

      t.timestamps
    end
  end
end
