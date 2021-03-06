require 'strscan'

# Reads CSV file generated by Redshift UNLOAD statement (with option ADDQUOTES ESCAPE).
# UNLOAD escapes data by '\' (backslash character), we cannot use standard CSV class.
class RedshiftCsvFile
  class MalformedCSVException < StandardError; end

  # f :: IO
  def initialize(f)
    @f = f
    @s = ScanBuffer.new(@f)
  end

  def each_row
    s = @s
    while row = parse_row(@s)
      yield row
    end
  end

  alias each each_row

  def read_row
    return nil if @s.eof?
    parse_row(@s)
  end

  private

  def parse_row(s)
    s.next_row or return nil
    row = []
    begin
      first = false
      column = s.scan_column
      unless column
        raise MalformedCSVException, "CSV parse error: unterminated column or row at line #{s.lineno}"
      end
      row.push unescape_column(column)
    end while s.read_separator
    unless s.read_eol
      raise MalformedCSVException, "CSV parse error: missing column separator at line #{s.lineno}"
    end
    row
  end

  UNESCAPE_MAP = {
    '\\t' => "\t",
    '\\r' => "\r",
    '\\n' => "\n",
  }

  def unescape_column(col)
    charmap = UNESCAPE_MAP
    col[1...-1].gsub(/\\./m) {|s| charmap[s] || s[1,1] }
  end

  class ScanBuffer
    def initialize(f)
      @f = f
      @s = StringScanner.new("")
      @eof = false
    end

    def eof?
      @s.eos? && @eof
    end

    def lineno
      @f.lineno
    end

    def next_row
      fill_buffer
    end

    MAX_COLUMN_LENGTH = (1.2 * (1024 ** 3)).to_i   # 1.2MB

    def scan_column
      s = @s
      s.skip(/[ \t]+/)
      until column = s.scan(/"(?:\\.|[^"\\])*"/m)
        fill_buffer or return nil
        return nil if s.eos?
        if s.rest_size > MAX_COLUMN_LENGTH
          raise MalformedCSVException, "CSV parse error: too long column at line #{@f.lineno}"
        end
      end
      column
    end

    def fill_buffer
      line = @f.gets
      if line
        @s << line
        true
      else
        @eof = true
        false
      end
    end

    def read_separator
      @s.skip(/[ \t]*,/)
    end

    def read_eol
      @s.skip(/[ \t\r]*(?:\n|\z)/)
    end
  end
end
