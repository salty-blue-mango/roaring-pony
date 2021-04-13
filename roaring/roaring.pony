"""
# Roaring Bitmap for Pony

This is the package documentation
"""

use "debug"


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

  fun ref unset(value: U16): Bool =>
    store.unset(value)

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
      try
        let container = _containers(loc)?
        container.contains(_Bits.storable(value))
      else
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
      try
        let container = _containers(loc)?
        container.set(_Bits.storable(value))
      else
        false
      end
    | (let loc: USize, _) =>
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
      try
        let container = _containers(loc)?
        container.flip(_Bits.storable(value))
      else
        false
      end
    | (let loc: USize, _) =>
      // lets assume get_container will always return valid indices
      try
        _containers.insert(loc, _Container.create(address, ArrayStore.create(_Bits.storable(value))))?
      end
      false
    end

  fun ref unset(value: U32): Bool =>
    """
    Removes the given `value` from, the set and
    returns true if the provided `value` was not in the set.
    """
    // TODO this assumes big-endianness
    let address = _Bits.address(value)
    match this._get_container(address)
    | (let loc: USize, true) =>
      try
        let container = _containers(loc)?
        container.unset(_Bits.storable(value))
      else
        true
      end
    | (let loc: USize, _) =>
      true
    end

  fun _get_container(address: U16): (USize, Bool) =>
    """
    binary search
    """
    BinarySearch.by[U16, _Container](address, _containers, {(c: _Container box): U16 => c.address})
