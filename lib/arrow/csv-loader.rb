# Copyright 2017-2018 Kouhei Sutou <kou@clear-code.com>
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

require "csv"
require "pathname"
require "time"

module Arrow
  class CSVLoader
    class << self
      def load(path_or_data, **options)
        new(path_or_data, **options).load
      end
    end

    def initialize(path_or_data, **options)
      @path_or_data = path_or_data
      @options = options
    end

    def load
      case @path_or_data
      when Pathname
        load_from_path(@path_or_data.to_path)
      when /\A.+\.csv\z/i
        load_from_path(@path_or_data)
      else
        load_data(@path_or_data)
      end
    end

    private
    def open_csv(path, **options)
      CSV.open(path, **options) do |csv|
        yield(csv)
      end
    end

    def parse_csv_data(data, **options)
      csv = CSV.new(data, **options)
      begin
        yield(csv)
      ensure
        csv.close
      end
    end

    def read_csv(csv)
      reader = CSVReader.new(csv)
      reader.read
    end

    def load_from_path(path)
      options = update_csv_parse_options(@options, :open_csv, path)
      open_csv(path, **options) do |csv|
        read_csv(csv)
      end
    end

    def load_data(data)
      options = update_csv_parse_options(@options, :parse_csv_data, data)
      parse_csv_data(data, **options) do |csv|
        read_csv(csv)
      end
    end

    ISO8601_CONVERTER = lambda do |field|
      begin
        encoded_field = field.encode(CSV::ConverterEncoding)
      rescue EncodingError
        field
      else
        begin
          Time.iso8601(encoded_field)
        rescue ArgumentError
          field
        end
      end
    end

    def update_csv_parse_options(options, create_csv, *args)
      return options unless options.empty?

      new_options = options.merge(converters: [:all, ISO8601_CONVERTER])
      __send__(create_csv, *args, **new_options) do |csv|
        row1 = csv.shift
        if row1.nil?
          new_options[:headers] = false
          return new_options
        end
        if row1.any?(&:nil?)
          new_options[:headers] = false
          return new_options
        end

        row2 = csv.shift
        return new_options if row2.nil?
        if row2.any?(&:nil?)
          new_options[:headers] = true
          return new_options
        end

        if row1.collect(&:class) != row2.collect(&:class)
          new_options[:headers] = true
          return new_options
        end

        new_options
      end
    end
  end
end
