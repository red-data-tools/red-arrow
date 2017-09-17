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

class ArrayBuilderTest < Test::Unit::TestCase
  sub_test_case(".build") do
    test("empty") do
      array = Arrow::Int32ArrayBuilder.build([])
      assert_equal([],
                   array.to_a)
    end

    test("values") do
      array = Arrow::Int32ArrayBuilder.build([1, -2])
      assert_equal([1, -2],
                   array.to_a)
    end

    test("values, nils") do
      array = Arrow::Int32ArrayBuilder.build([1, -2, nil, nil])
      assert_equal([1, -2, nil, nil],
                   array.to_a)
    end

    test("values, nils, values") do
      array = Arrow::Int32ArrayBuilder.build([1, -2, nil, nil, 3, -4])
      assert_equal([1, -2, nil, nil, 3, -4],
                   array.to_a)
    end

    test("values, nils, values, nils") do
      array = Arrow::Int32ArrayBuilder.build([1, -2, nil, nil, 3, -4, nil, nil])
      assert_equal([1, -2, nil, nil, 3, -4, nil, nil],
                   array.to_a)
    end

    test("nils") do
      array = Arrow::Int32ArrayBuilder.build([nil, nil])
      assert_equal([nil, nil],
                   array.to_a)
    end

    test("nils, values") do
      array = Arrow::Int32ArrayBuilder.build([nil, nil, 3, -4])
      assert_equal([nil, nil, 3, -4],
                   array.to_a)
    end

    test("nils, values, nil") do
      array = Arrow::Int32ArrayBuilder.build([nil, nil, 3, -4, nil, nil])
      assert_equal([nil, nil, 3, -4, nil, nil],
                   array.to_a)
    end

    test("nils, values, nil, values") do
      array = Arrow::Int32ArrayBuilder.build([nil, nil, 3, -4, nil, nil, 5, -6])
      assert_equal([nil, nil, 3, -4, nil, nil, 5, -6],
                   array.to_a)
    end
  end
end
