# frozen_string_literal: true

module Services
  module SeedGenerator
    class OpinionsService
      private

      SHEET_NAME = 'Opinions'
      MODEL = Opinion

      def generate_records_attributes
        records_attributes = []

        rows_quantity.times do |row_number|
          attributes = {}
          @row_number = row_number

          column_quantity.times do |column_number|
            @column_number = column_number
            attributes[column_name] = column_value
          end

          records_attributes << attributes
        end

        records_attributes
      end

      def column_name
        @work_sheet[COLUMN_NAME_ROW_INDEX][@column_number].value
      end

      def column_value
        return user_id if user_column?

        column_content
      end

      def user_id
        User.find_by!(email: column_content).id
      end

      def column_content
        @work_sheet[@row_number + COLUMN_NAME_Y_OFFSET][@column_number].value
      end

      def user_column?
        @column_number == 2
      end

      def rows_quantity
        2
      end
    end
  end
end
