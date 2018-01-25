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

class CSVLoaderTest < Test::Unit::TestCase
  include Helper::Fixture

  sub_test_case(".load") do
    test("String: data: with header") do
      data = fixture_path("with-header.csv").read
      assert_equal(<<-TABLE, Arrow::CSVLoader.load(data).to_s)
	name	score
0	alice	   10
1	bob 	   29
2	chris	   -1
      TABLE
    end

    test("String: data: without header") do
      data = fixture_path("without-header.csv").read
      assert_equal(<<-TABLE, Arrow::CSVLoader.load(data).to_s)
	0	1
0	alice	10
1	bob	29
2	chris	-1
      TABLE
    end

    test("String: path: with header") do
      path = fixture_path("with-header.csv").to_s
      assert_equal(<<-TABLE, Arrow::CSVLoader.load(path).to_s)
	name	score
0	alice	   10
1	bob 	   29
2	chris	   -1
      TABLE
    end

    test("String: path: without header") do
      path = fixture_path("without-header.csv").to_s
      assert_equal(<<-TABLE, Arrow::CSVLoader.load(path).to_s)
	0	1
0	alice	10
1	bob	29
2	chris	-1
      TABLE
    end

    test("Pathname: with header") do
      path = fixture_path("with-header.csv")
      assert_equal(<<-TABLE, Arrow::CSVLoader.load(path).to_s)
	name	score
0	alice	   10
1	bob 	   29
2	chris	   -1
      TABLE
    end

    test("Pathname: without header") do
      path = fixture_path("without-header.csv")
      assert_equal(<<-TABLE, Arrow::CSVLoader.load(path).to_s)
	0	1
0	alice	10
1	bob	29
2	chris	-1
      TABLE
    end

    test("null: with double quote") do
      path = fixture_path("null-with-double-quote.csv").to_s
      assert_equal(<<-TABLE, Arrow::CSVLoader.load(path).to_s)
	name	score
0	alice	   10
1	bob 	     
2	chris	   -1
      TABLE
    end

    test("null: without double quote") do
      path = fixture_path("null-without-double-quote.csv").to_s
      assert_equal(<<-TABLE, Arrow::CSVLoader.load(path).to_s)
	name	score
0	alice	   10
1	bob 	     
2	chris	   -1
      TABLE
    end
  end
end
