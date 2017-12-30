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

class SearchableTest < Test::Unit::TestCase
  def setup
    @scores = Arrow::Column.new(Arrow::Field.new("score", :int32),
                                Arrow::Int32Array.new([10, -1, nil, 2, 29]))
  end

  sub_test_case("#==") do
    test("same class") do
      same_value_scores =
        Arrow::Column.new(Arrow::Field.new("score", :int32),
                          Arrow::Int32Array.new(@scores.to_a))
      assert do
        @scores == same_value_scores
      end
    end

    test("number") do
      assert_equal(Arrow::BooleanArray.new([false, true, nil, false, false]),
                   @scores == -1)
    end

    test("nil") do
      assert_equal(Arrow::BooleanArray.new([false, false, true, false, false]),
                   @scores == nil)
    end
  end
end
