import os, struct, sys
if sys.version_info[0] == 3:
    xrange = range

# defined in RFC 3447, section 4.2
def OS2IP(octets, skip_assert=False):
    ret = 0
    for octet in struct.unpack("=" + "B" * len(octets), octets):
        ret = ret << 8
        ret += octet
    if not skip_assert:
        assert octets == I2OSP(ret, len(octets))
    return ret

def I2OSP(val, length):
  val = int(val)
  if val < 0 or val >= (1 << (8 * length)):
      raise ValueError("bad I2OSP call: val=%d length=%d" % (val, length))
  ret = [0] * length
  val_ = val
  for idx in reversed(xrange(0, length)):
      ret[idx] = val_ & 0xff
      val_ = val_ >> 8
  ret = struct.pack("=" + "B" * length, *ret)
  assert OS2IP(ret, True) == val
  return ret

def to_hex(octet_string):
    if isinstance(octet_string, str):
        return "".join("{:02x}".format(ord(c)) for c in octet_string)
    assert isinstance(octet_string, bytes)
    return "".join("{:02x}".format(c) for c in octet_string)