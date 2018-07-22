Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:59856 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1727774AbeGVKXd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 22 Jul 2018 06:23:33 -0400
From: jiyin@redhat.com
To: bfields@redhat.com
Cc: linux-nfs@vger.kernel.org, "Jianhong.Yin" <yin-jianhong@163.com>
Subject: [PATCH 5/6] pynfs: python3 support plan: remove suffix 'L' of long integer
Date: Sun, 22 Jul 2018 17:27:09 +0800
Message-Id: <20180722092710.17521-5-jiyin@redhat.com>
In-Reply-To: <20180722092710.17521-1-jiyin@redhat.com>
References: <20180722092710.17521-1-jiyin@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "Jianhong.Yin" <yin-jianhong@163.com>

s/(0x[[:xdigit:]]+)L\>/\1/g
s/(\<[[:digit:]]+)L\>/\1/g

Signed-off-by: Jianhong Yin <yin-jianhong@163.com>
---
 nfs4.0/lib/rpc/rpc.py                 | 14 +++++++-------
 nfs4.0/lib/rpc/rpcsec/sec_auth_gss.py |  2 +-
 nfs4.0/nfs4lib.py                     |  8 ++++----
 nfs4.0/nfs4server.py                  |  6 +++---
 nfs4.0/nfs4state.py                   |  4 ++--
 nfs4.0/servertests/environment.py     |  2 +-
 nfs4.0/servertests/st_commit.py       |  8 ++++----
 nfs4.1/client41tests/environment.py   |  2 +-
 nfs4.1/dataserver.py                  |  2 +-
 nfs4.1/fs.py                          |  2 +-
 nfs4.1/nfs4client.py                  |  2 +-
 nfs4.1/nfs4lib.py                     | 10 +++++-----
 nfs4.1/nfs4server.py                  |  4 ++--
 nfs4.1/server41tests/environment.py   |  4 ++--
 nfs4.1/server41tests/st_debug.py      |  2 +-
 nfs4.1/testmod.py                     |  2 +-
 rpc/rpc.py                            |  8 ++++----
 17 files changed, 41 insertions(+), 41 deletions(-)

diff --git a/nfs4.0/lib/rpc/rpc.py b/nfs4.0/lib/rpc/rpc.py
index 83a51c4..d9c1401 100644
--- a/nfs4.0/lib/rpc/rpc.py
+++ b/nfs4.0/lib/rpc/rpc.py
@@ -157,9 +157,9 @@ def _recv_record(self):
     while not last:
         rec_mark = self.recv_all(4)
         count = struct.unpack('>L', rec_mark)[0]
-        last = count & 0x80000000L
+        last = count & 0x80000000
         if last:
-            count &= 0x7fffffffL
+            count &= 0x7fffffff
         data += self.recv_all(count)
     return data
 
@@ -171,7 +171,7 @@ def _send_record(self, data, chunksize=2048):
         chunk = data[i:i+chunksize]
         i += chunksize
         if i >= dlen:
-            last = 0x80000000L
+            last = 0x80000000
         mark = struct.pack('>L', last | len(chunk))
         self.sendall(mark + chunk)
 
@@ -202,7 +202,7 @@ class RPCClient(object):
         self._rpcunpacker = {t : rpc_pack.RPCUnpacker('')}
         self.default_prog = program
         self.default_vers = version
-        self.xid = 0L
+        self.xid = 0
         self._xidlist = {}
         if sec_list is None:
             sec_list = [SecAuthNone()]
@@ -558,8 +558,8 @@ class RPCServer(Server):
             str = self.readbufs[fd]
             if len(str) >= 4:
                 packetlen = struct.unpack('>L', str[0:4])[0]
-                last = 0x80000000L & packetlen
-                packetlen &= 0x7fffffffL
+                last = 0x80000000 & packetlen
+                packetlen &= 0x7fffffff
                 if len(str) >= 4 + packetlen:
                     self.packetbufs[fd].append(str[4:4 + packetlen])
                     self.readbufs[fd] = str[4 + packetlen:]
@@ -593,7 +593,7 @@ class RPCServer(Server):
                 last = 0
                 self.recordbufs[fd][0] = data[chunksize:]
             else:
