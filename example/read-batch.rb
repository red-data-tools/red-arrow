#!/usr/bin/env ruby

require "arrow"

Arrow::IO::MemoryMappedFile.open("/tmp/logs-batch.arrow", :read) do |input|
  Arrow::IPC::FileReader.open(input) do |reader|
    reader.each do |record_batch|
      record_batch.each do |record|
        p record[:count]
      end
    end
  end
end
