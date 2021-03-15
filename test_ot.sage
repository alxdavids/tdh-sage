import time
try:
  from sagelib.tdh import TrapdoorHashDDH, TrapdoorHashDDHRate1
  from sagelib.ot import BatchOT, StringOT
  from sagelib.utils import max_length_item
  from sagelib.test_utils import create_p256_curve
except ImportError as e:
  sys.exit("Error loading preprocessed sage files. Try running `make clean pyfiles`. Full error: " + e)

def run_test(function):
  print("******** Running: {} ********".format(function.__name__))
  start = time.perf_counter()
  function()
  end = time.perf_counter()
  print("******** Finished: {} after {:0.4f} seconds ********".format(function.__name__, end - start))

def run_message(function, *args):
  start = time.perf_counter()
  ret = function(*args)
  end = time.perf_counter()
  print(f"Message: {function.__name__}, total time: {end-start:0.4f}")
  return ret

def checkBatchOT(tdh):
  bOT = BatchOT(tdh)
  n = 8
  k = 3
  inp_send = [0]*n
  inp_rec = [0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 1]
  (st, msg1) = run_message(bOT.one, inp_send, k, n)
  msg2 = run_message(bOT.two, msg1, inp_rec, k, n)
  s = run_message(bOT.three, st, msg2, n)
  for j in range(0, n):
    try:
      if j == 1 or j == 2 or j == 7:
        assert s[j] == 1
      else:
        assert s[j] == 0
    except AssertionError as e:
      print("j: {}, s[{}]: {}".format(j, j, s[j]))
      raise e

def checkStringOT(tdh):
  inp_send = 1
  inp_rec = ["hello", "btw", "world"]
  sOT = StringOT(tdh, len(inp_rec), max_length_item(inp_rec)*8)
  (st, msg1) = run_message(sOT.one, inp_send)
  msg2 = run_message(sOT.two, msg1, inp_rec)
  s = run_message(sOT.three, st, msg2)
  try:
    assert s == "btw"
  except AssertionError as e:
    print("s: {}".format(s))
    raise e

def checkDDHBatchOT():
  G, EC, p = create_p256_curve()
  tdh = TrapdoorHashDDH(EC, p, G)
  checkBatchOT(tdh)

def checkDDHStringOT():
  G, EC, p = create_p256_curve()
  tdh = TrapdoorHashDDH(EC, p, G)
  checkStringOT(tdh)

def checkDDHRate1BatchOT():
  G, EC, p = create_p256_curve()
  tdh = TrapdoorHashDDHRate1(EC, p, G, 1/2^10)
  checkBatchOT(tdh)

def checkDDHRate1StringOT():
  G, EC, p = create_p256_curve()
  tdh = TrapdoorHashDDHRate1(EC, p, G, 1/2^10)
  checkStringOT(tdh)

if __name__ == "__main__":
  run_test(checkDDHBatchOT)
  run_test(checkDDHRate1BatchOT)
  run_test(checkDDHStringOT)
  run_test(checkDDHRate1StringOT)