-                last = 0x80000000L
+                last = 0x80000000
                 del self.recordbufs[fd][0]
             mark = struct.pack('>L', last | len(chunk))
             self.writebufs[fd] = (mark + chunk)
diff --git a/nfs4.0/lib/rpc/rpcsec/sec_auth_gss.py b/nfs4.0/lib/rpc/rpcsec/sec_auth_gss.py
index 6351355..ee6ad53 100644
--- a/nfs4.0/lib/rpc/rpcsec/sec_auth_gss.py
+++ b/nfs4.0/lib/rpc/rpcsec/sec_auth_gss.py
@@ -72,7 +72,7 @@ def show_major(m):
     """Return string corresponding to major code"""
     if m == 0:
         return gss_major_codes[0]
-    call = m & 0xff000000L
+    call = m & 0xff000000
     routine = m & 0xff0000
     supp = m & 0xffff
     out = []
diff --git a/nfs4.0/nfs4lib.py b/nfs4.0/nfs4lib.py
index a0fdce1..d255eb7 100644
--- a/nfs4.0/nfs4lib.py
+++ b/nfs4.0/nfs4lib.py
@@ -93,7 +93,7 @@ class FancyNFS4Packer(nfs4_pack.NFS4Packer):
     def filter_bitmap4(self, data):
         out = []
         while data:
-            out.append(data & 0xffffffffL)
+            out.append(data & 0xffffffff)
             data >>= 32
         return out
 
@@ -108,7 +108,7 @@ class FancyNFS4Packer(nfs4_pack.NFS4Packer):
 class FancyNFS4Unpacker(nfs4_pack.NFS4Unpacker):
     def filter_bitmap4(self, data):
         """Put bitmap into single long, instead of array of 32bit chunks"""
-        out = 0L
+        out = 0
         shift = 0
         for i in data:
             out |= (long(i) << shift)
@@ -1006,9 +1006,9 @@ def fattr2dict(obj):
 
 def list2bitmap(list):
     """Construct a bitmap from a list of bit numbers"""
-    mask = 0L
+    mask = 0
     for bit in list:
-        mask |= 1L << bit
+        mask |= 1 << bit
     return mask
 
 def bitmap2list(bitmap):
diff --git a/nfs4.0/nfs4server.py b/nfs4.0/nfs4server.py
index cb3ea72..163bd60 100755
--- a/nfs4.0/nfs4server.py
+++ b/nfs4.0/nfs4server.py
@@ -475,7 +475,7 @@ class NFS4Server(rpc.RPCServer):
             e = verify_name(filename)
             if e: raise NFS4Error(e)
             # At this point we know it is CLAIM_NULL with valid filename and cfh
-            attrset = 0L
+            attrset = 0
             ci_old = self.curr_fh.fattr4_change
             if op.opopen.openhow.opentype == OPEN4_CREATE:
                 print("  CREATING FILE.")
@@ -812,13 +812,13 @@ class NFS4Server(rpc.RPCServer):
         print("  CURRENT FILEHANDLE: %s" % repr(self.curr_fh))
         print(op.opsetattr.obj_attributes)
         if not self.curr_fh:
-            return simple_error(NFS4ERR_NOFILEHANDLE, 0L)
+            return simple_error(NFS4ERR_NOFILEHANDLE, 0)
         try:
             attrdict = op.opsetattr.obj_attributes
             if FATTR4_SIZE in attrdict:
                 # This counts as a write, so must do some checking
                 if self.curr_fh.get_type() != NF4REG:
-                    return simple_error(NFS4ERR_BAD_STATEID, 0L)
+                    return simple_error(NFS4ERR_BAD_STATEID, 0)
                 oldsize = self.curr_fh.fattr4_size
                 newsize = attrdict[FATTR4_SIZE]
                 if oldsize <= newsize:
diff --git a/nfs4.0/nfs4state.py b/nfs4.0/nfs4state.py
index e854b3b..484a284 100755
--- a/nfs4.0/nfs4state.py
+++ b/nfs4.0/nfs4state.py
@@ -26,7 +26,7 @@ POSIXLOCK = True # If True, allow locks to be split/joined automatically
 POSIXACL = True # If True, forces acls to follow posix mapping rules
 
 class NFS4Error(Exception):
