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
  class RollingWindow
    def initialize(table, size)
      @table = table
      @size = size
    end

    def lag(key, diff: 1)
      column = @table[key]
      if @size
        windows = column.each_slice(@size)
      else
        windows = column
      end
      lag_values = [nil] * diff
      windows.each_cons(diff + 1) do |values|
        target = values[0]
        current = values[1]
        if target.nil? or current.nil?
          lag_values << nil
        else
          lag_values << current - target
        end
      end
      ArrayBuilder.build(lag_values)
    end
  end
end
