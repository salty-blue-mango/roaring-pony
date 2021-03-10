use "ponytest"

primitive PrivateTests is TestList
  fun tag tests(test: PonyTest) =>
    """
    This is the place for tests of
    private parts of this library.

    Implement those tests as private classes like the `_DummyTest` below.
    Otherwise they might show up in documentation.
    """
    test(_DummyTest)

class iso _DummyTest is UnitTest
  fun name(): String => "private dummy"

  fun apply(h: TestHelper) =>
    h.assert_eq[USize](1, 1)