-    def __init__(self, code, msg=None, attrs=0L, lock_denied=None):
+    def __init__(self, code, msg=None, attrs=0, lock_denied=None):
         self.code = code
         self.name = nfsstat4[code]
         if msg is None:
@@ -384,7 +384,7 @@ class NFSServerState:
         # Check for special stateids
         if stateid.seqid==0 and stateid.other==chr(0)*12:
             return 0
-        if stateid.seqid==0xffffffffL and stateid.other==chr(0xff)*12:
+        if stateid.seqid==0xffffffff and stateid.other==chr(0xff)*12:
             return 1
         # Check for self consistency
         if stateid.other[:4] != self.instance:
diff --git a/nfs4.0/servertests/environment.py b/nfs4.0/servertests/environment.py
index a848ed4..a5cfe60 100644
--- a/nfs4.0/servertests/environment.py
+++ b/nfs4.0/servertests/environment.py
@@ -119,7 +119,7 @@ class Environment(testmod.Environment):
         self.filedata = "This is the file test data."
         self.linkdata = "/etc/X11"
         self.stateid0 = stateid4(0, '')
-        self.stateid1 = stateid4(0xffffffffL, '\xff'*12)
+        self.stateid1 = stateid4(0xffffffff, '\xff'*12)
 
     def _get_security(self, opts):
         if opts.security == 'none':
diff --git a/nfs4.0/servertests/st_commit.py b/nfs4.0/servertests/st_commit.py
index e903739..eecf2c8 100644
--- a/nfs4.0/servertests/st_commit.py
+++ b/nfs4.0/servertests/st_commit.py
@@ -42,7 +42,7 @@ def testCommitOffsetMax1(t, env):
     DEPEND: MKFILE
     CODE: CMT1c
     """
-    _commit(t, env.c1, 0xffffffffffffffffL, statlist=[NFS4_OK, NFS4ERR_INVAL])
+    _commit(t, env.c1, 0xffffffffffffffff, statlist=[NFS4_OK, NFS4ERR_INVAL])
 
 def testCommitOffsetMax2(t, env):
     """COMMIT
@@ -51,7 +51,7 @@ def testCommitOffsetMax2(t, env):
     DEPEND: MKFILE
     CODE: CMT1d
     """
-    _commit(t, env.c1, 0xfffffffffffffffeL, statlist=[NFS4_OK, NFS4ERR_INVAL])
+    _commit(t, env.c1, 0xfffffffffffffffe, statlist=[NFS4_OK, NFS4ERR_INVAL])
 
 def testCommitCount1(t, env):
     """COMMIT
@@ -69,7 +69,7 @@ def testCommitCountMax(t, env):
     DEPEND: MKFILE
     CODE: CMT1f
     """
-    _commit(t, env.c1, 0, 0xffffffffL)
+    _commit(t, env.c1, 0, 0xffffffff)
 
 def testLink(t, env):
     """COMMIT
@@ -159,5 +159,5 @@ def testCommitOverflow(t, env):
     fh, stateid = c.create_confirm(t.code)
     res = c.write_file(fh, _text, 0, stateid, how=UNSTABLE4)
     check(res, msg="WRITE with how=UNSTABLE4")
-    res = c.commit_file(fh, 0xfffffffffffffff0L, 64)
+    res = c.commit_file(fh, 0xfffffffffffffff0, 64)
     check(res, NFS4ERR_INVAL, "COMMIT with offset + count overflow")
diff --git a/nfs4.1/client41tests/environment.py b/nfs4.1/client41tests/environment.py
index 6b48d12..7c7bb0c 100644
--- a/nfs4.1/client41tests/environment.py
+++ b/nfs4.1/client41tests/environment.py
@@ -373,7 +373,7 @@ def clean_dir(sess, path):
             res = sess.compound(ops)
         check(res, msg="Trying to remove %s" % repr(e.name))
 
