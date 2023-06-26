using Test
using ClimateDatasets

import ClimateDatasets: file_extension

@testset "ClimateDatasets Tests" begin
    @testset "filename_to_bounds and bounds_to_filename" begin

        # Using a mock dataset that we can use to call our methods
        struct MockDataset <: AbstractDataset end
        ClimateDatasets.file_extension(dataset::MockDataset) = ".txt"

        # build the mock dataset
        dataset = MockDataset()

        # Test 1: with minimum and maximum bounds
        target_1 = "time=2023-01-01T00:00:00_to_2023-12-31T23:59:59.txt"
        bounds_1 = filename_to_bounds(dataset, target_1)
        actual_1 = bounds_to_filename(dataset, bounds_1)
        @test target_1 == actual_1

        # Test 2: with a single value as bound
        target_2 = "temperature=15.0.txt"
        bounds_2 = filename_to_bounds(dataset, target_2)
        actual_2 = bounds_to_filename(dataset, bounds_2)
        @test target_2 == actual_2

        # Test 3: with complex filenames containing multiple dimensions
        target_3 = "stnid=15_to_20__temperature=2023-01-01T00:00:00_to_2023-12-31T23:59:59.txt"
        bounds_3 = filename_to_bounds(dataset, target_3)
        actual_3 = bounds_to_filename(dataset, bounds_3)
        @test target_3 == actual_3

        # Test 4: with non-time-based bounds and multiple dimensions
        target_4 = "elevation=1500_to_2000__latitude=20_to_30__longitude=-150_to_-140.txt"
        bounds_4 = filename_to_bounds(dataset, target_4)
        actual_4 = bounds_to_filename(dataset, bounds_4)
        @test target_3 == actual_3
    end
end
