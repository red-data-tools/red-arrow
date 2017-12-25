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
    arrays = []
    arrays << Arrow::ChunkedArray.new([
                                        Arrow::UInt32Array.new([1, 2]),
                                        Arrow::UInt32Array.new([4, 8, 16]),
                                        Arrow::UInt32Array.new([32, 64]),
                                        Arrow::UInt32Array.new([128]),
                                      ])
    arrays << Arrow::ChunkedArray.new([
                                        Arrow::BooleanArray.new([
                                                                  true,
                                                                  false,
                                                                  nil,
                                                                ]),
                                        Arrow::BooleanArray.new([true]),
                                        Arrow::BooleanArray.new([true, false]),
                                        Arrow::BooleanArray.new([nil]),
                                        Arrow::BooleanArray.new([nil]),
                                      ])
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
end
