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
  class ChunkedArray
    include Enumerable

    def [](i)
      n_chunks.times do |j|
        array = get_chunk(j)
        return array[i] if i < array.length
        i -= array.length
      end
      nil
    end

    def each(&block)
      return to_enum(__method__) unless block_given?

      each_chunk do |array|
        array.each(&block)
      end
    end

    def each_chunk
      return to_enum(__method__) unless block_given?

      n_chunks.times do |i|
        yield(get_chunk(i))
      end
    end
  end
end
