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
  class TimestampArrayBuilder
    # TODO: Workaround for Apache Arrow GLib 0.8.0
    alias_method :initialize_raw, :initialize
    def initialize(data_type)
      initialize_raw(data_type)
      data_type_name = data_type.to_s
      if data_type_name.end_with?("[s]")
        @unit_id = :second
      elsif data_type_name.end_with?("[ms]")
        @unit_id = :milli
      elsif data_type_name.end_with?("[us]")
        @unit_id = :micro
      else
        @unit_id = :nano
      end
    end

    private
    def unit_id
      @unit_id ||= unit.nick.to_sym
    end

    def convert_to_arrow_value(value)
      if value.respond_to?(:to_time) and not value.is_a?(Time)
        value = value.to_time
      end

      if value.is_a?(Time)
        case unit_id
        when :second
          value.to_i
        when :milli
          value.to_i * 1_000 + value.usec / 1000
        when :micro
          value.to_i * 1_000_000 + value.usec
        else
          value.to_i * 1_000_000_000 + value.nsec
        end
      else
        value
      end
    end
  end
end
