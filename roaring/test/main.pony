use "ponytest"
use ".."

actor Main is TestList
  new create(env: Env) => PonyTest(env, this)

  new make() => None

  fun tag tests(test: PonyTest) =>
    // register test cases to run here
    test(DummyTest)

    // include the tests of the private API here
    PrivateTests.tests(test)

class iso DummyTest is UnitTest
  fun name(): String => "public dummy"

  fun apply(h: TestHelper) =>
    h.assert_eq[USize](1, 1)
