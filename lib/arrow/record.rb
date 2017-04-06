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
    attr_accessor :index
    def initialize(record_batch, index)
      @record_batch = record_batch
      @index = index
    end

    def [](column_name_or_column_index)
      @record_batch.find_column(column_name_or_column_index)[@index]
    end

    def columns
      @record_batch.columns
    end
  end
end
