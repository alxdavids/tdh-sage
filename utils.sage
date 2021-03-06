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

def string_to_bits(s=''):
  return "".join([bin(ord(x))[2:].zfill(8) for x in s])

def bits_to_string(b=None):
  return ''.join([chr(int(x, 2)) for x in b])

def pad_bits(bits, total_len):
  m = total_len - len(bits)
  assert m % 8 == 0
  return "".join(string_to_bits(" "*int(m/8))) + bits

def max_length_item(item):
  max_len = -1
  for x in item:
    l = len(x)
    if l > max_len:
      max_len = len(x)
  return max_len
  