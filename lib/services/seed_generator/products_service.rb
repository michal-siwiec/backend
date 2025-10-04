# frozen_string_literal: true

module Services
  module SeedGenerator
    class ProductsService
      private

      SHEET_NAME = 'Products'
      MODEL = Product

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
        return product_category_id if product_category_column?
        return available_quantity if available_quantity_column?

        column_content
      end

      def product_category_id
        ProductCategory.find_by(name: column_content).id
      end

      def product_category_column?
        @column_number == 4
      end

      def available_quantity
        column_content.to_i
      end

      def available_quantity_column?
        @column_number == 2
      end

      def column_content
        @work_sheet[@row_number + COLUMN_NAME_Y_OFFSET][@column_number]&.value
      end

      def rows_quantity
        26
      end
    end
  end
end
