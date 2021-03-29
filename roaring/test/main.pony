use "ponytest"
use "ponycheck"
use ".."

actor Main is TestList
  new create(env: Env) => PonyTest(env, this)

  new make() => None

  fun tag tests(test: PonyTest) =>
    // register test cases to run here
    test(DummyTest)
    test(SetTest)
    test(Property1UnitTest[U32](SetContains))

    // include the tests of the private API here
    PrivateRoaringTests.tests(test)

class iso DummyTest is UnitTest
  fun name(): String => "public dummy"

  fun apply(h: TestHelper) =>
    h.assert_eq[USize](1, 1)

class iso SetTest is UnitTest
  fun name(): String => "set"

  fun apply(h: TestHelper) =>
    let roaring = Roaring
    h.assert_false(roaring.set(U32(1)))
    h.assert_true(roaring.set(U32(1)))
    h.assert_false(roaring.set(U32(2)))
    h.assert_true(roaring.set(U32(2)))
    h.assert_false(roaring.set(U32(0)))
    h.assert_false(roaring.set(U32.max_value()))

class SetContains is Property1[U32]
  fun name(): String => "Bitmaps contains values after set"

  fun gen(): Generator[U32] => Generators.u32(U32.min_value(), U32.max_value())

  fun property(arg1: U32, h: PropertyHelper) =>
    let roaring = Roaring
    roaring.set(arg1)
    h.assert_true(roaring.contains(arg1))