-def do_readdir(sess, file, cookie=0, cookieverf='', attrs=0L,
+def do_readdir(sess, file, cookie=0, cookieverf='', attrs=0,
                dircount=4096, maxcount=4096):
     # Since we may not get whole directory listing in one readdir request,
     # loop until we do. For each request result, create a flat list
diff --git a/nfs4.1/dataserver.py b/nfs4.1/dataserver.py
index f32f3d7..80179f8 100644
--- a/nfs4.1/dataserver.py
+++ b/nfs4.1/dataserver.py
@@ -206,7 +206,7 @@ class DataServer41(DataServer):
 
     def get_size(self, fh):
         ops = [op4.putfh(fh),
-               op4.getattr(1L << const4.FATTR4_SIZE)]
+               op4.getattr(1 << const4.FATTR4_SIZE)]
         res = self._execute(ops)
         attrdict = res.resarray[-1].obj_attributes
         return attrdict.get(const4.FATTR4_SIZE, 0)
diff --git a/nfs4.1/fs.py b/nfs4.1/fs.py
index d9b58f2..b0b06d5 100644
--- a/nfs4.1/fs.py
+++ b/nfs4.1/fs.py
@@ -306,7 +306,7 @@ class FSObject(object):
         # STUB - need to check principal, and set owner/group if needed
         log_o.log(5, "FSObject.set_attrs(%r)" % attrs)
         info = nfs4lib.attr_info
-        bitmap = 0L
+        bitmap = 0
         try:
             for attr in attrs:
                 if self.fs.fattr4_supported_attrs & attr == 0:
diff --git a/nfs4.1/nfs4client.py b/nfs4.1/nfs4client.py
index 708850d..135981d 100644
--- a/nfs4.1/nfs4client.py
+++ b/nfs4.1/nfs4client.py
@@ -611,7 +611,7 @@ sha256 = '`\x86H\x01e\x03\x04\x02\x01'
 binding_opts = conn_binding4args(True, ["gibberish", sha256])
 fore_attrs = channel_attrs4(4096,4096,4096,128,8,[])
 cb_sec= callback_sec_parms4(0)
-C.compound([C.create_session_op(0,1,0L,0,binding_opts, fore_attrs, fore_attrs,123,[cb_sec])])
+C.compound([C.create_session_op(0,1,0,0,binding_opts, fore_attrs, fore_attrs,123,[cb_sec])])
 """
 
 """ SEQUENCE
diff --git a/nfs4.1/nfs4lib.py b/nfs4.1/nfs4lib.py
index 96752c2..20eae0f 100644
--- a/nfs4.1/nfs4lib.py
+++ b/nfs4.1/nfs4lib.py
@@ -194,7 +194,7 @@ class FancyNFS4Packer(NFS4Packer):
     def filter_bitmap4(self, data):
         out = []
         while data:
-            out.append(data & 0xffffffffL)
+            out.append(data & 0xffffffff)
             data >>= 32
         return out
 
@@ -217,7 +217,7 @@ class FancyNFS4Packer(NFS4Packer):
 class FancyNFS4Unpacker(NFS4Unpacker):
     def filter_bitmap4(self, data):
         """Put bitmap into single long, instead of array of 32bit chunks"""
-        out = 0L
+        out = 0
         shift = 0
         for i in data:
             out |= (long(i) << shift)
@@ -276,9 +276,9 @@ def fattr2dict(obj):
 
 def list2bitmap(list):
     """Construct a bitmap from a list of bit numbers"""
-    mask = 0L
+    mask = 0
     for bit in list:
-        mask |= 1L << bit
+        mask |= 1 << bit
     return mask
 
 def bitmap2list(bitmap):
@@ -565,7 +565,7 @@ def attr_name(bitnum):
     return bitnum2attr.get(bitnum, "unknown_%r" % bitnum)
 
 class NFS4Error(Exception):
-    def __init__(self, status, attrs=0L, lock_denied=None, tag=None, check_msg=None):
+    def __init__(self, status, attrs=0, lock_denied=None, tag=None, check_msg=None):
         self.status = status
         self.name = xdrdef.nfs4_const.nfsstat4[status]
         if check_msg is None:
diff --git a/nfs4.1/nfs4server.py b/nfs4.1/nfs4server.py
index f8bd251..cd78082 100755
--- a/nfs4.1/nfs4server.py
+++ b/nfs4.1/nfs4server.py
@@ -212,7 +212,7 @@ class ClientList(object):
     def __init__(self):
         self._data = {}
         self.lock = Lock("ClientList")
-        self._nextid = 0L
+        self._nextid = 0
 
     def __getitem__(self, key):
         return self._data.get(key)
