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
  class DataType
    def numeric?
      false
    end
  end

  class Int8DataType
    def numeric?
      true
    end
  end

  class Int16DataType
    def numeric?
      true
    end
  end

  class Int32DataType
    def numeric?
      true
    end
  end

  class Int64DataType
    def numeric?
      true
    end
  end

  class UInt8DataType
    def numeric?
      true
    end
  end

  class UInt16DataType
    def numeric?
      true
    end
  end

  class UInt32DataType
    def numeric?
      true
    end
  end

  class UInt64DataType
    def numeric?
      true
    end
  end

  class FloatDataType
    def numeric?
      true
    end
  end

  class DoubleDataType
    def numeric?
      true
    end
  end
end
