import Foundation

struct App {
    let filters: [Filter]
    
    public static let shared = `default`
}

extension App {
    private static let `default` = App(
        filters: [
            PassthroughFilter(),
//            OldFilmFilter(),
            SharpAndWarmFilter(inputSharpness: 0.7),
            VignetteFilter(),
            SepiaFilter(),
            VintageFilter(),
            ClampFilter(),
            RetroFilter(),
            ProcessFilter(),
            ComicFilter(),
            ColorInvertFilter(),
            HalfToneFilter(),
            BlurFilter(blurRadius: 30),
            TonalFilter(),
            MonoFilter(),
            MonochromeFilter(),
            NoirFilter()
        ]
    )
    
    private static let many = App(
        filters: [
            PassthroughFilter(),
            ComicFilter(),
            BlurFilter(blurRadius: 50),
            OldFilmFilter(),
            SharpAndWarmFilter(inputSharpness: 0.7),
            VignetteFilter(),
            ComicFilter(),
            BlurFilter(blurRadius: 50),
            OldFilmFilter(),
            SharpAndWarmFilter(inputSharpness: 0.7),
            VignetteFilter(),
            ComicFilter(),
            BlurFilter(blurRadius: 50),
            OldFilmFilter(),
            SharpAndWarmFilter(inputSharpness: 0.7),
            VignetteFilter(),
            ComicFilter(),
            BlurFilter(blurRadius: 50),
            OldFilmFilter(),
            SharpAndWarmFilter(inputSharpness: 0.7),
            VignetteFilter(),
            ClampFilter()
        ]
    )
    
    private static let variant2 = App(
        filters: [
            PassthroughFilter(),
            ComicFilter()
        ]
    )
    
    private static let composite = App(
        filters: [
            PassthroughFilter(),
            OldFilmFilter() + VignetteFilter(),
            BlurFilter(blurRadius: 20) + SharpAndWarmFilter(inputSharpness: 0.7),
            ClampFilter() + VignetteFilter(),
            ComicFilter() + VignetteFilter(),
        ]
    )
    
    private static let slowFilter = App(
        filters: [
            PassthroughFilter(),
            ClampFilter() +
            VignetteFilter() +
            SharpAndWarmFilter(inputSharpness: 0.7) +
            ClampFilter() +
            VignetteFilter() +
            SharpAndWarmFilter(inputSharpness: 0.7) +
            ClampFilter() +
            VignetteFilter() +
            SharpAndWarmFilter(inputSharpness: 0.7) +
            ClampFilter() +
            VignetteFilter() +
            SharpAndWarmFilter(inputSharpness: 0.7)
        ]
    )
     
}
