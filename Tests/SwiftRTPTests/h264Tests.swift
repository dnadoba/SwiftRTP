import XCTest
@testable import BinaryKit
@testable import SwiftRTP

final class NALUnitHeaderTests: XCTestCase {
    func testReadAndWriteFromStruct() throws {
        let headers = [
            NALUnitHeader(forbiddenZeroBit: false, referenceIndex: 0, type: .fragmentationUnitA),
            NALUnitHeader(forbiddenZeroBit: true, referenceIndex: 0, type: .fragmentationUnitB),
            NALUnitHeader(forbiddenZeroBit: false, referenceIndex: 1, type: .reserved31),
            NALUnitHeader(forbiddenZeroBit: false, referenceIndex: 2, type: .multiTimeAggregationPacket16),
            NALUnitHeader(forbiddenZeroBit: false, referenceIndex: 3, type: .singleTimeAggregationPacketA),
        ]
        for header in headers {
            var writer = BinaryWriter()
            try header.write(to: &writer)
            var reader = BinaryReader(bytes: writer.bytesStore)
            XCTAssertEqual(header, try NALUnitHeader(reader: &reader))
        }
    }
    
    func testReadHeaderFromBinary() throws {
        var header = BinaryReader(bytes: [0b1_01_10000])
        //                                  | |  |
        //                                  | |  type
        //                                  | reference index
        //                                  forbidden zero bit
        XCTAssertEqual(
            try NALUnitHeader(reader: &header),
            NALUnitHeader(
                forbiddenZeroBit: true,
                referenceIndex: 1,
                type: .init(rawValue: 16)
            ))
    }
    func testWriteHeaderToBinary() throws {
        var writer = BinaryWriter(bytes: [])
        try NALUnitHeader(
            forbiddenZeroBit: false,
            referenceIndex: 2,
            type: .init(rawValue: 16)
        ).write(to: &writer)
        
        XCTAssertEqual(writer.bytesStore, [0b0_10_10000])
        //                                   | |  |
        //                                   | |  type
        //                                   | reference index
        //                                   forbidden zero bit
    }
    
    func testSingleTimeAggregationPacket() throws {
        let singleTimeAggregationPacketAWithSPSAndPPS = "1800176742c028da01e0089f97011000003e90000bb800f1832a000468ce3c80"
        var reader = try XCTUnwrap(BinaryReader(hexString: singleTimeAggregationPacketAWithSPSAndPPS))
        var a = NALPackageParser<[UInt8]>()
        let nalus = try a.readPackage(from: &reader)
        let sps = try XCTUnwrap(nalus.first)
        let pps = try XCTUnwrap(nalus.last)
        XCTAssertEqual(sps.header, NALUnitHeader(forbiddenZeroBit: false, referenceIndex: 3, type: .sequenceParameterSet))
        XCTAssertEqual(sps.payload.count, 22)
        XCTAssertEqual(pps.header, NALUnitHeader(forbiddenZeroBit: false, referenceIndex: 3, type: .pictureParameterSet))
        XCTAssertEqual(pps.payload.count, 3)
    }
    
