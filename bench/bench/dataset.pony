use "../../roaring"
use "files"
use "buffered"
use "collections"
use "ponyzip"

class RoaringDataset

  let _name: String
  let _path: FilePath
  let _stream: OutStream

  new create(base_path: FilePath, stream: OutStream, name': String) ? =>
    _name = name'
    _path = base_path.join(name' + ".zip")?
    _stream = stream
    if not _path.exists() then
      _stream.print("path '" + _path.path + "' does not exist or is not readable.")
      error
    end

  fun name(): String => _name

  fun load(): Roaring iso^ ? =>
    let archive =
      match Zip.open(_path)
      | let a: ZipArchive => a
      | let e: ZipError =>
        _stream.print(e.string())
        error
      end

    let r = recover Roaring end
    var elements: USize  = 0
    for stat in archive.stats() do
      let file = stat.open() as ZipFile
      let size = (stat.size as U64).usize()
      let content =
        try
          String.from_array(file.read(size)?)
        else
          _stream.print("Could not read " + size.string() + " from " + _path.path)
          error
        end

      // each file is a one-line CSV
      let splitted: Array[String val] val = content.split_by(",")
      let len = splitted.size()
      elements = elements + len
      for value in splitted.values() do
        let v =
          try
            value.clone().>strip().u32()?
          else
            _stream.print("Could not parse u32 from  \"" + value + "\".")
            error
          end
        r.set(v)
      end

      file.close()
    end
    archive.discard()
    //_stream.print("Loaded " + elements.string() + " items from " + _path.path + ".")

    r




