# Patch IO::Buffered to not buffer reads when `sync?`
module IO::Buffered
  def read_byte : UInt8?
    check_open

    fill_buffer if !sync? && @in_buffer_rem.empty?
    if @in_buffer_rem.empty?
      return nil unless sync?

      byte = uninitialized UInt8
      if read(Slice.new(pointerof(byte), 1)) == 1
        byte
      else
        nil
      end
    else
      b = @in_buffer_rem[0]
      @in_buffer_rem += 1
      b
    end
  end

  # Buffered implementation of `IO#read(slice)`.
  def read(slice : Bytes)
    check_open

    count = slice.size
    return 0 if count == 0

    if @in_buffer_rem.empty?
      # If we are asked to read more than half the buffer's size,
      # read directly into the slice, as it's not worth the extra
      # memory copy.
      if sync? || count >= BUFFER_SIZE / 2
        return unbuffered_read(slice[0, count]).to_i
      else
        fill_buffer
        return 0 if @in_buffer_rem.empty?
      end
    end

    to_read = Math.min(count, @in_buffer_rem.size)
    slice.copy_from(@in_buffer_rem.pointer(to_read), to_read)
    @in_buffer_rem += to_read
    to_read
  end
end

class PChan(T)
  @reader_pipe : IO::Buffered
  @writer_pipe : IO::Buffered

  def initialize
    {% raise "Must be a struct" if T < Reference %}
    @reader_pipe, @writer_pipe = IO.pipe

    @reader_pipe.sync = true
    @writer_pipe.sync = true
  end

  def receive : T
    object_memory = Bytes.new(sizeof(T))
    @reader_pipe.read_fully(object_memory)
    object_memory.to_unsafe.as(T*).value
  end

  def send(object : T)
    object_memory = Bytes.new(pointerof(object).as(UInt8*), sizeof(T))
    @writer_pipe.write(object_memory)
  end
end
