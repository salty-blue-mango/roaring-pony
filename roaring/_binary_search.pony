use "debug"

// TODO: test more thoroughly
primitive BinarySearch
  fun apply[T: Comparable[T] #read](needle: T, haystack: ReadSeq[T]): (USize, Bool) =>
    """
    Perform a binary search for `needle` on `haystack`.

    Returns the result as a 2-tuple of either:
    * the index of the found element and `true` if the search was successful, or
    * the index where to insert the `needle` to maintain a sorted `haystack` and `false`
    """
    try
      var i = USize(0)
      var l = USize(0)
      var r = haystack.size()
      var idx_adjustment: USize = 0
      while l < r do
        i = (l + r).fld(2)
        let elem = haystack(i)?
        match needle.compare(elem)
        | Less =>
          idx_adjustment = 0
          r = i
        | Equal => return (i, true)
        | Greater =>
          // insert index needs to be adjusted by 1 if greater
          idx_adjustment = 1
          l = i + 1
        end
      end
      (i + idx_adjustment, false)
    else
      // shouldnt happen
      Debug("invalid haystack access.")
      (0, false)
    end

  fun by[T: Comparable[T] #read, X: Any #read](needle: T, haystack: ReadSeq[X], retrieve: {(box->X): T} val): (USize, Bool) =>
    try
      var i = USize(0)
      var l = USize(0)
      var r = haystack.size()
      var idx_adjustment: USize = 0
      while l < r do
        i = (l + r).fld(2)
        let elem: T = retrieve(haystack(i)?)
        match needle.compare(elem)
        | Less =>
          idx_adjustment = 0
          r = i
        | Equal => return (i, true)
        | Greater =>
          idx_adjustment = 1
          l = i + 1
        end
      end
      (i + idx_adjustment, false)
    else
      // shouldnt happen
      Debug("invalid haystack access.")
      (0, false)
    end
