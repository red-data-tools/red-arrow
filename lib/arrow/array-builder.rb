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
        if builder.respond_to?(:append_values)
          start_index = 0
          current_index = 0
          status = :value
          values.each do |value|
            if value.nil?
              if status == :value
                if start_index != current_index
                  builder.append_values(values[start_index...current_index])
                  start_index = current_index
                end
                status = :null
              end
            else
              if status == :null
                builder.append_nulls(current_index - start_index)
                start_index = current_index
                status = :value
              end
            end
            current_index += 1
          end
          if start_index != current_index
            if status == :value
              if start_index == 0 and current_index == values.size
                builder.append_values(values)
              else
                builder.append_values(values[start_index...current_index])
              end
            else
              builder.append_nulls(current_index - start_index)
            end
          end
        else
          values.each do |value|
            if value.nil?
              builder.append_null
            else
              builder.append(value)
            end
          end
        end
        builder.finish
      end
    end
  end
end
