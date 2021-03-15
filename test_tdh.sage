try:
  from sagelib.tdh import TrapdoorHashDDH, TrapdoorHashDDHRate1
  from sagelib.test_utils import create_p256_curve, run_test, run_internal
except ImportError as e:
  sys.exit("Error loading preprocessed sage files. Try running `make clean pyfiles`. Full error: " + e)

def checkDDH():
  """
  Checks the rate-(1/group_length) TDH function from DDH.
  """
  G, EC, p = create_p256_curve()
  tdh = TrapdoorHashDDH(EC, p, G)
  n, i = 10, 2
  hk = run_internal(tdh.Sample, n)
  for i in range(10):
    (ek, td) = run_internal(tdh.Generate, hk, i)
    x = [0]*n
    r = ZZ(tdh.ZZp.random_element())
    H = run_internal(tdh.Hash, hk, x, r)
    e = run_internal(tdh.E, ek, x, r)
    hint = [None]*2
    hint[0], hint[1] = run_internal(tdh.D, td, H)
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
  hk = run_internal(tdh.Sample, n)
  for i in range(10):
    (ek, td) = run_internal(tdh.Generate, hk, i)
    x = [0]*n
    x[2] = 1
    r = ZZ(tdh.ZZp.random_element())
    H = run_internal(tdh.Hash, hk, x, r)
    e = run_internal(tdh.E, ek, x, r)
    hint = [None]*2
    hint[0], hint[1] = run_internal(tdh.D, td, H)
    assert e == hint[x[i]]
    assert e != hint[1-x[i]]

if __name__ == "__main__":
  run_test(checkDDH)
  run_test(checkDDHRate1)