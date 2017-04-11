#!/usr/bin/env ruby

require "arrow"

fields = [
  Arrow::Field.new("uint8",  :uint8),
  Arrow::Field.new("uint16", :uint16),
  Arrow::Field.new("uint32", :uint32),
  Arrow::Field.new("uint64", :uint64),
  Arrow::Field.new("int8",   :int8),
  Arrow::Field.new("int16",  :int16),
  Arrow::Field.new("int32",  :int32),
  Arrow::Field.new("int64",  :int64),
  Arrow::Field.new("float",  :float),
  Arrow::Field.new("double", :double),
]
schema = Arrow::Schema.new(fields)

Arrow::IOFileOutputStream.open("/tmp/batch.arrow", false) do |output|
  Arrow::IPCFileWriter.open(output, schema) do |writer|
    uints = [1, 2, 4, 8]
    ints = [1, -2, 4, -8]
    floats = [1.1, -2.2, 4.4, -8.8]
    columns = [
      Arrow::UInt8Array.new(uints),
      Arrow::UInt16Array.new(uints),
      Arrow::UInt32Array.new(uints),
      Arrow::UInt64Array.new(uints),
      Arrow::Int8Array.new(ints),
      Arrow::Int16Array.new(ints),
      Arrow::Int32Array.new(ints),
      Arrow::Int64Array.new(ints),
      Arrow::FloatArray.new(floats),
      Arrow::DoubleArray.new(floats),
    ]

    record_batch = Arrow::RecordBatch.new(schema, 4, columns)
    writer.write_record_batch(record_batch)

    sliced_columns = columns.collect do |column|
      column.slice(1, 3)
    end
    record_batch = Arrow::RecordBatch.new(schema, 3, sliced_columns)
    writer.write_record_batch(record_batch)
  end
end
