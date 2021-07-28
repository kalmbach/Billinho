class CreateEnrollments < ActiveRecord::Migration[6.1]
  def change
    create_table :enrollments do |t|
      t.integer :amount, null: false
      t.integer :installments, null: false
      t.integer :due_day, null: false
      t.references :student, null: false, foreign_key: true
      t.timestamps
    end

    reversible do |dir|
      dir.up do
        execute <<~SQL
          ALTER TABLE enrollments
          ADD CONSTRAINT check_amount CHECK (amount > 0);
        SQL

        execute <<~SQL
          ALTER TABLE enrollments
          ADD CONSTRAINT check_installments CHECK (installments > 1);
        SQL

        execute <<~SQL
          ALTER TABLE enrollments
          ADD CONSTRAINT check_due_day CHECK (due_day BETWEEN 1 AND 31);
        SQL
      end

      dir.down { execute <<~SQL }
        ALTER TABLE enrollments DROP CONSTRAINT check_amount;
        ALTER TABLE enrollments DROP CONSTRAINT check_installments;
        ALTER TABLE enrollments DROP CONSTRAINT check_due_day;
      SQL
    end
  end
end
