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
  class ArrayBuilder
    class << self
      def build(values)
        builder = new
        builder.build(values)
      end
    end

    def build(values)
      if respond_to?(:append_values)
        start_index = 0
        current_index = 0
        status = :value
        values.each do |value|
          if value.nil?
            if status == :value
              if start_index != current_index
                append_values(values[start_index...current_index])
                start_index = current_index
              end
              status = :null
            end
          else
            if status == :null
              append_nulls(current_index - start_index)
              start_index = current_index
              status = :value
            end
          end
          current_index += 1
        end
        if start_index != current_index
          if status == :value
            if start_index == 0 and current_index == values.size
              append_values(values)
            else
              append_values(values[start_index...current_index])
            end
          else
            append_nulls(current_index - start_index)
          end
        end
      else
        values.each do |value|
          if value.nil?
            append_null
          else
            append(value)
          end
        end
      end
      finish
    end
  end
end
