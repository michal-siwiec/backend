# frozen_string_literal: true

module Services
  module SeedGenerator
    class ProductCategoriesService
      private

      SHEET_NAME = 'ProductsCategories'
      MODEL = ProductCategory

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
        @work_sheet[@row_number + COLUMN_NAME_Y_OFFSET][@column_number].value
      end

      def rows_quantity
        5
      end
    end
  end
end
