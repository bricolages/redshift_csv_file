# redshift_csv_file library

redshift_csv_file is a Redshift-specific CSV file parser in Ruby.
Amazon Redshift generates non-standard CSV format, special handling is required.

## Usage

```
require 'redshift_csv_file'

File.open('unloaded_file.csv') {|f|
  RedshiftCsvFile.new(f).each_row do |col1, col2, col3|
    p [col1, col2, col3]   # => ["value1", "value2", "value3"]
  end
}
```

## License

MIT license.
See LICENSE file for details.

## Author

Minero Aoki
