# frozen_string_literal: true

module Services
  module SeedGenerator
    class UsersService
      private

      SHEET_NAME = 'Users'
      MODEL = User

      def create_records
        generate_records_attributes.each do |attr|
          user = User.find_by(email: attr['email'])
          next if user

          User.create!(attr)
        end
      end

      def generate_records_attributes
        records_properties = []

        rows_quantity.times do |row_number|
          properties_hash = {}
          @row_number = row_number

          column_quantity.times do |column_number|
            @column_number = column_number
            properties_hash[column_name] = column_value
          end

          records_properties << properties_hash
        end

        records_properties
      end

      def column_name
        @work_sheet[COLUMN_NAME_ROW_INDEX][@column_number].value
      end

      def column_value
        @work_sheet[@row_number + COLUMN_NAME_Y_OFFSET][@column_number].value
      end

      def rows_quantity
        2
      end
    end
  end
end
