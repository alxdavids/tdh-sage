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
        raise ValueError("Expected some equality")
    return s
