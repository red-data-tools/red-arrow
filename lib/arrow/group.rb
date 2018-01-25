# Copyright 2018 Kouhei Sutou <kou@clear-code.com>
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

module Arrow
  class Group
    def initialize(table, keys)
      @table = table
      @keys = keys
    end

    def count
      key_names = @keys.collect(&:to_s)
      target_columns = @table.columns.reject do |column|
        key_names.include?(column.name)
      end
      aggregate(target_columns) do |column, indexes|
        n = 0
        indexes.each do |index|
          n += 1 unless column.null?(index)
        end
        n
      end
    end

    private
    def aggregate(target_columns)
      sort_values = @table.n_rows.times.collect do |i|
        key_values = @keys.collect do |key|
          @table[key][i]
        end
        [key_values, i]
      end
      sorted = sort_values.sort_by do |key_values, i|
        key_values
      end

      grouped_keys = []
      aggregated_arrays_raw = []
      target_columns.size.times do
        aggregated_arrays_raw << []
      end
      indexes = []
      sorted.each do |key_values, i|
        if grouped_keys.empty?
          grouped_keys << key_values
          indexes.clear
          indexes << i
        else
          if key_values == grouped_keys.last
            indexes << i
          else
            grouped_keys << key_values
            target_columns.each_with_index do |column, j|
              aggregated_arrays_raw[j] << yield(column, indexes)
            end
            indexes.clear
            indexes << i
          end
        end
      end
      target_columns.each_with_index do |column, j|
        aggregated_arrays_raw[j] << yield(column, indexes)
      end

      grouped_key_arrays_raw = grouped_keys.transpose
      columns = @keys.collect.with_index do |key, i|
        key_column = @table[key]
        key_column_array_class = key_column.data.chunks.first.class
        Column.new(key_column.field,
                   key_column_array_class.new(grouped_key_arrays_raw[i]))
      end
      target_columns.each_with_index do |column, i|
        array = ArrayBuilder.build(aggregated_arrays_raw[i])
        field = Field.new(column.name, array.value_data_type)
        columns << Column.new(field, array)
      end
      Table.new(columns)
    end
  end
end