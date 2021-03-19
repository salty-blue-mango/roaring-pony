"""
# Roaring Bitmap for Pony

This is the package documentation
"""

class ref ArrayStore
  """
  max 4096 U16s
  """
  let _buffer: Array[U16]

  new ref create(initial: U16) =>
    _buffer = Array[U16].create(1)
    _buffer.push(initial)


type Store is ArrayStore // | BitmapStore | RunStore)

class ref _Container
  let address: U16
  let store: Store

  new ref create(address': U16, store': Store) =>
    address = address'
    store = store'


class ref Roaring
  """
  just a dummy placeholder
  """

  let _containers: Array[_Container] ref

  new create() =>
    _containers = Array[_Container].create(0)

  fun ref set(value: U32): Bool =>
    """
    TODO

    """
    let address = (value >> 16).u16()
    match this.get_container(address)
    | (let loc: USize, true) => None
    | (let loc: USize, false) =>
      // lets assume get_container will always return valid indices
      try
        _containers.insert(loc, _Container.create(address, ArrayStore.create(value.u16())))?
      end
    end
    false

  fun get_container(address: U16): (USize, Bool) =>
    """
    binary search
    """
    (0, false)

  fun contains(value: U32): Bool =>
    """
    TODO
    """
    false

