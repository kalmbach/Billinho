# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_07_27_020630) do
  # These are extensions that must be enabled in order to support this database
  enable_extension 'plpgsql'

  create_table 'bills', force: :cascade do |t|
    t.integer 'amount', null: false
    t.date 'due_date', null: false
    t.string 'status', default: 'open', null: false
    t.bigint 'enrollment_id', null: false
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
    t.index ['enrollment_id'], name: 'index_bills_on_enrollment_id'
    t.check_constraint "(status)::text = ANY ((ARRAY['open'::character varying, 'pending'::character varying, 'paid'::character varying])::text[])",
                       name: 'check_status'
    t.check_constraint 'amount > 0', name: 'check_amount'
  end

  create_table 'enrollments', force: :cascade do |t|
    t.integer 'amount', null: false
    t.integer 'installments', null: false
    t.integer 'due_day', null: false
    t.bigint 'student_id', null: false
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
    t.index ['student_id'], name: 'index_enrollments_on_student_id'
    t.check_constraint '(due_day >= 1) AND (due_day <= 31)',
                       name: 'check_due_day'
    t.check_constraint 'amount > 0', name: 'check_amount'
    t.check_constraint 'installments > 1', name: 'check_installments'
  end

  create_table 'students', force: :cascade do |t|
    t.string 'name', null: false
    t.string 'cpf', null: false
    t.date 'birthdate'
    t.string 'payment_method', null: false
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
    t.index ['cpf'], name: 'index_students_on_cpf', unique: true
    t.check_constraint "(payment_method)::text = ANY ((ARRAY['credit_card'::character varying, 'boleto'::character varying])::text[])",
                       name: 'check_payment_method'
  end

  add_foreign_key 'bills', 'enrollments'
  add_foreign_key 'enrollments', 'students'
end
