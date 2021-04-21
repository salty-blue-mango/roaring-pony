class ref ArrayStore
  """
  Roaring store encoding set bits as U16 entries in the _buffer array.

  Limited to max. 4096 entries.
  """
  embed _buffer: Array[U16]

  new ref create(initial: U16) =>
    _buffer = Array[U16].create(1)
    _buffer.push(initial)

  fun ref set(value: U16): Bool =>
    match BinarySearch.apply[U16](value, _buffer)
    | (let loc: USize, true) => true
    | (let loc: USize, _) =>
      try
        _buffer.insert(loc, value)?
      end
      false
    end

  fun ref flip(value: U16): Bool =>
    match BinarySearch.apply[U16](value, _buffer)
    | (let loc: USize, false) =>
      set(value)
      false
    | (let loc: USize, _) =>
      try
        _buffer.delete(loc)?
      end
      true
    end

  fun ref unset(value: U16): Bool =>
    match BinarySearch.apply[U16](value, _buffer)
    | (let loc: USize, false) => true
    | (let loc: USize, _) =>
      try
        _buffer.delete(loc)?
      end
      false
    end

  fun contains(value: U16): Bool =>
    """
    Returns true if the entry was found, false otherwise.
    """
    (let _, let found) = BinarySearch.apply[U16](value, _buffer)
    found

