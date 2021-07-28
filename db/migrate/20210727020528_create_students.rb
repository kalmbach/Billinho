class CreateStudents < ActiveRecord::Migration[6.1]
  def change
    create_table :students do |t|
      t.string :name, null: false
      t.string :cpf, null: false, index: { unique: true }
      t.date :birthdate, null: true
      t.string :payment_method, null: false
      t.timestamps
    end

    reversible do |dir|
      dir.up { execute <<~SQL }
        ALTER TABLE students
        ADD CONSTRAINT check_payment_method
          CHECK (payment_method IN (
            'credit_card',
            'boleto'
          ));
      SQL

      dir.down { execute <<~SQL }
        ALTER TABLE students DROP CONSTRAINT check_payment_method;
      SQL
    end
  end
end
