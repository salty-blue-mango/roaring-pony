use "ponybench"
use "random"
use "files"
use "cli"

use "ponyzip"

use "../../roaring"

actor Main is BenchmarkList
  let _env: Env

  new create(env: Env) =>
    _env = env
    PonyBench(env, this)

  be benchmarks(bench: PonyBench) =>
    read_only_benchmarks(bench)

  fun print_available_datasets() =>
    _env.err.print("""
      Available datasets:

      * census-income
      * census-income_srt
      * census1881
      * census1881_srt
      * dimension_003
      * dimension_008
      * dimension_033
      * uscensus2000
      * weather_sept_85
      * weather_sept_85_srt
      * wikileaks-noquotes
      * wikileads-noquotes_srt

      """)

  be read_only_benchmarks(bench: PonyBench) =>
    try
      // TODO: make this independent of the current diretory
      let dataset_base_path = FilePath.create(_env.root as AmbientAuth, "bench/data/real-roaring-dataset")?
      try
        let dataset_name = EnvVars(_env.vars)("ROARING_DATASET")?
        let stream = _env.err
        try
          let dataset = RoaringDataset(dataset_base_path, stream, dataset_name)?
          let roaring = recover val dataset.load()? end
          bench(_ContainsBench.create(dataset_name, roaring))
        else
          _env.err.print("Error loading dataset")
          print_available_datasets()
        end
      else
        _env.err.print("ROARING_DATASET unset")
        print_available_datasets()
      end
    else
      _env.err.print("no ambientauth available")
    end

class iso _ContainsBench is MicroBenchmark

  let _dataset: String
  let _roaring: Roaring val
  let _rand: Rand = Rand
  var _index: U32 = 0

  new iso create(dataset: String, roaring: Roaring val) =>
    _dataset = dataset
    _roaring = roaring

  fun name(): String => "contains[" + _dataset + "]"

  fun ref before_iteration() =>
    _index = _rand.int[U32](U32.max_value())

  fun apply() =>
    DoNotOptimise[Bool](_roaring.contains(_index))
    DoNotOptimise.observe()


