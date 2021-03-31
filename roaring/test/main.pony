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

  fun gen(): Generator[Array[U32]] => GenerateMediumArray()

  fun property(arg1: Array[U32], h: PropertyHelper) =>
    let roaring = Roaring
    for value in arg1.values() do
      roaring.set(value)  // Set value (may have been previously set)
      h.assert_true(roaring.contains(value))  // Does contain value
    end

class MediumArraySetTwice is Property1[Array[U32]]
  fun name(): String => "Medium-sized array; set() returns status of if previously set()"

  fun gen(): Generator[Array[U32]] => GenerateMediumArray()

  fun property(arg1: Array[U32], h: PropertyHelper) =>
    let roaring = Roaring
    for value in arg1.values() do
      roaring.set(value)  // Set value (may have been previously set)
      h.assert_true(roaring.set(value))  // Value previously set
    end

primitive GenerateMediumArray
  fun apply(): Generator[Array[U32]] =>
    Generators.array_of[U32](where
        gen = Generators.u32(U32.min_value(), U32.max_value()),
        min = 4096.mul(2),
        max = 4096.mul(4))