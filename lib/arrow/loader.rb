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

require "arrow/block-openable"

module Arrow
  class Loader < GObjectIntrospection::Loader
    class << self
      def load
        super("Arrow", Arrow)
      end
    end

    private
    def post_load(repository, namespace)
      require_libraries
    end

    def require_libraries
      require "arrow/array"
      require "arrow/array-builder"
      require "arrow/field"
      require "arrow/record-batch"
      require "arrow/tensor"

      require "arrow/file-reader"
      require "arrow/stream-reader"
    end

    def load_object_info(info)
      super

      klass = @base_module.const_get(rubyish_class_name(info))
      if klass.respond_to?(:open)
        klass.singleton_class.prepend(BlockOpenable)
      end
    end

    def rubyish_method_name(function_info, options={})
      if function_info.n_in_args == 1 and function_info.name == "get_value"
        "[]"
      else
        super
      end
    end
  end
end
