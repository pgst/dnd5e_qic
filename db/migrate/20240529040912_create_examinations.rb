class CreateExaminations < ActiveRecord::Migration[7.1]
  def change
    create_table :examinations do |t|
      t.text :question_txt
      t.string :correct_ans
      t.boolean :can_use, default: false

      t.timestamps
    end
  end
end
