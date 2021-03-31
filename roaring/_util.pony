primitive _Bits 
  """
  Primitive for having a single source of truth for when we un-assume endianness
  """

  fun most_sig(value: U32): U16 => (value >> (value.bitwidth() / 2)).u16()
  fun address(value: U32): U16 => most_sig(value)

  fun least_sig(value: U32): U16 => value.u16()
  fun storable(value: U32): U16 => least_sig(value)