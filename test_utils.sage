import time

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

def run_test(function):
  print("******** Running: {} ********".format(function.__name__))
  start = time.perf_counter()
  function()
  end = time.perf_counter()
  print("******** Finished: {} after {:0.4f} seconds ********".format(function.__name__, end - start))

def run_internal(function, *args):
  start = time.perf_counter()
  ret = function(*args)
  end = time.perf_counter()
  print(f"Function: {function.__name__}, total time: {end-start:0.4f}")
  return ret