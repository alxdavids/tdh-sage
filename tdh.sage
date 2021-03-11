from Crypto.Hash import SHA256
from sage.crypto.util import least_significant_bits
from sagelib.utils import I2OSP
import binascii

class TrapdoorHashDDH:
  # Trying to instantiate a trapdoor hash function
  def __init__(self, GG, p, G):
    self.GG = GG
    self.G = G
    self.p = p
    self.ZZp = IntegerModRing(p)
  
  def Sample(self, n):
    A = []
    for _ in range(2):
      v = [None]*n
      for j in range(n):
        v[j] = (self.GG.random_point())
      A.append(v)
    return ((self.GG, self.ZZp, self.G), A, n)
  
  def Generate(self, hk, i):
    A, n = hk[1], hk[2]
    s, t = ZZ(self.ZZp.random_element()), ZZ(self.ZZp.random_element())
    U = s*self.G
    B = []
    for b in range(2):
      v = [None]*n
      for j in range(n):
        v[j] = s*A[b][j]
        if j == i and b == 1:
          v[j] = v[j] + t*self.G
      B.append(v)
    return ((U, B, n), (s, t))

  def Hash(self, hk, x, r):
    A, n = hk[1], hk[2]
    assert len(x) == n
    H = r*self.G
    for j in range(n):
      if x[j] == 0:
        H = H + A[0][j]
      else:
        H = H + A[1][j]
    return H
  
  def E(self, ek, x, r):
    """
    Encode function
    """
    (U, B, n) = ek
    e = r*U
    for j in range(n):
      if x[j] == 0:
        e = e + B[0][j]
      else:
        e = e + B[1][j]
    return e
  
  def D(self, td, H):
    (s, t) = td
    e0, e1 = s*H, s*H + t*self.G
    return e0, e1

class TrapdoorHashDDHRate1(TrapdoorHashDDH):
  def __init__(self, GG, p, G, delta):
    super().__init__(GG, p, G)
    self.delta = delta

  # Trying to instantiate a trapdoor hash function with rate 1  
  def Generate(self, hk, i):
    ((U, B, n), (s, t)) = super().Generate(hk, i)
    prf_key = binascii.b2a_hex(os.urandom(16))
    return ((U, B, t, prf_key, n), (s, t, prf_key))
  
  def E(self, ek, x, r):
    (U, B, t, prf_key, n) = ek
    e = super().E((U, B, n), x, r)
    return self.Dist(e, self.delta, 1, prf_key, t*self.G)
  
  def D(self, td, H):
    (s, t, prf_key) = td
    e0, e1 = super().D((s, t), H)
    return self.Dist(e0, self.delta, 1, prf_key, t*self.G), self.Dist(e1, self.delta, 1, prf_key, t*self.G)
  
  def Dist(self, H, delta, m, prf_key, Y):
    # not convinced about this
    t = (2*m*ln(2/delta))/delta
    i = 0
    bound = ceil(log((2*m)/delta))
    while i <= t:
      P = H + i*Y
      Px, Py = P.xy()[0], P.xy()[1]
      prf = SHA256.new()
      prf.update(prf_key)
      prf.update(I2OSP(4, 1))
      prf.update(I2OSP(Px, 32))
      prf.update(I2OSP(Py, 32))
      out = prf.hexdigest()
      z = ZZ("0x" + out)
      bits = least_significant_bits(z, bound)
      satisfied = True
      for bit in bits:
        if bit == 0:
          continue
        satisfied = False
        break
      if satisfied:
        break
      i = i+1
    return least_significant_bits(i, 1)[0]
  