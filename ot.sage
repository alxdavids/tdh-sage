try:
  from sagelib.utils import string_to_bits, bits_to_string, pad_bits
except ImportError as e:
  sys.exit("Error loading preprocessed sage files. Try running `make clean pyfiles`. Full error: " + e)

class BatchOT:
  def __init__(self, tdh):
    self.tdh = tdh
    pass

  def one(self, inp_send, k, n):
    assert len(inp_send) == n
    hk = self.tdh.Sample(n*k)
    ek = []
    td = []
    for j in range(0, n):
      val = j*k + inp_send[j]
      ek_j, td_j = self.tdh.Generate(hk, val)
      ek.append(ek_j)
      td.append(td_j)
    return [(inp_send, hk, td), (hk, ek)]
  
  def two(self, msg1, inp_rec, k, n):
    assert len(inp_rec) == n*k
    (hk, ek) = msg1
    r = ZZ(self.tdh.ZZp.random_element())
    H = self.tdh.Hash(hk, inp_rec, r)
    e = []
    for j in range(0, n):
      e.append(self.tdh.E(ek[j], inp_rec, r))
    return (H, e)
  
  def three(self, st, msg2, n):
    (H, e) = msg2
    (_, _, td) = st
    s = []
    for j in range(0, n):
      e0_j, e1_j = self.tdh.D(td[j], H)
      assert e0_j != e1_j
      if e0_j == e[j]:
        s.append(0)
      elif e1_j == e[j]:
        s.append(1)
      else:
        raise ValueError("Expected some equality to occur")
    return s

class StringOT:
  def __init__(self, tdh, k, n):
    self.bOT = BatchOT(tdh)
    self.k = k
    self.n = n
   
  def one(self, inp_send):
    (st, msg1) = self.bOT.one([inp_send]*self.n, self.k, self.n)
    return (st, msg1)

  def two(self, msg1, inp_rec):
    bOT_inp_rec = [None]*(self.n*self.k)
    for l in range(0, self.k):
      bits = string_to_bits(inp_rec[l])
      padded_bits = pad_bits(bits, self.n)
      for j in range(0, self.n):
        val = j*self.k + l
        print(f"j: {j}, k: {self.k}, l: {l}, n: {self.n}, len(bits): {len(bits)}, len(pad_bits): {len(padded_bits)}")
        bOT_inp_rec[val] = int(padded_bits[j])
    (H, e) = self.bOT.two(msg1, bOT_inp_rec, self.k, self.n)
    return (H, e)
  
  def three(self, st, msg2):
    s = self.bOT.three(st, msg2, self.n)
    assert len(s) % 8 == 0
    chrs = []
    for i in range(0, int(len(s)/8)):
      chrs.append("".join(s[int(i*8):int((i+1)*8)]))
    return bits_to_string(chrs).strip()
