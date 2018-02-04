# News

## 0.8.2 - 2018-02-04

### Improvements

  * `Arrow::Table#size`: Added.

  * `Arrow::Table#length`: Added.

  * `Arrow::Table#pack`: Added.

  * `Arrow::Column#pack`: Added.

  * `Arrow::ChunkedArray#pack`: Added.

  * `Arrow::Column#reverse_each`: Added.

  * `Arrow::Table#slice`: Added negative integer support.

  * `Arrow::Slicer::ColumnCondition#in?`: Added.

  * `Arrow::Table#group`: Added.

  * `Arrow::ChunkedArray#null?`: Added.

  * `Arrow::Column#null?`: Added.

  * `Arrow::Group`: Added.

  * `Arrow::CSVLoader`: Changed to treat `""` as a null value instead
    of empty string.

  * `Arrow::Table#[]`: Stopped to accept multiple column name.

  * `Arrow::ChunkedArray#valid?`: Added.

  * `Arrow::Column#valid?`: Added.

  * `Arrow::Slicer::ColumnCondition#valid?`: Added.

### Fixes

  * `Arrow::TableFormatter`: Fixed a bug that too much records are
    formatted.

## 0.8.1 - 2018-01-05

### Improvements

  * `Arrow::ArrayBuilder.build`: Added generic array build support.

  * `Arrow::Table#save`: Added.

  * `Arrow::Table.load`: Added.

  * `Arrow::CSVLoader`: Added.

  * `Arrow::CSVReader.read`: Removed.

## 0.8.0 - 2018-01-04

### Improvements

  * Required Apache Arrow 0.8.0.

  * Update README. [GitHub#5][Patch by mikisou]

  * `Arrow::Table#each_record_batch`: Added.

  * `Arrow::ArrayBuilder#build`: Added.

  * `Arrow::CSVReader`: Added.

  * `Arrow::Array#[]`: Added `NULL` support.

  * `Arrow::TimestampArray`: Added.

  * `Arrow::Table#to_s`: Added table style format.

  * `Arrow::Table#slice`: Added.

  * `Arrow::Table#[]`: Added.

  * `Arrow::Table`: Added dynamic column name reader.

  * `Arrow::Table#merge`: Added.

  * `Arrow::Table#remove_column`: Added column name support.

  * `Arrow::Table#select_columns`: Added.

### Thanks

  * mikisou

## 0.4.1 - 2017-09-19

### Improvements

  * `Arrow::Array.new`: Improved performance.

### Fixes

  * `Arrow::Buffer`: Fixed a crash on GC.

## 0.4.0 - 2017-05-18

### Improvements

  * `Arrow::StringArray#[]`: Changed to return `String` instead of
    `GLib::Bytes`.

## 0.3.1 - 2017-05-17

### Improvements

  * `Arrow::MemoryMappedInputStream`: Renamed from
    `Arrow::MemoryMappedFile`.

  * `Arrow::RecordBatchStreamReader`: Renamed from
    `Arrow::StreamReader`.

  * `Arrow::RecordBatchFileReader`: Renamed from
    `Arrow::FileReader`.

  * `Arrow::RecordBatchStreamWriter`: Renamed from
    `Arrow::StreamWriter`.

  * `Arrow::RecordBatchFileWriter`: Renamed from
    `Arrow::FileWriter`.

  * `Arrow::Column#each`: Added.

  * `Arrow::ChunkedColumn#each`: Added.

  * `Arrow::Table#columns`: Added.

  * `Arrow::Table#each_column`: Added.

  * Supported auto native package install on install.

## 0.3.0 - 2017-05-06

### Improvements

  * `Arrow::Record#to_h`: Added.

  * `#to_arrow`: Added convenience methods for polymorphism.

  * Supported Apache Arrow 0.3.0.

## 0.2.2 - 2017-04-24

### Improvements

  * `Arrow::RecordBatch#each`: Supported reusing record object for
    performance.

  * ``Arrow::IO`: Unified into `Arrow`.

  * ``Arrow::IPC`: Unified into `Arrow`.

## 0.2.1 - 2017-03-23

### Improvements

  * Added `Arrow::IPC::FileReader#each`.

### Fixes

  * Fixed a bug that `Arrow::Record#[]` doesn't work.

## 0.2.0 - 2017-03-14

Initial release!!!