    func testFragmentedPacketA() throws {
        var startPacket = try XCTUnwrap(BinaryReader(hexString:  "5c819be08800670444be0026bf2648723fe940484be00bc0cb732593f84fffff011ebdb79a117822237e7945f89f08cbc7e5453f84f0004114a42042494a5041049247ffe000747fd813075efe0ba4f0ce1525fe60340202e00b8d582796fc83c5a94dbf0f196f1e5ea583934d1fc40b81a498070219e03dd1cd27e5f65b7263c8662cb0390cc5960090dad30ade4cf5a69b50780ac06dfa7e8fe13c0022001a18b2d6b507245cb96fff002e99b216573080e00f2c1f15c8a7a7073b730a6625fec32433c8648679ff9bc0841e5ffbbcb97092a6cdc65b80389973ef89c0c5cd800ad66c8515d1c83d750568050abdcc140444c00a94c80fe021b79ec522bc67a70abf0267a1b23a3ff3c31ed9fa5c6f686639eea912547be23c2785540fef5adef5ae7f8812128422920a6e6d9108fbd4b0cbe024ef4b7d8345e0557e542d7b6c44dc7628066bfd4b2f9899784e3fa61aad7781feb9337ba3cd87f87c07000d817e005a9e827282157aef823db3b608c96089f01803b000459e0ed21b1034b74680b0a34cb6362aff7e97e320fe1e9b1ec445ee3faf0a60094188c8896b58c6cfff002ac49be81ec703dfb80989f81851a49c06d579c484bf77df07d0f722a2f077e0c0082320022578da56a1ca0506805895280056f460a5ce0616cfec061aa19e4815a0f69f5af3f7f918d983c575cf0a304505af40cbcf7a09e00088cc884eaaa888aedfffc00719e85730a26dfb8447450001023801763cc841c49913b60024cf20b3b8001cc91d8ef2f5fbfe98cb8702e8be58ce7056dff8318f84f0e94cf9612c3e584b09ff89f048b874b0df463c44de2632a2040a84792c26fc979ecff0d54907d16018c47f81c440980131d515355ddf9ef1ae2233b55e3918f107971ef1e0214f2d339f79fe10072260176cb5c36bcf3e35f6f607fb35dbbaa0c5630043425a1dbb3c1f13332d755b1fc48ee03889f4b00212d94f21c47f005d8e469738e78cfbfeffc17f0196000204995cc35b8060ebcf01c2030af0577016114acc22111f928b43281527aff19aded9ae6ff06a6b2e573a9566ffa9f37822872474b331ec81f398d36adfb5000dd5b81a8671a75eb1049929fee0af730886709e03cc345a8a0467b4f05096cdc973d58075acd4026af019d5445ffba550f5a0133c3c037c04a2ce4bd678042008d5325e182500008022e0850c6ab179e20140097215eeaea3ffffef007646e2cf6034006409981808db758b11887eb033570c27ac920f9787c0d20846426d68799c000e00acb2cc0a90afe3c2e9e09d81cc3e77c0fcab6837603033dfafab3f0012ab706f08043fc0439e0aa0696231c0d6c406052d3f3c200791f0fb2c9d96fc0247b8d196d6d208b25bef81b75ba8f1990fa032de2111e006116413ba5e7b23f7835bc060cfee9ffc220284678018c906b308bc001113c46e09e59e376e67b18a2a658c45bcdce7a50724e0e12c69670f3bdf600526c46852b5880152bcf804151e3c7dff808136095aec001afd1460748cbf063cfbc2780106da5b69cfe011b57e7c81042dc80ca591c999e1093ffd5080c1b2c0e88040f96a307440207cb0d080c1f2dc40ee43a082dd906393fb90e7860052dc631338e68d383f150eb8b4891ec0193ec493950f0753119d48883c0f8fee6ce0532f3ca61043884fcf15bc2f59bc015a372e3d3f0309fcfe13c664990743cef9de8743cef9df3f9fc47f11f8600b2118a4630474b2f0c4811c089561c59c28dfbde3332027e252171eb000c5b42883535e0bfda6ddfbf5ffdbb8325429b67de1f812457804de7d57f6f0d4e3c58fc278032491222001802f5505ae67826442df3b6ab417400079ef640a8d78e004af9130001003b98798000801dcc1c0022be0e0013bf80b000f08f87d964ecb7af6a76feae6d0dc055498f590175882ea48baaa27e13c0082e0c24c428973a428833d808926739e98008c986ce48512204347c5587021b6e709e00d52b6a3d33e67eb06a0f9573cd81005dee4cf99ed807002a5b8d80700a96e61001202b0015e5c21ef"))
        var middlePacket = try XCTUnwrap(BinaryReader(hexString:  "5c010423ffdd031b76441ece8b7fe002227902853b1f18cfd57c26dc9845c0744be18b2b2c0cfe49a2224abdf7012013d9117d0c5696d7f60cf1ef87a5efc022002806400b72191e23a65c0001026779e00f5460f7f4c0c086308f0ca31c3ac82fdbc0f0002ea50c795392cb7192a492455f421210501ae806fc02f2c925c94084b93181e9ff042020711f0a7fffff80063ab6f449bc1000e81d8216ff2047699767ac8125ad1fa8292fbc18701253701f8d7f1fae4bfb49489b2cdde81e0800740ac420a01774c1eb22b004efd0c23eb0096e8ce5c62aabb0128d64f0c4d456fb839ff0309fcfe7f3f9fcff014003802380091f9c21886c8277f8005c67c5686acf7d36fbf3cda0015899f2a2c329bfe0004c8bccc1fb8228848b4e0b7fe186cc3fdeb52189f7061f03c00441f32edec77f77ff0c3e06001703b0016b6b18dd3e5b1c82416f7396229bc05db1f5c418e10ef6de1c002fd14cf9e427dc180b448a558e14a7fc1c2780219b99a693fef7ffc05554d6601e18a15973559f09e00093ca4f30c8917ef075bee2de41d6f058fed6783ade3220974efd40eb794505a8173d3fe013001f22a01b4045588395aec285845b35c247daa66a44ef09e001107e9233c88ffd7e01270f44bde4ea018d086b302800a91d305c003460d7a2206e6c93f7e00b3998891ced91edd5a3c7bff4768c2f31d88bf5e1d40ad7393c4ce6078640649300505a28bafbb4610c8003b9267435d9bb27de290a7e698001ef380835c760f3af034d76be0380439d147fe13ffff9a134308c6424fb5600a9c3ef60a7692168032183baf831b2e75bf3ba1f7878f4e41f67105acdbf7cc098652660164a9408d6d3ee384fffff0085abfdb0110026466006d9bd13c81fa5b40fcc085f806657fc56300010072106f1edad59a2d95daf1e4925e4830207b5e29bb7258af7437f3fa0ed8346977073ffcf036312ff36001917c8acfafffe0230db9f9821d2b5b890ac77a61089c0073d147a1a3bc801b73967765dbf1661fca254f37ffa830f3f0309fcfe7f3f9fe03240608cf00889b24ebc8001cbdb202415ac7e70410e790128b0efecf84cf6317ac0e10335ef1e1a9a51be00088e67a0487393cb0ed7b07fb5981c3647b31a95dd7b5e2ff83f897d9fcc754bffb030f8044405c8c8ff85de5b009914c1f66f0009e890c3feb9a0cb0491482cccc6598a37864c1890b6061d890bb92881084a86f3f6cc201c3e5b02a532da64385cafd45a14c1c3a496925c69d4d269b4d60e00440462219bc0ac0f01879a5a026ac198fe02fb8d21fd8449116e8ce9e00146e123bb02f18e78f000829406267e07327f818c925e32fd0444ff116b014c790affffed3effb7f7f806640a010805be404f1c33a8f03995b21921c10085fbee80008137006441b4901c80eef8b00010229e000204930fbad81ec28a5ec62e07d913d00008113f360ef2b95a1e023b7ec02800591d8017c33a34a041f90b1341608bd69d734ff8343f5b1302bc41df2b74aea322a81f610044bc5fa4278002a1c2149a8cf364a0827f01eb04d37cf051d01ff20246a81cce3b70098221538cbcf101500b701f3987b52009ee202a016e62210ba8626d12c27b3d0fcdbfb00676c5f6a8bd1d1c100fe17b14fc0fc1b4676c913be0be003ca21145a6cff853311ffd8c98ce632633e1001922e00804e989b95f813115674c8f7aff06d80d3e5a01207df5cc6c254e6094a470ab43887ce99642797ffffcb09618801a03310f300401c6738846282b9fd822fcd40cb7ffdd7981118a4cc011206ab50d80de2fcb906bea9540891046c57bd81f15ade839d98848cdd7bff80f8024846367608c85482456b5ef2df800ef48516d167d0cf81800d355eca3cf019b0a5fa9e91cddf01ade4c44e5e0e5897e7838c6aa47ddffff366f0011ab37a25effff0162038464c94000a1c8b4ad4807047037ef859f076b2e033826c4c755e4306304177c1ef71ad8bb3a9e0091b33b111464bb1010143fc1f5687a1c43fc2e78e22de980bbf853311ff0ff96ae5fab96"))
        var endPacket = try XCTUnwrap(BinaryReader(hexString:  "5c41ae5fc278004606f8c88e322ff007f7c68871583c80231573f0309fcff04210084070473de99838214d2533070429a4a66009d8dd6abbaad0e6fbc1e5b9607af9684f0004934c118f9798e6157ff870700d2c0b9608c3ce6ff09e0082640cca7320eaf80238fb114b9f4800421b73e300118dd6403c712b16317301a010086a18ea9d5d6b807ff57cf40395b96c1cadcb18bc0214fffc69e9a711e23e0e40202260e004394f4cc061111f53179f78399e4022e576fe7bc03114c70f03cc33d01e2004404200ac82d1c54498810debc25d98108b4382d7db80ada1a299d97fbde0d19948d8eaadf18ed28697f6eeb00aab9dcebb594c9cd6b534137ec0b2024021001a52248a57f7ffff1593c6b183de49fd1aaf042b4ebbcf81c4044847cbfc51a025039c56627fc80010d6c6224550e45f8175307fd01902ef9d9342bd6a52bb00a00164760218248e2bf9fc0006d8534b5402c050b3c757c4ac433db95442a9a7283e97ff93eb72a1f5277f340c41cf7d030f3fcfe13c001064214a521084395c826fe6b9ebae7ebae6bae071400052e14c0ecdafc76e56dce34eb6e271e0a00c23ee26d998d63dff0065443e594fa9e033a490255fc712cdebfd4f5f7a1fef17f725ec11c5f2045be407b343cfdec06b10c30205fe5e2c41ebe5b07adcb103f3ca14ffff79a39ace68e6a2378535f99f1db9f5b73c2780087d77ddffff003f094a48c5cff00080dc"))
        
        
        var parser = NALPackageParser<[UInt8]>()
        XCTAssertEqual(try parser.readPackage(from: &startPacket), [])
        XCTAssertEqual(try parser.readPackage(from: &middlePacket), [])
        let nalu = try XCTUnwrap(try parser.readPackage(from: &endPacket).first)
        XCTAssertEqual(nalu.header, NALUnitHeader(forbiddenZeroBit: false, referenceIndex: 2, type: .init(rawValue: 1)))
        XCTAssertEqual(nalu.payload.count, 6874)
    }
    
    func test_a() {
        let nalu = NALUnit(header: .init(forbiddenZeroBit: false, referenceIndex: 0, type: .pictureParameterSet), payload: Data([1,2,3,4,5,6,7,8]))
        XCTAssertEqual(nalu.bytes, Data([NALUnitType.pictureParameterSet.rawValue, 1,2,3,4,5,6,7,8]))
    }
    
    static var allTests = [
        ("testReadAndWriteFromStruct", testReadAndWriteFromStruct),
    ]
}
