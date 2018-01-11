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
  class TableListFormatter < TableFormatter
    private
    def format_header(text, columns)
    end

    def format_rows(text, columns, rows, n_digits, start_offset)
      rows.each_with_index do |row, nth_row|
        text << ("=" * 20 + " #{start_offset + nth_row} " + "=" * 20 + "\n")
        row.each_with_index do |column_value, nth_column|
          column = columns[nth_column]
          text << "#{column.name}: #{column_value}\n"
        end
      end
    end

    def format_ellipsis(text)
      text << "...\n"
    end
  end
end
