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

class TableTest < Test::Unit::TestCase
  test("#columns") do
    fields = [
      Arrow::Field.new("count", :uint32),
      Arrow::Field.new("visible", :boolean),
    ]
    schema = Arrow::Schema.new(fields)
    columns = [
      Arrow::Column.new(fields[0],
                        Arrow::UInt32Array.new([1, 2, 4, 8])),
      Arrow::Column.new(fields[1],
                        Arrow::BooleanArray.new([true, false, nil, true])),
    ]
    table = Arrow::Table.new(schema, columns)
    assert_equal(["count", "visible"],
                 table.columns.collect(&:name))
  end

  test("#slice") do
    fields = [
      Arrow::Field.new("count", :uint32),
      Arrow::Field.new("visible", :boolean),
    ]
    schema = Arrow::Schema.new(fields)
    count_arrays = [
      Arrow::UInt32Array.new([1, 2]),
      Arrow::UInt32Array.new([4, 8, 16]),
      Arrow::UInt32Array.new([32, 64]),
      Arrow::UInt32Array.new([128]),
    ]
    visible_arrays = [
      Arrow::BooleanArray.new([true, false, nil]),
      Arrow::BooleanArray.new([true]),
      Arrow::BooleanArray.new([true, false]),
      Arrow::BooleanArray.new([nil]),
      Arrow::BooleanArray.new([nil]),
    ]
    arrays = [
      Arrow::ChunkedArray.new(count_arrays),
      Arrow::ChunkedArray.new(visible_arrays),
    ]
    columns = [
      Arrow::Column.new(fields[0], arrays[0]),
      Arrow::Column.new(fields[1], arrays[1]),
    ]
    table = Arrow::Table.new(schema, columns)
    target_rows = Arrow::BooleanArray.new([nil, true, true, false, true, false, true, true])
    assert_equal(<<-TABLE, table.slice(target_rows).to_s)
	count	visible
0	    2	  false
1	    4	       
2	   16	   true
3	   64	       
4	  128	       
    TABLE
  end

  sub_test_case("#[]") do
    setup do
      @count_field = Arrow::Field.new("count", :uint32)
      @visible_field = Arrow::Field.new("visible", :boolean)
      schema = Arrow::Schema.new([@count_field, @visible_field])
      count_arrays = [
        Arrow::UInt32Array.new([1, 2]),
        Arrow::UInt32Array.new([4, 8, 16]),
        Arrow::UInt32Array.new([32, 64]),
        Arrow::UInt32Array.new([128]),
      ]
      visible_arrays = [
        Arrow::BooleanArray.new([true, false, nil]),
        Arrow::BooleanArray.new([true]),
        Arrow::BooleanArray.new([true, false]),
        Arrow::BooleanArray.new([nil]),
        Arrow::BooleanArray.new([nil]),
      ]
      @count_array = Arrow::ChunkedArray.new(count_arrays)
      @visible_array = Arrow::ChunkedArray.new(visible_arrays)
      @count_column = Arrow::Column.new(@count_field, @count_array)
      @visible_column = Arrow::Column.new(@visible_field, @visible_array)
      @table = Arrow::Table.new(schema, [@count_column, @visible_column])
    end

    test("[String]") do
      assert_equal(@count_column, @table["count"])
    end

    test("[Symbol]") do
      assert_equal(@visible_column, @table[:visible])
    end

    test("[String, Symbol]") do
      assert_equal(Arrow::Table.new(@table.schema,
                                    [@visible_column, @count_column]).to_s,
                   @table["visible", :count].to_s)
    end
  end
end
