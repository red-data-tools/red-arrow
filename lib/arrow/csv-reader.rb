# Copyright 2017 Kouhei Sutou <kou@clear-code.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "csv"
require "pathname"
require "time"

module Arrow
  class CSVReader
    class << self
      def read(csv, **options)
        case csv
        when Pathname
          path = csv.to_path
          options = update_csv_parse_options(options, :open_csv, path)
          open_csv(path, **options) do |_csv|
            read(_csv)
          end
        when /\A.+\.csv\z/i
          read(Pathname.new(csv), **options)
        when String
          options = update_csv_parse_options(options, :parse_csv_data, csv)
          parse_csv_data(csv, **options) do |_csv|
            read(_csv)
          end
        else
          new(csv).read
        end
      end

      private
      def open_csv(path, **options)
        CSV.open(path, **options) do |csv|
          yield(csv)
        end
      end

      def parse_csv_data(data, **options)
        csv = CSV.new(data, **options)
        begin
          yield(csv)
        ensure
          csv.close
        end
      end

      ISO8601_CONVERTER = lambda do |field|
        begin
          encoded_field = field.encode(CSV::ConverterEncoding)
        rescue EncodingError
          field
        else
          begin
            Time.iso8601(encoded_field)
          rescue ArgumentError
            field
          end
        end
      end

      def update_csv_parse_options(options, create_csv, *args)
        return options unless options.empty?

        new_options = options.merge(converters: [:all, ISO8601_CONVERTER])
        __send__(create_csv, *args, **new_options) do |csv|
          row1 = csv.shift
          if row1.nil?
            new_options[:headers] = false
            return new_options
          end
          if row1.any?(&:nil?)
            new_options[:headers] = false
            return new_options
          end

          row2 = csv.shift
          return new_options if row2.nil?
          if row2.any?(&:nil?)
            new_options[:headers] = true
            return new_options
          end

          if row1.collect(&:class) != row2.collect(&:class)
            new_options[:headers] = true
            return new_options
          end

          new_options
        end
      end
    end

    def initialize(csv)
      @csv = csv
    end

    def read
      builders = []
      values_set = []
      @csv.each do |row|
        if row.is_a?(CSV::Row)
          row = row.collect(&:last)
        end
        row.each_with_index do |value, i|
          builders[i] ||= create_builder(value)
          values = (values_set[i] ||= [])
          case value
          when Time
            value = value.to_i * (10 ** 9) + value.nsec
          end
          values << value
        end
      end
      return nil if values_set.empty?

      arrays = values_set.collect.with_index do |values, i|
        builders[i].build(values)
      end
      if @csv.headers
        names = @csv.headers
      else
        names = builders.size.times.collect(&:to_s)
      end
      fields = names.collect.with_index do |name, i|
        Arrow::Field.new(name, arrays[i].value_data_type)
      end
      schema = Schema.new(fields)
      columns = arrays.collect.with_index do |array, i|
        Column.new(fields[i], array)
      end
      Table.new(schema, columns)
    end

    private
    def create_builder(sample_value)
      case sample_value
      when Integer
        IntArrayBuilder.new
      when Float
        DoubleArrayBuilder.new
      when String
        StringArrayBuilder.new
      when Time
        data_type = TimestampDataType.new(:nano)
        TimestampArrayBuilder.new(data_type)
      else
        nil
      end
    end
  end
end
