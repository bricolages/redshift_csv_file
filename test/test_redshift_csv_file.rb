require 'test/unit'
require 'redshift_csv_file'
require 'stringio'

class TestRedshiftCsvFile < Test::Unit::TestCase
  def parse_row(line)
    r = RedshiftCsvFile.new(StringIO.new(line))
    r.read_row
  end

  def test_read_row
    assert_equal ['xxx', 'yyyy', 'zzz'],
      parse_row(%Q("xxx","yyyy","zzz"\n))

    assert_equal ['xxx', 'yyyy', 'zzz'],
      parse_row(%Q( "xxx" , "yyyy","zzz"\t\n))

    assert_equal ['x,x', "y\r\ny", 'z"z', 'a\\a'],
      parse_row(%Q("x\\,x","y\\r\\ny","z\\"z","a\\\\a"\n))

    assert_equal ['x,x', "y\ny", 'z"z', 'a\\a'],
      parse_row(%Q("x\\,x","y\\\ny","z\\"z","a\\\\a"\n))

    assert_equal ['981179', '2017-01-07', '6', 'show', '99', '3'],
      parse_row(%Q("981179","2017-01-07","6","show","99","3"\r\n))

    assert_equal ['981179', '2017-01-07', '6', '852', 'show', '{"page"=>"4"}', '1', '1'],
      parse_row(%Q("981179","2017-01-07","6","852","show","{\\"page\\"=>\\"4\\"}","1","1"\n))

    assert_raises RedshiftCsvFile::MalformedCSVException do
      parse_row(%Q("xxx,"yyy"))
    end
  end

  def parse_rows(text)
    r = RedshiftCsvFile.new(StringIO.new(text))
    rows = []
    r.each_row do |row|
      rows.push row
    end
    rows
  end

  def test_each_row
    assert_equal [
        ['xxx', 'yyy', 'zzz'],
        ['aaa', 'bbb', 'ccc']
      ],
      parse_rows(%Q("xxx","yyy","zzz"\n"aaa","bbb","ccc"\n))

    assert_equal [
        ['xxx', 'yyy', 'zzz'],
        ['aaa', 'bbb', 'ccc']
      ],
      parse_rows(%Q("xxx","yyy","zzz"\n"aaa","bbb","ccc"))

    assert_equal [
        ['xxx', 'yyy', 'zzz'],
        ['aaa', "b\nb", 'c"c']
      ],
      parse_rows(%Q("xxx","yyy","zzz"\n"aaa","b\\\nb","c\\"c"))
  end
end
