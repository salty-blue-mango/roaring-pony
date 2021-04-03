"""
# Roaring Bitmap for Pony

This is the package documentation
"""

use "debug"

class ref ArrayStore
  """
  max 4096 U16s
  """
  let _buffer: Array[U16]

  new ref create(initial: U16) =>
    _buffer = Array[U16].create(1)
    _buffer.push(initial)

  fun ref set(value: U16): Bool =>
    match BinarySearch.apply[U16](value, _buffer)
    | (let loc: USize, true) =>
      Debug(value.string() + " found at " + loc.string())
      true
    | (let loc: USize, _) =>
      try
        _buffer.insert(loc, value)?
      else
        Debug("Bad loc from _binary_search: " + loc.string())
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
      else
        Debug("Bad loc from _binary_search: " + loc.string())
      end
      true
    end

  fun contains(value: U16): Bool =>
    """
    Returns true if the entry was found, false otherwise.
    """
    (let _, let found) = BinarySearch.apply[U16](value, _buffer)
    found

type Store is ArrayStore // | BitmapStore | RunStore)


class ref _Container
  let address: U16
  let store: Store

  new ref create(address': U16, store': Store) =>
    address = address'
    store = store'

  fun ref set(value: U16): Bool =>
    store.set(value)

  fun ref flip(value: U16): Bool =>
    store.flip(value)

  fun contains(value: U16): Bool =>
    """
    Returns true if the entry was found, false otherwise.
    """
    store.contains(value)


class ref Roaring
  """
  """

  let _containers: Array[_Container] ref

  new create() =>
    _containers = Array[_Container].create(0)

  fun contains(value: U32): Bool =>
    """
    Returns true if the entry was found, false otherwise.
    """
    let address = _Bits.address(value)
    match this._get_container(address)
    | (let loc: USize, true) =>
      Debug("container for " + address.string() + " found at " + loc.string())
      try
        let container = _containers(loc)?
        container.contains(_Bits.storable(value))
      else
        Debug("invalid location returned from get_container " + loc.string())
        false
      end
    else
      false
    end

  fun ref set(value: U32): Bool =>
    """
    Adds the given `value` to the set and
    returns true if the provided `value` has already been in the set.
    """
    // TODO this assumes big-endianness
    let address = _Bits.address(value)
    match this._get_container(address)
    | (let loc: USize, true) =>
      Debug("container for " + address.string() + " found at " + loc.string())
      try
        let container = _containers(loc)?
        container.set(_Bits.storable(value))
      else
        Debug("invalid location returned from get_container " + loc.string())
        false
      end
    | (let loc: USize, _) =>
      Debug("container for " + address.string() + " not found, insert at " + loc.string())
      // lets assume get_container will always return valid indices
      try
        _containers.insert(loc, _Container.create(address, ArrayStore.create(_Bits.storable(value))))?
      end
      false
    end

  fun ref flip(value: U32): Bool =>
    """
    Flips the value between being in the set or not in the set.
    Returns true if the value was in the set prior to the flip.
    """
    // TODO this assumes big-endianness
    let address = _Bits.address(value)
    match this._get_container(address)
    | (let loc: USize, true) =>
      Debug("container for " + address.string() + " found at " + loc.string())
      try
        let container = _containers(loc)?
        container.flip(_Bits.storable(value))
      else
        Debug("invalid location returned from get_container " + loc.string())
        false
      end
    | (let loc: USize, _) =>
      Debug("container for " + address.string() + " not found, insert at " + loc.string())
      // lets assume get_container will always return valid indices
      try
        _containers.insert(loc, _Container.create(address, ArrayStore.create(_Bits.storable(value))))?
      end
      false
    end

  fun _get_container(address: U16): (USize, Bool) =>
    """
    binary search
    """
    BinarySearch.by[U16, _Container](address, _containers, {(c: _Container box): U16 => c.address})
