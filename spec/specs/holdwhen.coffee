# build-dependencies: startwith, filter, delay, interval, take, bus

describe "EventStream.holdWhen", ->
  describe "Keeps events on hold when a property is true", ->
    expectStreamTimings(
      ->
        src = series(2, [1,2,3,4])
        valve = series(2, [true, false, true, false]).delay(1).toProperty()
        src.holdWhen(valve)
      [[2, 1], [5, 2], [6, 3], [9, 4]])
  describe "Holds forever when the property ends with truthy value", ->
    expectStreamTimings(
      ->
        src = series(2, [1,2,3,4])
        valve = series(2, [true, false, true]).delay(1).toProperty()
        src.holdWhen(valve)
      [[2, 1], [5, 2], [6, 3]])
  describe "Ends properly with never-ending valve", ->
    expectStreamEvents(
      ->
        valve = new Bacon.Bus()
        series(2, [1,2,3]).holdWhen(valve)
      [1,2,3])
  describe "Supports truthy init value for property", ->
    expectStreamTimings(
      ->
        src = series(2, [1,2])
        valve = series(2, [false]).delay(1).toProperty(true)
        src.holdWhen(valve)
      [[3, 1], [4, 2]])
  describe "Works with array values", ->
    expectStreamEvents(
      ->
        Bacon.interval(1000, [1,2]).
          holdWhen(Bacon.later(1000, false).startWith(true)).
            take(1)
      [[1, 2]])

  describe.skip "Doesn't crash when flushing huge buffers", ->
    count = 6000
    expectPropertyEvents(
      ->
        source = series(1, [1..count])
        flag = source.map((x) -> x != count-1).toProperty(true)
        source.holdWhen(flag).fold(0, ((x,y) -> x+1), { eager: true})
      [count-1])

  describe "Works with synchronous sources", ->
    expectStreamTimings(
      ->
        Bacon.once("2").
          holdWhen(Bacon.later(1000, false).toProperty(true))
      [[1000, "2"]])
  describe "Works with synchronous sources, case 2", ->
    expectStreamTimings(
      ->
        Bacon.once(2).
          holdWhen(Bacon.once(true))
      [])
  describe "Works with synchronous sources, case 3", ->
    expectStreamTimings(
      ->
        Bacon.once("2").
          holdWhen(Bacon.constant(false))
      [[0, "2"]])
  describe "Works with synchronous sources, case 4", ->
    expectStreamTimings(
      ->
        Bacon.fromArray([new Bacon.Error(), "2"]).
          holdWhen(later(20, false).startWith(true))
      [error(), [20, "2"]])
  it "toString", ->
    expect(Bacon.once(1).holdWhen(Bacon.constant(true)).toString()).to.equal(
      "Bacon.once(1).holdWhen(Bacon.constant(true))")


