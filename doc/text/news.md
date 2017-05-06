# News

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
