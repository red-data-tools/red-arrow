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
  class Array
    include Enumerable

    class << self
      def new(values)
        builder_class_name = "#{name}Builder"
        if const_defined?(builder_class_name)
          builder_class = const_get(builder_class_name)
          builder_class.build(values)
        else
          super
        end
      end
    end

    def [](i)
      if null?(i)
        nil
      else
        get_value(i)
      end
    end

    def each
      return to_enum(__method__) unless block_given?

      length.times do |i|
        yield(self[i])
      end
    end

    def to_arrow
      self
    end
  end
end
