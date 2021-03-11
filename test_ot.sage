try:
  from sagelib.tdh import TrapdoorHashDDH, TrapdoorHashDDHRate1
  from sagelib.ot import BatchOT
  from sagelib.test_utils import create_p256_curve
except ImportError as e:
  sys.exit("Error loading preprocessed sage files. Try running `make clean pyfiles`. Full error: " + e)

def checkBatchOT(tdh):
  bOT = BatchOT(tdh)
  n = 10
  k = 7
  inp_send = [0]*n
  inp_send[2] = 1
  inp_rec = [0]*(n*k)
  inp_rec[15] = 1
  (st, msg1) = bOT.one(inp_send, k, n)
  msg2 = bOT.two(msg1, inp_rec, k, n)
  s = bOT.three(st, msg2, n)
  for j in range(0, n):
    if j != 2:
      assert s[j] == 0
    else:
      assert s[j] == 1

def checkDDHOT():
  G, EC, p = create_p256_curve()
  tdh = TrapdoorHashDDH(EC, p, G)
  checkBatchOT(tdh)

def checkDDHRate1OT():
  G, EC, p = create_p256_curve()
  tdh = TrapdoorHashDDHRate1(EC, p, G, 1/2^10)
  checkBatchOT(tdh)

if __name__ == "__main__":
  checkDDHOT()
  checkDDHRate1OT()
