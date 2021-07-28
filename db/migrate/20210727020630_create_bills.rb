class CreateBills < ActiveRecord::Migration[6.1]
  def change
    create_table :bills do |t|
      t.integer :amount, null: false
      t.date :due_date, null: false
      t.string :status, null: false, default: 'open'
      t.references :enrollment, null: false, foreign_key: true
      t.timestamps
    end

    reversible do |dir|
      dir.up do
        execute <<~SQL
          ALTER TABLE bills
          ADD CONSTRAINT check_amount CHECK (amount > 0);
        SQL

        execute <<~SQL
          ALTER TABLE bills
          ADD CONSTRAINT check_status
            CHECK (status in ('open', 'pending', 'paid'));
        SQL
      end

      dir.down { execute <<~SQL }
        ALTER TABLE bills DROP CONSTRAINT check_amount;
        ALTER TABLE bills DROP CONSTRAINT check_status;
      SQL
    end
  end
end
