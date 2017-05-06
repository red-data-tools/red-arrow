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
  class FileReader
    include Enumerable

    # For backward compatibility
    if respond_to?(:open)
      class << self
        alias_method :open_raw, :open
        def open(input)
          warn("#{self}.#{__method__}: use #{self}.new instead: #{caller(1, 1)[0]}")
          reader = open_raw(input)
          if block_given?
            yield(reader)
          else
            reader
          end
        end
      end
    else
      class << self
        def open(input)
          warn("#{self}.#{__method__}: use #{self}.new instead #{caller(1, 1)[0]}")
          reader = new(input)
          if block_given?
            yield(reader)
          else
            reader
          end
        end
      end
    end

    def each
      n_record_batches.times do |i|
        yield(get_record_batch(i))
      end
    end
  end
end
