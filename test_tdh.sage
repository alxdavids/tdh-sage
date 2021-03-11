try:
  from sagelib.tdh import TrapdoorHashDDH, TrapdoorHashDDHRate1
except ImportError as e:
  sys.exit("Error loading preprocessed sage files. Try running `make clean pyfiles`. Full error: " + e)

def create_p256_curve():
  # Finite field prime
  p256 = 0xFFFFFFFF00000001000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFF

  # Curve parameters for the curve equation: y^2 = x^3 + a256*x +b256
  a256 = p256 - 3
  b256 = 0x5AC635D8AA3A93E7B3EBBD55769886BC651D06B0CC53B0F63BCE3C3E27D2604B

  # Base point (x, y)
  gx = 0x6B17D1F2E12C4247F8BCE6E563A440F277037D812DEB33A0F4A13945D898C296
  gy = 0x4FE342E2FE1A7F9B8EE7EB4A7C0F9E162BCE33576B315ECECBB6406837BF51F5

  # Curve order
  qq = 0xFFFFFFFF00000000FFFFFFFFFFFFFFFFBCE6FAADA7179E84F3B9CAC2FC632551

  # Create a finite field of order p256
  FF = GF(p256)

  # Define a curve over that field with specified Weierstrass a and b parameters
  EC = EllipticCurve([FF(a256), FF(b256)])

  # Since we know P-256's order we can skip computing it and set it explicitly
  EC.set_order(qq)

  # Create a variable for the base point
  G = EC(FF(gx), FF(gy))

  return G, EC, p256

def checkDDH():
  """
  Checks the rate-(1/group_length) TDH function from DDH.
  """
  G, EC, p = create_p256_curve()
  tdh = TrapdoorHashDDH(EC, p, G)
  n, i = 10, 2
  hk = tdh.Sample(n)
  for i in range(10):
    (ek, td) = tdh.Generate(hk, i)
    x = [0]*n
    r = ZZ(tdh.ZZp.random_element())
    H = tdh.Hash(hk, x, r)
    e = tdh.E(ek, x, r)
    hint = [None]*2
    hint[0], hint[1] = tdh.D(td, H)
    assert e == hint[x[i]]
    assert e != hint[1-x[i]]

def checkDDHRate1():
  """
  Checks the rate-1 TDH function from DDH.
  WARNING: This is probabilistic, and will fail with delta + negl probability
  """
  delta = 1/2^8
  G, EC, p = create_p256_curve()
  tdh = TrapdoorHashDDHRate1(EC, p, G, delta)
  n, i = 10, 2
  hk = tdh.Sample(n)
  for i in range(10):
    (ek, td) = tdh.Generate(hk, i)
    x = [0]*n
    x[2] = 1
    r = ZZ(tdh.ZZp.random_element())
    H = tdh.Hash(hk, x, r)
    e = tdh.E(ek, x, r)
    hint = [None]*2
    hint[0], hint[1] = tdh.D(td, H)
    assert e == hint[x[i]]
    assert e != hint[1-x[i]]

if __name__ == "__main__":
  checkDDH()
  checkDDHRate1()