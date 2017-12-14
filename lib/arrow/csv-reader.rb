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

module Arrow
  class CSVReader
    class << self
      def read(csv)
        new(csv).read
      end
    end

    def initialize(csv)
      @csv = csv
    end

    def read
      builders = []
      values_set = []
      @csv.each do |row|
        row.each_with_index do |(_name, value), i|
          builders[i] ||= create_builder(value)
          values = (values_set[i] ||= [])
          case value
          when Time
            value = value.to_i * (10 ** 9) + value.nsec
          end
          values << value
        end
      end
      arrays = values_set.collect.with_index do |values, i|
        builders[i].build(values)
      end
      fields = @csv.headers.collect.with_index do |name, i|
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
