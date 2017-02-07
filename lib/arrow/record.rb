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
  class Record
    def initialize(record_batch, i)
      @record_batch = record_batch
      @schema = record_batch.schema
      @columns = record_batch.columns
      @i = i
    end

    def [](name_or_index)
      find_column(name_or_index).get_value(@i)
    end

    def find_column(name_or_index)
      case name_or_index
      when String, Symbol
        name = name_or_index
        index = resolve_name(name)
      else
        index = name_or_index
      end
      @columns[index]
    end

    private
    def resolve_name(name)
      (@name_to_index ||= build_name_to_index)[name.to_s]
    end

    def build_name_to_index
      index = {}
      @schema.fields.each_with_index do |field, i|
        index[field.name] = i
      end
      index
    end
  end
end
