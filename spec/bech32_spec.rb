require 'spec_helper'

describe Bech32 do

  VALID_CHECKSUM = [
      "A12UEL5L",
      "an83characterlonghumanreadablepartthatcontainsthenumber1andtheexcludedcharactersbio1tt5tgs",
      "abcdef1qpzry9x8gf2tvdw0s3jn54khce6mua7lmqqqxw",
      "11qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqc8247j",
      "split1checkupstagehandshakeupstreamerranterredcaperred2y9e3w",
  ]

  INVALID_CHECKSUM = [
      " 1nwldj5",
      "\x7F" + "1axkwrx",
      "an84characterslonghumanreadablepartthatcontainsthenumber1andtheexcludedcharactersbio1569pvx",
      "pzry9x0s0muk",
      "1pzry9x0s0muk",
      "x1b4n0q5v",
      "li1dgmt3",
      "de1lg7wt\xff",
  ]

  VALID_ADDRESS = [
      ["BC1QW508D6QEJXTDG4Y5R3ZARVARY0C5XW7KV8F3T4", "0014751e76e8199196d454941c45d1b3a323f1433bd6"],
      ["tb1qrp33g0q5c5txsp9arysrx4k6zdkfs4nce4xj0gdcccefvpysxf3q0sl5k7",
       "00201863143c14c5166804bd19203356da136c985678cd4d27a1b8c6329604903262"],
      ["bc1pw508d6qejxtdg4y5r3zarvary0c5xw7kw508d6qejxtdg4y5r3zarvary0c5xw7k7grplx",
       "5128751e76e8199196d454941c45d1b3a323f1433bd6751e76e8199196d454941c45d1b3a323f1433bd6"],
      ["BC1SW50QA3JX3S", "6002751e"],
      ["bc1zw508d6qejxtdg4y5r3zarvaryvg6kdaj", "5210751e76e8199196d454941c45d1b3a323"],
      ["tb1qqqqqp399et2xygdj5xreqhjjvcmzhxw4aywxecjdzew6hylgvsesrxh6hy",
       "0020000000c4a5cad46221b2a187905e5266362b99d5e91c6ce24d165dab93e86433"],
  ]

  INVALID_ADDRESS = [
      "tc1qw508d6qejxtdg4y5r3zarvary0c5xw7kg3g4ty",
      "bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t5",
      "BC13W508D6QEJXTDG4Y5R3ZARVARY0C5XW7KN40WF2",
      "bc1rw5uspcuh",
      "bc10w508d6qejxtdg4y5r3zarvary0c5xw7kw508d6qejxtdg4y5r3zarvary0c5xw7kw5rljs90",
      "BC1QR508D6QEJXTDG4Y5R3ZARVARYV98GJ9P",
      "tb1qrp33g0q5c5txsp9arysrx4k6zdkfs4nce4xj0gdcccefvpysxf3q0sL5k7",
      "bc1zw508d6qejxtdg4y5r3zarvaryvqyzf3du",
      "tb1qrp33g0q5c5txsp9arysrx4k6zdkfs4nce4xj0gdcccefvpysxf3pjxtptv",
      "bc1gmk9yu",
  ]

  it 'valid checksum' do
    VALID_CHECKSUM.each do |bech|
      hrp, _ = Bech32.decode(bech)
      expect(hrp).to be_truthy
      pos = bech.rindex('1')
      bech = bech[0..pos] + (bech[pos + 1].ord ^ 1).chr + bech[pos+2..-1]
      hrp, _ = Bech32.decode(bech)
      expect(hrp).to be_nil
    end
  end

  def test_invalid_checksum
    INVALID_CHECKSUM.each do |bech|
      hrp, _ = Bech32.decode(bech)
      assert_nil (hrp)
    end
  end

  it 'valid address' do
    VALID_ADDRESS.each do |addr, hex|
      segwit_addr = Bech32::SegwitAddr.new(addr)
      expect(segwit_addr.ver).to be_truthy
      expect(segwit_addr.to_script_pubkey).to eq(hex)
      expect(segwit_addr.addr).to eq(addr.downcase)
      # from hex
      segwit_addr = Bech32::SegwitAddr.new
      segwit_addr.hrp = addr[0..1].downcase
      segwit_addr.script_pubkey = hex
      expect(segwit_addr.addr).to eq(addr.downcase)
    end
  end

  it 'invlid address' do
    INVALID_ADDRESS.each do |addr|
      expect{Bech32::SegwitAddr.new(addr)}.to raise_error(RuntimeError)
    end
  end

  it 'parse segwit script_pubkey' do
    segwit_addr = Bech32::SegwitAddr.new
    segwit_addr.script_pubkey = '0014751e76e8199196d454941c45d1b3a323f1433bd6'
    expect(segwit_addr.addr).to eq('BC1QW508D6QEJXTDG4Y5R3ZARVARY0C5XW7KV8F3T4'.downcase)
  end

end
