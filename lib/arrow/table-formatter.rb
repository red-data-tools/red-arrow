# Copyright 2017-2018 Kouhei Sutou <kou@clear-code.com>
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

require "time"

module Arrow
  class TableFormatter
    def initialize(table)
      @table = table
    end

    def format
      text = ""
      columns = @table.columns
      columns.each do |column|
        text << "\t"
        text << format_column_name(column)
      end
      text << "\n"

      n_rows = @table.n_rows
      return text if n_rows.zero?

      border = 20
      n_digits = (Math.log10(n_rows) + 1).truncate
      [border, n_rows].min.times do |i|
        format_row(text, columns, i, n_digits)
      end
      return text if n_rows <= border

      text << "...\n"
      [border, n_rows - border].max.upto(n_rows - 1) do |i|
        format_row(text, columns, i, n_digits)
      end

      text
    end

    private
    FLOAT_N_DIGITS = 10
    def format_column_name(column)
      case column.data_type
      when TimestampDataType
        "%*s" % [Time.now.iso8601.size, column.name]
      when FloatDataType, DoubleDataType
        "%*s" % [FLOAT_N_DIGITS, column.name]
      else
        column.name
      end
    end

    def format_row(text, columns, i, n_digits)
      text << ("%*d" % [n_digits, i])
      columns.each do |column|
        text << "\t"
        text << format_column_value(column, i)
      end
      text << "\n"
      text
    end

    def format_column_value(column, i)
      value = column[i]
      case value
      when Time
        value.iso8601
      when Float
        "%*f" % [[column.name.size, FLOAT_N_DIGITS].max, value]
      when Integer
        "%*d" % [column.name.size, value]
      else
        "%-*s" % [column.name.size, value.to_s]
      end
    end
  end
end
