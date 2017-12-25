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

module Arrow
  class Table
    def each_column
      return to_enum(__method__) unless block_given?

      n_columns.times do |i|
        yield(get_column(i))
      end
    end

    def columns
      @columns ||= each_column.to_a
    end

    def each_record_batch
      return to_enum(__method__) unless block_given?

      reader = TableBatchReader.new(self)
      while record_batch = reader.read_next
        yield(record_batch)
      end
    end

    def [](*args)
      if args.size == 1
        case args[0]
        when String, Symbol
          find_column(args[0])
        when BooleanArray
          slice(args[0])
        else
          message = "#{self.class}\#[#{args[0].inspect}]: " +
            "Must be String, Symbol or Arrow::BooleanArray"
          raise ArgumentError, message
        end
      else
        new_columns = args.collect do |column_name|
          column = find_column(column_name)
          if column.nil?
            message = "Unknown column: <#{column_name.inspect}>: #{inspect}"
            raise ArgumentError, message
          end
          column
        end
        self.class.new(schema, new_columns)
      end
    end

    def slice(target_rows)
      target_ranges = []
      in_target = false
      target_start = nil
      target_rows.each_with_index do |is_target, i|
        if is_target
          unless in_target
            target_start = i
            in_target = true
          end
        else
          if in_target
            target_ranges << [target_start, i - 1]
            target_start = nil
            in_target = false
          end
        end
      end
      if in_target
        target_ranges << [target_start, target_rows.length - 1]
      end

      sliced_columns = each_column.collect do |column|
        chunks = []
        arrays = column.data.each_chunk.to_a
        offset = 0
        offset_in_array = 0
        target_ranges.each do |from, to|
          range_size = to - from + 1
          while range_size > 0
            while offset + arrays.first.length - offset_in_array < from
              offset += arrays.first.length - offset_in_array
              arrays.shift
              offset_in_array = 0
            end
            if offset < from
              skipped_size = from - offset
              offset += skipped_size
              offset_in_array += skipped_size
            end
            array = arrays.first
            array_length = array.length
            rest_length = array_length - offset_in_array
            if rest_length <= range_size
              chunks << array.slice(offset_in_array, array_length)
              offset += rest_length
              range_size -= rest_length
              offset_in_array = 0
              arrays.shift
            else
              chunks << array.slice(offset_in_array, range_size)
              offset += range_size
              offset_in_array += range_size
              range_size = 0
            end
          end
        end
        Column.new(column.field, ChunkedArray.new(chunks))
      end

      self.class.new(schema, sliced_columns)
    end

    def to_s
      formatter = TableFormatter.new(self)
      formatter.format
    end

    def inspect
      "#{super}\n#{to_s}"
    end

    private
    def find_column(name)
      name = name.to_s
      columns.find do |column|
        column.name == name
      end
    end
  end
end
