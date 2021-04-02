use "ponytest"
use "ponycheck"
use ".."

actor Main is TestList
  new create(env: Env) => PonyTest(env, this)

  new make() => None

  fun tag tests(test: PonyTest) =>
    // register test cases to run here
    test(Property1UnitTest[U32](SetContains))
    test(Property1UnitTest[U32](SetTwice))
    test(Property1UnitTest[Array[U32]](MediumArraySetContains))
    test(Property1UnitTest[Array[U32]](MediumArraySetTwice))

    // include the tests of the private API here
    PrivateRoaringTests.tests(test)

class SetContains is Property1[U32]
  fun name(): String => "contains() is true after set()"

  fun gen(): Generator[U32] => Generators.u32(U32.min_value(), U32.max_value())

  fun property(arg1: U32, h: PropertyHelper) =>
    let roaring = Roaring
    h.assert_false(roaring.contains(arg1))  // Not much good as a test if true here
    h.assert_false(roaring.set(arg1))  // Value not previously set
    h.assert_true(roaring.contains(arg1))  // Does contain value

class SetTwice is Property1[U32]
  fun name(): String => "set() returns status of if previously set()"

  fun gen(): Generator[U32] => Generators.u32(U32.min_value(), U32.max_value())

  fun property(arg1: U32, h: PropertyHelper) =>
    let roaring = Roaring
    h.assert_false(roaring.set(arg1))  // Value not previously set
    h.assert_true(roaring.set(arg1))  // Value previously set

class MediumArraySetContains is Property1[Array[U32]]
  fun name(): String => "Medium-sized array; contains() is true after set()"

  fun gen(): Generator[Array[U32]] => GenerateMediumUniqueArray()

  fun property(arg1: Array[U32], h: PropertyHelper) =>
    let roaring = Roaring
    for value in arg1.values() do
      h.assert_false(roaring.contains(value))  // Not much good as a test if true here
      h.assert_false(roaring.set(value))  // Value not previously set
      h.assert_true(roaring.contains(value))  // Does contain value
    end

class MediumArraySetTwice is Property1[Array[U32]]
  fun name(): String => "Medium-sized array; set() returns status of if previously set()"

  fun gen(): Generator[Array[U32]] => GenerateMediumUniqueArray()

  fun property(arg1: Array[U32], h: PropertyHelper) =>
    let roaring = Roaring
    for value in arg1.values() do
      h.assert_false(roaring.set(value))  // Value not previously set
      h.assert_true(roaring.set(value))  // Value previously set
    end

primitive GenerateMediumArray
  fun apply(): Generator[Array[U32]] =>
    Generators.array_of[U32](where
      gen = Generators.u32(U32.min_value(), U32.max_value()),
      min = 4096.mul(2),
      max = 4096.mul(4))

primitive GenerateMediumUniqueArray
  """
  Generate a medium-sized array of unique U32 values.

  TODO: This currently uses a post-fact filter for minimum size which results in
  longer runtimes to produce a properly sized array. A faster procedure is desired.
  One possible route is using collections.Range(U32.min_value(), U32.max_value(), <non-looping step size>)
  followed by a random.shuffle(array)
  """
  fun apply(): Generator[Array[U32]] =>
    let min: USize = 4096.mul(2)
    let max: USize = 4096.mul(4)
    let hashset: Generator[HashSet[U32, HashEq[U32] val] ref] box =
      Generators.set_of[U32](where
        gen = Generators.u32(U32.min_value(), U32.max_value()),
        max = max
      )
    hashset
      .filter({ (set) => (set, (min <= set.size())) })
      .map[Array[U32]]({ 
        (set) => 
          let array: Array[U32] = Array[U32].create(set.size())
          for value in set.values() do
            array.push(value)
          end
          array
      })
