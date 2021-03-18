use "../roaring" // replace with `use "roaring"` in your code

actor Main
  new create(env: Env) =>
    let roaring = Roaring
    roaring.set(U32.max_value())
    env.out.print("Usage Example works")
