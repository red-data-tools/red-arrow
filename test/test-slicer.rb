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

class SlicerTest < Test::Unit::TestCase
  def setup
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

  sub_test_case("column ==") do
    test("nil") do
      sliced_table = @table.slice do |slicer|
        slicer.visible == nil
      end
      assert_equal(<<-TABLE, sliced_table.to_s)
	count	visible
0	    4	       
1	   64	       
2	  128	       
      TABLE
    end

    test("value") do
      sliced_table = @table.slice do |slicer|
        slicer.visible == true
      end
      assert_equal(<<-TABLE, sliced_table.to_s)
	count	visible
0	    1	true   
1	    8	true   
2	   16	true   
      TABLE
    end
  end

  sub_test_case("!(column ==)") do
    test("nil") do
      sliced_table = @table.slice do |slicer|
        !(slicer.visible == nil)
      end
      assert_equal(<<-TABLE, sliced_table.to_s)
	count	visible
0	    1	true   
1	    2	false  
2	    8	true   
3	   16	true   
4	   32	false  
      TABLE
    end

    test("value") do
      sliced_table = @table.slice do |slicer|
        !(slicer.visible == true)
      end
      assert_equal(<<-TABLE, sliced_table.to_s)
	count	visible
0	    2	false  
1	   32	false  
      TABLE
    end
  end

  sub_test_case("column !=") do
    test("nil") do
      sliced_table = @table.slice do |slicer|
        slicer.visible != nil
      end
      assert_equal(<<-TABLE, sliced_table.to_s)
	count	visible
0	    1	true   
1	    2	false  
2	    8	true   
3	   16	true   
4	   32	false  
      TABLE
    end

    test("value") do
      sliced_table = @table.slice do |slicer|
        slicer.visible != true
      end
      assert_equal(<<-TABLE, sliced_table.to_s)
	count	visible
0	    2	false  
1	   32	false  
      TABLE
    end
  end

  test("column < value") do
    sliced_table = @table.slice do |slicer|
      slicer.count < 16
    end
    assert_equal(<<-TABLE, sliced_table.to_s)
	count	visible
0	    1	true   
1	    2	false  
2	    4	       
3	    8	true   
    TABLE
  end

  test("!(column < value)") do
    sliced_table = @table.slice do |slicer|
      !(slicer.count < 16)
    end
    assert_equal(<<-TABLE, sliced_table.to_s)
	count	visible
0	   16	true   
1	   32	false  
2	   64	       
3	  128	       
    TABLE
  end

  test("column <= value") do
    sliced_table = @table.slice do |slicer|
      slicer.count <= 16
    end
    assert_equal(<<-TABLE, sliced_table.to_s)
	count	visible
0	    1	true   
1	    2	false  
2	    4	       
3	    8	true   
4	   16	true   
    TABLE
  end

  test("!(column <= value)") do
    sliced_table = @table.slice do |slicer|
      !(slicer.count <= 16)
    end
    assert_equal(<<-TABLE, sliced_table.to_s)
	count	visible
0	   32	false  
1	   64	       
2	  128	       
    TABLE
  end

  test("column > value") do
    sliced_table = @table.slice do |slicer|
      slicer.count > 16
    end
    assert_equal(<<-TABLE, sliced_table.to_s)
	count	visible
0	   32	false  
1	   64	       
2	  128	       
    TABLE
  end

  test("!(column > value)") do
    sliced_table = @table.slice do |slicer|
      !(slicer.count > 16)
    end
    assert_equal(<<-TABLE, sliced_table.to_s)
	count	visible
0	    1	true   
1	    2	false  
2	    4	       
3	    8	true   
4	   16	true   
    TABLE
  end

  test("column >= value") do
    sliced_table = @table.slice do |slicer|
      slicer.count >= 16
    end
    assert_equal(<<-TABLE, sliced_table.to_s)
	count	visible
0	   16	true   
1	   32	false  
2	   64	       
3	  128	       
    TABLE
  end

  test("!(column >= value)") do
    sliced_table = @table.slice do |slicer|
      !(slicer.count >= 16)
    end
    assert_equal(<<-TABLE, sliced_table.to_s)
	count	visible
0	    1	true   
1	    2	false  
2	    4	       
3	    8	true   
    TABLE
  end
end
