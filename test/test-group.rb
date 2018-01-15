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

class GroupTest < Test::Unit::TestCase
  include Helper::Fixture

  def setup
    raw_table = {
      :group_key1 => Arrow::UInt8Array.new([1, 1, 2, 3, 3, 3]),
      :group_key2 => Arrow::UInt8Array.new([1, 1, 1, 1, 2, 2]),
      :int => Arrow::Int32Array.new([-1, -2, nil, -4, -5, -6]),
      :uint => Arrow::UInt32Array.new([1, nil, 3, 4, 5, 6]),
      :float => Arrow::FloatArray.new([nil, 2.2, 3.3, 4.4, 5.5, 6.6]),
      :string => Arrow::StringArray.new(["a", "b", "c", nil, "e", "f"]),
    }
    @table = Arrow::Table.new(raw_table)
  end

  sub_test_case("#count") do
    test("single") do
      assert_equal(<<-TABLE, @table.group(:group_key1).count.to_s)
	group_key1	group_key2	int	uint	float	string
0	         1	         2	  2	   1	    1	     2
1	         2	         1	  0	   1	    1	     1
2	         3	         3	  3	   3	    3	     2
      TABLE
    end

    test("multiple") do
      assert_equal(<<-TABLE, @table.group(:group_key1, :group_key2).count.to_s)
	group_key1	group_key2	int	uint	float	string
0	         1	         1	  2	   1	    1	     2
1	         2	         1	  0	   1	    1	     1
2	         3	         1	  1	   1	    1	     0
3	         3	         2	  2	   2	    2	     2
      TABLE
    end
  end
end
