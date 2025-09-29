# rubocop:disable Metrics/MethodLength, Metrics/ClassLength
class AddConstraintsForOrders < ActiveRecord::Migration[5.2]
  def up
    change_column_null :orders, :name, false
    change_column_null :orders, :surname, false
    change_column_null :orders, :phone_number, false
    change_column_null :orders, :street, false
    change_column_null :orders, :city, false
    change_column_null :orders, :postal_code, false
    change_column_null :orders, :delivery_method, false
    change_column_null :orders, :payment_method, false
    change_column_null :orders, :email, false
    change_column_null :orders, :user_id, false

    execute <<-SQL
      ALTER TABLE orders
      ADD FOREIGN KEY (user_id) REFERENCES users(id)
    SQL

    execute <<-SQL
      ALTER TABLE orders
      ADD CONSTRAINT name_length_check CHECK (length(name) > 0)
    SQL

    execute <<-SQL
      ALTER TABLE orders
      ADD CONSTRAINT surname_length_check CHECK (length(surname) > 0)
    SQL

    execute <<-SQL
      ALTER TABLE orders
      ADD CONSTRAINT phone_number_length_check CHECK (length(phone_number) > 0)
    SQL

    execute <<-SQL
      ALTER TABLE orders
      ADD CONSTRAINT street_length_check CHECK (length(street) > 0)
    SQL

    execute <<-SQL
      ALTER TABLE orders
      ADD CONSTRAINT city_length_check CHECK (length(city) > 0)
    SQL

    execute <<-SQL
      ALTER TABLE orders
      ADD CONSTRAINT postal_code_length_check CHECK (length(postal_code) > 0)
    SQL

    execute <<-SQL
      ALTER TABLE orders
      ADD CONSTRAINT delivery_method_length_check CHECK (length(delivery_method) > 0)
    SQL

    execute <<-SQL
      ALTER TABLE orders
      ADD CONSTRAINT payment_method_length_check CHECK (length(payment_method) > 0)
    SQL

    execute <<-SQL
      ALTER TABLE orders
      ADD CONSTRAINT email_length_check CHECK (length(email) > 0)
    SQL
  end

  def down
    change_column_null :orders, :name, true
    change_column_null :orders, :surname, true
    change_column_null :orders, :phone_number, true
    change_column_null :orders, :street, true
    change_column_null :orders, :city, true
    change_column_null :orders, :postal_code, true
    change_column_null :orders, :delivery_method, true
    change_column_null :orders, :payment_method, true
    change_column_null :orders, :email, true
    change_column_null :orders, :user_id, true

    execute <<-SQL
      ALTER TABLE orders
      DROP CONSTRAINT orders_user_id_fkey
    SQL

    execute <<-SQL
      ALTER TABLE orders
      DROP CONSTRAINT name_length_check
    SQL

    execute <<-SQL
      ALTER TABLE orders
      DROP CONSTRAINT surname_length_check
    SQL

    execute <<-SQL
      ALTER TABLE orders
      DROP CONSTRAINT phone_number_length_check
    SQL

    execute <<-SQL
      ALTER TABLE orders
      DROP CONSTRAINT street_length_check
    SQL

    execute <<-SQL
      ALTER TABLE orders
      DROP CONSTRAINT city_length_check
    SQL

    execute <<-SQL
      ALTER TABLE orders
      DROP CONSTRAINT postal_code_length_check
    SQL

    execute <<-SQL
      ALTER TABLE orders
      DROP CONSTRAINT delivery_method_length_check
    SQL

    execute <<-SQL
      ALTER TABLE orders
      DROP CONSTRAINT payment_method_length_check
    SQL

    execute <<-SQL
      ALTER TABLE orders
      DROP CONSTRAINT email_length_check
    SQL
  end
end
# rubocop:enable Metrics/MethodLength, Metrics/ClassLength
