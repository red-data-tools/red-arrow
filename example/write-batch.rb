#!/usr/bin/env ruby

require "arrow"

fields = [
  Arrow::Field.new("count", :uint32),
]
schema = Arrow::Schema.new(fields)

Arrow::IO::FileOutputStream.open("/tmp/logs-batch.arrow", false) do |output|
  Arrow::IPC::FileWriter.open(output, schema) do |writer|
    counts = [1, 2, 4, 8]
    arrow_counts = Arrow::UInt32Array.new(counts)

    record_batch = Arrow::RecordBatch.new(schema, 4, [arrow_counts])
    writer.write_record_batch(record_batch)

    record_batch = Arrow::RecordBatch.new(schema, 3, [arrow_counts.slice(1, 3)])
    writer.write_record_batch(record_batch)
  end
end
