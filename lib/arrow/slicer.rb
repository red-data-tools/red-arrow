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
  class Slicer
    def initialize(table)
      @table = table
    end

    def [](column_name)
      column = @table[column_name]
      return nil if column.nil?
      ColumnCondition.new(column)
    end

    def respond_to_missing?(name, include_private)
      return true if self[name]
      super
    end

    def method_missing(name, *args, &block)
      if args.empty?
        column_condition = self[name]
        return column_condition if column_condition
      end
      super
    end

    class Condition
      def evaluate
        message = "Slicer::Condition must define \#evaluate: #{inspect}"
        raise NotImplementedError.new(message)
      end
    end

    class ColumnCondition < Condition
      def initialize(column)
        @column = column
      end

      def ==(value)
        EqualCondition.new(@column, value)
      end

      def !=(value)
        NotEqualCondition.new(@column, value)
      end

      def <(value)
        LessCondition.new(@column, value)
      end

      def <=(value)
        LessEqualCondition.new(@column, value)
      end

      def >(value)
        GreaterCondition.new(@column, value)
      end

      def >=(value)
        GreaterEqualCondition.new(@column, value)
      end
    end

    class EqualCondition < Condition
      def initialize(column, value)
        @column = column
        @value = value
      end

      def !@
        NotEqualCondition.new(@column, @value)
      end

      def evaluate
        case @value
        when nil
          raw_array = @column.collect(&:nil?)
          BooleanArray.new(raw_array)
        else
          raw_array = @column.collect do |value|
            if value.nil?
              nil
            else
              @value == value
            end
          end
          BooleanArray.new(raw_array)
        end
      end
    end

    class NotEqualCondition < Condition
      def initialize(column, value)
        @column = column
        @value = value
      end

      def !@
        EqualCondition.new(@column, @value)
      end

      def evaluate
        case @value
        when nil
          raw_array = @column.collect do |value|
            not value.nil?
          end
          BooleanArray.new(raw_array)
        else
          raw_array = @column.collect do |value|
            if value.nil?
              nil
            else
              @value != value
            end
          end
          BooleanArray.new(raw_array)
        end
      end
    end

    class LessCondition < Condition
      def initialize(column, value)
        @column = column
        @value = value
      end

      def !@
        GreaterEqualCondition.new(@column, @value)
      end

      def evaluate
        raw_array = @column.collect do |value|
          if value.nil?
            nil
          else
            @value > value
          end
        end
        BooleanArray.new(raw_array)
      end
    end

    class LessEqualCondition < Condition
      def initialize(column, value)
        @column = column
        @value = value
      end

      def !@
        GreaterCondition.new(@column, @value)
      end

      def evaluate
        raw_array = @column.collect do |value|
          if value.nil?
            nil
          else
            @value >= value
          end
        end
        BooleanArray.new(raw_array)
      end
    end

    class GreaterCondition < Condition
      def initialize(column, value)
        @column = column
        @value = value
      end

      def !@
        LessEqualCondition.new(@column, @value)
      end

      def evaluate
        raw_array = @column.collect do |value|
          if value.nil?
            nil
          else
            @value < value
          end
        end
        BooleanArray.new(raw_array)
      end
    end

    class GreaterEqualCondition < Condition
      def initialize(column, value)
        @column = column
        @value = value
      end

      def !@
        LessCondition.new(@column, @value)
      end

      def evaluate
        raw_array = @column.collect do |value|
          if value.nil?
            nil
          else
            @value <= value
          end
        end
        BooleanArray.new(raw_array)
      end
    end
  end
end