@@ -1381,7 +1381,7 @@ class NFS4Server(rpc.Server):
 
     def open_claim_null(self, arg, env):
         """Simulated switch function from op_open that handles CLAIM_NULL"""
-        bitmask = 0L
+        bitmask = 0
         # cfh holds dir, claim.file holds name
         if not env.cfh.isdir:
             raise NFS4Error(NFS4ERR_NOTDIR)
diff --git a/nfs4.1/server41tests/environment.py b/nfs4.1/server41tests/environment.py
index 1a837ee..823dfe3 100644
--- a/nfs4.1/server41tests/environment.py
+++ b/nfs4.1/server41tests/environment.py
@@ -139,7 +139,7 @@ class Environment(testmod.Environment):
         self.filedata = "This is the file test data."
         self.linkdata = "/etc/X11"
         self.stateid0 = stateid4(0, '')
-        self.stateid1 = stateid4(0xffffffffL, '\xff'*12)
+        self.stateid1 = stateid4(0xffffffff, '\xff'*12)
 
         log.info("Created client to %s, %i" % (opts.server, opts.port))
 
@@ -429,7 +429,7 @@ def clean_dir(sess, path):
             res = sess.compound(ops)
         check(res, msg="Trying to remove %s" % repr(e.name))
 
-def do_readdir(sess, file, cookie=0, cookieverf='', attrs=0L,
+def do_readdir(sess, file, cookie=0, cookieverf='', attrs=0,
                dircount=4096, maxcount=4096):
     # Since we may not get whole directory listing in one readdir request,
     # loop until we do. For each request result, create a flat list
diff --git a/nfs4.1/server41tests/st_debug.py b/nfs4.1/server41tests/st_debug.py
index e34d03f..345fc77 100644
--- a/nfs4.1/server41tests/st_debug.py
+++ b/nfs4.1/server41tests/st_debug.py
@@ -89,7 +89,7 @@ def testDeadlock(t, env):
     def ops(i):
         return [op.putfh(fh),
                 op.write(stateid, i*1000, UNSTABLE4, chr(97+i)*100),
-                op.getattr(42950721818L)
+                op.getattr(42950721818)
                 ]
     xids = [sess1.compound_async(ops(i), slot=i) for i in range(4)]
     for xid in xids:
diff --git a/nfs4.1/testmod.py b/nfs4.1/testmod.py
index 8108a23..21e9915 100644
--- a/nfs4.1/testmod.py
+++ b/nfs4.1/testmod.py
@@ -374,7 +374,7 @@ def createtests(testdir):
     # Reduce doc string info into format easier to work with
     used_codes = {}
     flag_dict = {}
-    bit = 1L
+    bit = 1
     for t in tests:
 ##         if not t.flags_list:
 ##             raise RuntimeError("%s has no flags" % t.fullname)
diff --git a/rpc/rpc.py b/rpc/rpc.py
index 834fedd..af2b325 100644
--- a/rpc/rpc.py
+++ b/rpc/rpc.py
@@ -265,8 +265,8 @@ class Pipe(object):
                 # We don't even have the packet length yet, wait for more data
                 break
             packetlen = struct.unpack('>L', buf[0:4])[0]
-            last = 0x80000000L & packetlen
-            packetlen &= 0x7fffffffL
+            last = 0x80000000 & packetlen
+            packetlen &= 0x7fffffff
             packetlen += 4 # Include size of record mark
             if len(buf) < packetlen:
                 # We don't have a full packet yet, wait for more data
@@ -310,7 +310,7 @@ class Pipe(object):
                 chunk = record[i: i + count]
                 i += count
                 if i >= dlen:
-                    last = 0x80000000L
+                    last = 0x80000000
                 mark = struct.pack('>L', last | len(chunk))
                 out += mark + chunk
             return out
@@ -351,7 +351,7 @@ class RpcPipe(Pipe):
         Pipe.__init__(self, *args, **kwargs)
         self._pending = {} # {xid:defer}
         self._lock = threading.Lock() # Protects fields below
-        self._xid = random.randint(0, 0x7fffffffL)
+        self._xid = random.randint(0, 0x7fffffff)
         self.set_active()
 
     def _get_xid(self):
-- 
2.17.1

