use "../roaring" // replace with `use "roaring"` in your code

actor Main
  new create(env: Env) =>
    let roaring = Roaring
    env.out.print("Usage Example works")
