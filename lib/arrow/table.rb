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
    alias_method :initialize_raw, :initialize
    def initialize(schema_or_raw_table, columns=nil)
      if columns.nil?
        raw_table = schema_or_raw_table
        fields = []
        columns = []
        raw_table.each do |name, array|
          field = Field.new(name.to_s, array.value_data_type)
          fields << field
          columns << Column.new(field, array)
        end
        schema = Schema.new(fields)
      else
        schema = schema_or_raw_table
      end
      initialize_raw(schema, columns)
    end

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

    # TODO
    #
    # @return [Arrow::Column, Array<Arrow::Column>, nil]
    def [](*args)
      if args.size == 1
        case args[0]
        when String, Symbol
          find_column(args[0])
        else
          message = "#{self.class}\#[#{args[0].inspect}]: " +
            "Must be String or Symbol"
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

    # TODO
    #
    # @return [Arrow::Table]
    def slice(slicer)
      case slicer
      when Integer
        slice_by_ranges([slicer])
      when Range
        slice_by_ranges([slicer])
      when ::Array
        slice_by_ranges(slicer)
      when BooleanArray
        target_ranges = []
        in_target = false
        target_start = nil
        slicer.each_with_index do |is_target, i|
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
          target_ranges << [target_start, slicer.length - 1]
        end
        slice_by_ranges(target_ranges)
      end
    end

    # TODO
    #
    # @return [Arrow::Table]
    def merge(other)
      added_columns = {}
      removed_columns = {}

      case other
      when Hash
        other.each do |name, value|
          name = name.to_s
          if value
            added_columns[name] = ensure_column(name, value)
          else
            removed_columns[name] = true
          end
        end
      when Table
        added_columns = {}
        other.columns.each do |column|
          added_columns[column.name] = column
        end
      else
        message = "merge target must be Hash or Arrow::Table: " +
          "<#{other.inspect}>: #{inspect}"
        raise ArgumentError, message
      end

      new_columns = []
      columns.each do |column|
        column_name = column.name
        new_column = added_columns.delete(column_name)
        if new_column
          new_columns << new_column
          next
        end
        next if removed_columns.key?(column_name)
        new_columns << column
      end
      added_columns.each do |name, new_column|
        new_columns << new_column
      end
      new_fields = new_columns.collect do |new_column|
        new_column.field
      end
      self.class.new(Schema.new(new_fields), new_columns)
    end

    def to_s
      formatter = TableFormatter.new(self)
      formatter.format
    end

    def inspect
      "#{super}\n#{to_s}"
    end

    def respond_to_missing?(name, include_private)
      return true if find_column(name)
      super
    end

    def method_missing(name, *args, &block)
      if args.empty?
        column = find_column(name)
        return column if column
      end
      super
    end

    private
    def find_column(name)
      name = name.to_s
      columns.find do |column|
        column.name == name
      end
    end

    def slice_by_ranges(ranges)
      sliced_columns = each_column.collect do |column|
        chunks = []
        arrays = column.data.each_chunk.to_a
        offset = 0
        offset_in_array = 0
        ranges.each do |range|
          case range
          when Integer
            from = to = range
          when Range
            from = range.first
            to = range.last
            to -= 1 if range.exclude_end?
          when ::Array
            from, to, = range
          else
            message = "slice range must be Integer, Range or [from, to]: #{range.inspect}"
            raise ArgumentError, message
          end

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

    def ensure_column(name, data)
      case data
      when Array
        field = Field.new(name, data.value_data_type)
        Column.new(field, data)
      when Column
        data
      else
        message = "column must be Arrow::Array or Arrow::Column: " +
          "<#{name}>: <#{data.inspect}>: #{inspect}"
        raise ArgumentError, message
      end
    end
  end
end
