Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:47060 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752915AbeDPIBD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 16 Apr 2018 04:01:03 -0400
From: jiyin@redhat.com
To: bfields@redhat.com
Cc: linux-nfs@vger.kernel.org, "Jianhong.Yin" <yin-jianhong@163.com>,
        Jianhong Yin <jiyin@redhat.com>
Subject: [PATCH] [pynfs] remove redundant nfs4.0/nfs4.x and nfs4.0/lib/ops_gen.py
Date: Mon, 16 Apr 2018 16:00:55 +0800
Message-Id: <20180416080055.23112-1-jiyin@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "Jianhong.Yin" <yin-jianhong@163.com>

remove redundant nfs4.0/nfs4.x and nfs4.0/lib/ops_gen.py
use nfs4.1/xdrdef/nfs4.x and nfs4.1/nfs_ops instead

test log:
'''
[root@test pynfs]# ./setup.py install >/dev/null
[root@test pynfs]# cd nfs4.0
[root@test nfs4.0]# ls -l nfs_ops.py xdrdef
lrwxrwxrwx. 1 root root 20 Apr 13 07:38 nfs_ops.py -> ../nfs4.1/nfs_ops.py
lrwxrwxrwx. 1 root root 16 Apr 13 07:29 xdrdef -> ../nfs4.1/xdrdef
[root@test nfs4.0]# ./testserver.py --outfile log.txt --maketree localhost:/exportdir all &>std.log
[root@test nfs4.0]# tail std.log
WRT13    st_write.testDoubleWrite                                 : PASS
WRT14    st_write.testLargeWrite                                  : PASS
WRT15    st_write.testSizes                                       : PASS
WRT18    st_write.testChangeGranularityWrite                      : FAILURE
           consecutive SETATTR(mode)'s don't all change change
           attribute
WRT19    st_write.testStolenStateid                               : PASS
**************************************************
Command line asked for 585 of 670 tests
Of those: 8 Skipped, 4 Failed, 0 Warned, 573 Passed
'''

Signed-off-by: Jianhong Yin <jiyin@redhat.com>
---
 nfs4.0/lib/ops_gen.py                       |   56 -
 nfs4.0/nfs4.x                               | 1696 ---------------------------
 nfs4.0/nfs4acl.py                           |    4 +-
 nfs4.0/nfs4client.py                        |    6 +-
 nfs4.0/nfs4lib.py                           |  100 +-
 nfs4.0/nfs4server.py                        |    6 +-
 nfs4.0/nfs4state.py                         |    5 +-
 nfs4.0/nfs_ops.py                           |    1 +
 nfs4.0/servertests/environment.py           |   10 +-
 nfs4.0/servertests/st_access.py             |   12 +-
 nfs4.0/servertests/st_acl.py                |    4 +-
 nfs4.0/servertests/st_close.py              |    2 +-
 nfs4.0/servertests/st_commit.py             |    2 +-
 nfs4.0/servertests/st_compound.py           |   16 +-
 nfs4.0/servertests/st_create.py             |   12 +-
 nfs4.0/servertests/st_delegation.py         |   32 +-
 nfs4.0/servertests/st_fslocations.py        |   10 +-
 nfs4.0/servertests/st_getattr.py            |   10 +-
 nfs4.0/servertests/st_getfh.py              |    6 +-
 nfs4.0/servertests/st_gss.py                |   22 +-
 nfs4.0/servertests/st_link.py               |    8 +-
 nfs4.0/servertests/st_lock.py               |    8 +-
 nfs4.0/servertests/st_lockt.py              |    2 +-
 nfs4.0/servertests/st_locku.py              |    4 +-
 nfs4.0/servertests/st_lookup.py             |   22 +-
 nfs4.0/servertests/st_lookupp.py            |   30 +-
 nfs4.0/servertests/st_nverify.py            |   16 +-
 nfs4.0/servertests/st_open.py               |    2 +-
 nfs4.0/servertests/st_openconfirm.py        |   10 +-
 nfs4.0/servertests/st_opendowngrade.py      |    2 +-
 nfs4.0/servertests/st_putfh.py              |   14 +-
 nfs4.0/servertests/st_putpubfh.py           |   10 +-
 nfs4.0/servertests/st_putrootfh.py          |    6 +-
 nfs4.0/servertests/st_read.py               |    2 +-
 nfs4.0/servertests/st_readdir.py            |    2 +-
 nfs4.0/servertests/st_readlink.py           |   20 +-
 nfs4.0/servertests/st_reboot.py             |   10 +-
 nfs4.0/servertests/st_releaselockowner.py   |    8 +-
 nfs4.0/servertests/st_remove.py             |   52 +-
 nfs4.0/servertests/st_rename.py             |    4 +-
 nfs4.0/servertests/st_renew.py              |   10 +-
 nfs4.0/servertests/st_replay.py             |   32 +-
 nfs4.0/servertests/st_restorefh.py          |   14 +-
 nfs4.0/servertests/st_savefh.py             |    6 +-
 nfs4.0/servertests/st_secinfo.py            |   18 +-
 nfs4.0/servertests/st_setattr.py            |   12 +-
 nfs4.0/servertests/st_setclientid.py        |   10 +-
 nfs4.0/servertests/st_setclientidconfirm.py |   12 +-
 nfs4.0/servertests/st_spoof.py              |    2 +-
 nfs4.0/servertests/st_verify.py             |   20 +-
 nfs4.0/servertests/st_write.py              |   28 +-
 nfs4.0/setup.py                             |   27 +-
 nfs4.0/testserver.py                        |    2 +-
 nfs4.0/xdrdef                               |    1 +
 54 files changed, 377 insertions(+), 2061 deletions(-)
 delete mode 100755 nfs4.0/lib/ops_gen.py
 delete mode 100644 nfs4.0/nfs4.x
 create mode 120000 nfs4.0/nfs_ops.py
 create mode 120000 nfs4.0/xdrdef

diff --git a/nfs4.0/lib/ops_gen.py b/nfs4.0/lib/ops_gen.py
deleted file mode 100755
index a677a10..0000000
diff --git a/nfs4.0/nfs4.x b/nfs4.0/nfs4.x
deleted file mode 100644
index 01ffa5f..0000000
diff --git a/nfs4.0/nfs4acl.py b/nfs4.0/nfs4acl.py
index 2bef2ca..8ae32e2 100644
--- a/nfs4.0/nfs4acl.py
+++ b/nfs4.0/nfs4acl.py
@@ -10,8 +10,8 @@
 # Taken from mapping description at
 # http://www.citi.umich.edu/projects/nfsv4/rfc/draft-ietf-nfsv4-acl-mapping-02.txt
 
-from nfs4_const import *
-from nfs4_type import *
+from xdrdef.nfs4_const import *
+from xdrdef.nfs4_type import *
 
 # Taken from mapping
 MODE_R = ACE4_READ_DATA | ACE4_READ_NAMED_ATTRS
diff --git a/nfs4.0/nfs4client.py b/nfs4.0/nfs4client.py
index d76eddb..90c8d2c 100755
--- a/nfs4.0/nfs4client.py
+++ b/nfs4.0/nfs4client.py
@@ -28,9 +28,9 @@ except ImportError:
 #    readline.parse_and_bind("tab: complete")
 #import cmd
 import nfs4lib
-import nfs4_type
-import nfs4_const
-import nfs4_pack
+import xdrdef.nfs4_type
+import xdrdef.nfs4_const
+import xdrdef.nfs4_pack
 import code
 import traceback
 
diff --git a/nfs4.0/nfs4lib.py b/nfs4.0/nfs4lib.py
index 5031feb..600bce0 100644
--- a/nfs4.0/nfs4lib.py
+++ b/nfs4.0/nfs4lib.py
@@ -29,12 +29,11 @@
 import rpc
 import threading
 from xdrlib import Error as XDRError
-import nfs4_const
-from nfs4_const import *
-import nfs4_type
-from nfs4_type import *
-import nfs4_pack
-import nfs4_ops
+import xdrdef.nfs4_const as nfs4_const
+from xdrdef.nfs4_const import *
+import xdrdef.nfs4_type as nfs4_type
+from xdrdef.nfs4_type import *
+import xdrdef.nfs4_pack as nfs4_pack
 import time
 import struct
 import socket
@@ -43,6 +42,9 @@ import re
 import inspect
 from os.path import basename
 
+import nfs_ops
+op4 = nfs_ops.NFS4ops()
+
 class NFSException(rpc.RPCError):
     pass
 
@@ -269,7 +271,7 @@ class CBServer(rpc.RPCServer):
 # STUB
 AuthSys = rpc.SecAuthSys(0,'jupiter',103558,100,[])
 
-class NFS4Client(rpc.RPCClient, nfs4_ops.NFS4Operations):
+class NFS4Client(rpc.RPCClient):
     def __init__(self, id, host='localhost', port=2049, homedir=['pynfs'],
                  sec_list=[AuthSys], opts=None):
         self._start_cb_server("cb_server_%s" % id)
@@ -391,7 +393,7 @@ class NFS4Client(rpc.RPCClient, nfs4_ops.NFS4Operations):
         self.clientid = res.resarray[0].switch.switch.clientid
         confirm = res.resarray[0].switch.switch.setclientid_confirm
         # SETCLIENTID_CONFIRM
-        confirmop = self.setclientid_confirm_op(self.clientid, confirm)
+        confirmop = op4.setclientid_confirm(self.clientid, confirm)
         res = self.compound([confirmop])
         try: check_result(res)
         except BadCompoundRes:
@@ -419,7 +421,7 @@ class NFS4Client(rpc.RPCClient, nfs4_ops.NFS4Operations):
         cb_location = clientaddr4('tcp', r_addr)
         callback = cb_client4(self.cb_server.prog, cb_location)
 
-        return self.setclientid_op(client_id, callback, cb_ident)
+        return op4.setclientid(client_id, callback, cb_ident)
 
     def get_cbid(self):
         self.cbid += 1
@@ -443,21 +445,21 @@ class NFS4Client(rpc.RPCClient, nfs4_ops.NFS4Operations):
 
     def getattr(self, attrlist=[]):
         # The argument to GETATTR4args is a list of integers.
-        return self.getattr_op(list2bitmap(attrlist))
+        return op4.getattr(list2bitmap(attrlist))
 
     def readdir(self, cookie=0, cookieverf='', dircount=0, maxcount=4096,
                 attr_request=[]):
         attrs = list2bitmap(attr_request)
-        return self.readdir_op(cookie, cookieverf, dircount, maxcount, attrs)
+        return op4.readdir(cookie, cookieverf, dircount, maxcount, attrs)
 
     def setattr(self, attrdict, stateid=None):
         if stateid is None: stateid = stateid4(0, "")
-        return self.setattr_op(stateid, attrdict)
+        return op4.setattr(stateid, attrdict)
 
     def link(self, old, new):
-        ops = self.use_obj(old) + [self.savefh_op()]
+        ops = self.use_obj(old) + [op4.savefh()]
         ops += self.use_obj(new[:-1])
-        ops += [self.link_op(new[-1])]
+        ops += [op4.link(new[-1])]
         return self.compound(ops)
 
     def open(self, owner, name=None, type=OPEN4_NOCREATE,
@@ -474,26 +476,26 @@ class NFS4Client(rpc.RPCClient, nfs4_ops.NFS4Operations):
         elif type == OPEN4_CREATE:
             openhow = openflag4(type, createhow4(mode, attrs, verf))
         claim = open_claim4(claim_type, name, deleg_type, deleg_cur_info)
-        return self.open_op(seqid, access, deny, openowner, openhow, claim)
+        return op4.open(seqid, access, deny, openowner, openhow, claim)
 
     def lookup_path(self, dir):
-        return [self.lookup_op(comp) for comp in dir]
+        return [op4.lookup(comp) for comp in dir]
 
     def lookupp_path(self, dir):
-    	return [self.lookupp_op() for comp in dir]
+    	return [op4.lookupp() for comp in dir]
 
     def go_home(self):
         """Return LOOKUP ops to get to homedir"""
-        return [self.putrootfh_op()] + self.lookup_path(self.homedir)
+        return [op4.putrootfh()] + self.lookup_path(self.homedir)
 
     def use_obj(self, file):
         """File is either None, a fh, or a list of path components"""
         if file is None or file == [None]:
             return []
         elif type(file) is str:
-            return [self.putfh_op(file)]
+            return [op4.putfh(file)]
         else:
-            return [self.putrootfh_op()] + self.lookup_path(file)
+            return [op4.putrootfh()] + self.lookup_path(file)
 
     def do_getattrdict(self, file, attrlist):
         """file can be either a fh or a path"""
@@ -514,8 +516,8 @@ class NFS4Client(rpc.RPCClient, nfs4_ops.NFS4Operations):
 
     def do_getfh(self, path):
         """Get filehandle"""
-        ops = [self.putrootfh_op()] + self.lookup_path(path)
-        ops += [self.getfh_op()]
+        ops = [op4.putrootfh()] + self.lookup_path(path)
+        ops += [op4.getfh()]
         res = self.compound(ops)
         check_result(res)
         return res.resarray[-1].switch.switch.object
@@ -533,7 +535,7 @@ class NFS4Client(rpc.RPCClient, nfs4_ops.NFS4Operations):
         count = 0
         while 1:
             count += 1
-            readdirop = self.readdir_op(cookie, cookieverf,
+            readdirop = op4.readdir(cookie, cookieverf,
                                         dircount, maxcount, attrs)
             res = self.compound(baseops + [readdirop])
             check_result(res, "READDIR with cookie=%i, maxcount=%i" %
@@ -565,11 +567,11 @@ class NFS4Client(rpc.RPCClient, nfs4_ops.NFS4Operations):
         entries = self.do_readdir(fh)
         for e in entries:
             # We separate setattr and remove to avoid an inode locking bug
-            ops = [self.putfh_op(fh), self.lookup_op(e.name)]
-            ops += [self.setattr_op(stateid, {FATTR4_MODE:0755})]
+            ops = [op4.putfh(fh), op4.lookup(e.name)]
+            ops += [op4.setattr(stateid, {FATTR4_MODE:0755})]
             res = self.compound(ops)
             check_result(res, "Making sure %s is writable" % repr(e.name))
-            ops = [self.putfh_op(fh), self.remove_op(e.name)]
+            ops = [op4.putfh(fh), op4.remove(e.name)]
             res = self.compound(ops)
             if res.status == NFS4ERR_NOTEMPTY:
                 self.clean_dir(path + [e.name])
@@ -591,7 +593,7 @@ class NFS4Client(rpc.RPCClient, nfs4_ops.NFS4Operations):
                    linkdata="/etc/X11"):
         if __builtins__['type'](path) is str:
             path = self.homedir + [path]
-        ops = [self.putrootfh_op()] + self.lookup_path(path[:-1])
+        ops = [op4.putrootfh()] + self.lookup_path(path[:-1])
         if type in [NF4DIR, NF4SOCK, NF4FIFO, NF4REG]:
             objtype = createtype4(type)
         elif type == NF4LNK:
@@ -599,16 +601,16 @@ class NFS4Client(rpc.RPCClient, nfs4_ops.NFS4Operations):
         elif type in [NF4BLK, NF4CHR]:
             devdata = specdata4(1, 2)
             objtype = createtype4(type, devdata=devdata)
-        ops += [self.create_op(objtype, path[-1], attrs)]
+        ops += [op4.create(objtype, path[-1], attrs)]
         return self.compound(ops)
 
     def rename_obj(self, oldpath, newpath):
         # Set (sfh) to olddir
-        ops = self.use_obj(oldpath[:-1]) + [self.savefh_op()]
+        ops = self.use_obj(oldpath[:-1]) + [op4.savefh()]
         # Set (cfh) to newdir
         ops += self.use_obj(newpath[:-1])
         # Call rename
-        ops += [self.rename_op(oldpath[-1], newpath[-1])]
+        ops += [op4.rename(oldpath[-1], newpath[-1])]
         return self.compound(ops)
 
     def create_file(self, owner, path=None, attrs={FATTR4_MODE: 0644},
@@ -632,7 +634,7 @@ class NFS4Client(rpc.RPCClient, nfs4_ops.NFS4Operations):
         ops = self.use_obj(dir)
         ops += [self.open(owner, name, OPEN4_CREATE, mode, attrs, verifier,
                           access, deny)]
-        ops += [self.getfh_op()]
+        ops += [op4.getfh()]
         res = self.compound(ops)
         self.advance_seqid(owner, res)
         if set_recall and (res.status != NFS4_OK or \
@@ -661,14 +663,14 @@ class NFS4Client(rpc.RPCClient, nfs4_ops.NFS4Operations):
                 self.cb_server.set_cb_recall(self.cbid,
                                              recall_funct, recall_return)
         elif claim_type==CLAIM_PREVIOUS:
-            ops = [self.putfh_op(path)]
+            ops = [op4.putfh(path)]
         elif claim_type==CLAIM_DELEGATE_CUR:
             ops = self.use_obj(dir)
             deleg_cur_info = open_claim_delegate_cur4(deleg_stateid, name)
         ops += [self.open(owner, name, access=access, deny=deny,
                           claim_type=claim_type, deleg_type=deleg_type,
                           deleg_cur_info=deleg_cur_info)]
-        ops += [self.getfh_op()]
+        ops += [op4.getfh()]
         res = self.compound(ops)
         self.advance_seqid(owner, res)
         if set_recall and (res.status != NFS4_OK or \
@@ -691,8 +693,8 @@ class NFS4Client(rpc.RPCClient, nfs4_ops.NFS4Operations):
         stateid = res.resarray[-2].switch.switch.stateid
         rflags = res.resarray[-2].switch.switch.rflags
         if rflags & OPEN4_RESULT_CONFIRM:
-            ops = [self.putfh_op(fhandle)]
-            ops += [self.open_confirm_op(stateid, self.get_seqid(owner))]
+            ops = [op4.putfh(fhandle)]
+            ops += [op4.open_confirm(stateid, self.get_seqid(owner))]
             res = self.compound(ops)
             self.advance_seqid(owner, res)
             check_result(res)
@@ -732,13 +734,13 @@ class NFS4Client(rpc.RPCClient, nfs4_ops.NFS4Operations):
 ##         if fh is None:
 ##             ops = []
 ##         else:
-##             ops = [self.putfh_op(fh)]
+##             ops = [op4.putfh(fh)]
 ##         claim = open_claim4(CLAIM_PREVIOUS,
 ##                             delegate_type=OPEN_DELEGATE_NONE)
 ##         openowner = open_owner4(self.clientid, owner)
 ##         how = openflag4(OPEN4_NOCREATE)
-##         ops += [self.open_op(seqid, access, deny, openowner, how, claim)]
-##         ops += [self.getfh_op()]
+##         ops += [op4.open(seqid, access, deny, openowner, how, claim)]
+##         ops += [op4.getfh()]
 ##         res = self.compound(ops)
 ##         self.advance_seqid(owner, res)
 ##         check(res, error, msg)
@@ -754,7 +756,7 @@ class NFS4Client(rpc.RPCClient, nfs4_ops.NFS4Operations):
                        seqid=None):
         if seqid is None: seqid = self.get_seqid(owner)
         ops = self.use_obj(file)
-        ops += [self.open_downgrade_op(stateid, seqid, access, deny)]
+        ops += [op4.open_downgrade(stateid, seqid, access, deny)]
         res = self.compound(ops)
         self.advance_seqid(owner, res)
         if res.status == NFS4_OK:
@@ -764,7 +766,7 @@ class NFS4Client(rpc.RPCClient, nfs4_ops.NFS4Operations):
     def write_file(self, file, data, offset=0, stateid=stateid4(0, ''),
                    how=FILE_SYNC4):
         ops = self.use_obj(file)
-        ops += [self.write_op(stateid, offset, how, data)]
+        ops += [op4.write(stateid, offset, how, data)]
         res = self.compound(ops)
         if res.status == NFS4_OK:
             res.count = res.resarray[-1].switch.switch.count
@@ -773,7 +775,7 @@ class NFS4Client(rpc.RPCClient, nfs4_ops.NFS4Operations):
     
     def read_file(self, file, offset=0, count=2048, stateid=stateid4(0, '')):
         ops =  self.use_obj(file)
-        ops += [self.read_op(stateid, offset, count)]
+        ops += [op4.read(stateid, offset, count)]
         res = self.compound(ops)
         if res.status == NFS4_OK:
             res.eof = res.resarray[-1].switch.switch.eof
@@ -795,7 +797,7 @@ class NFS4Client(rpc.RPCClient, nfs4_ops.NFS4Operations):
         nfs4_open_owner = open_to_lock_owner4(openseqid, openstateid,
                                               lockseqid, nfs4_lock_owner)
         locker = locker4(TRUE, open_owner=nfs4_open_owner)
-        ops += [self.lock_op(type, FALSE, offset, len, locker)]
+        ops += [op4.lock(type, FALSE, offset, len, locker)]
         res = self.compound(ops)
         self.advance_seqid(openowner, res)
         if res.status == NFS4_OK:
@@ -806,10 +808,10 @@ class NFS4Client(rpc.RPCClient, nfs4_ops.NFS4Operations):
                     offset=0, len=0xffffffffffffffff, type=WRITE_LT):
         """Lock the file using stateid and seqid from previous lock operation
         """
-        ops = [self.putfh_op(fh)]
+        ops = [op4.putfh(fh)]
         existing_lock_owner = exist_lock_owner4(stateid, seqid)
         locker = locker4(FALSE, lock_owner=existing_lock_owner)
-        ops += [self.lock_op(type, FALSE, offset, len, locker)]
+        ops += [op4.lock(type, FALSE, offset, len, locker)]
         res = self.compound(ops)
         if res.status==NFS4_OK:
             res.lockid = res.resarray[-1].switch.switch.lock_stateid
@@ -818,7 +820,7 @@ class NFS4Client(rpc.RPCClient, nfs4_ops.NFS4Operations):
     def unlock_file(self, seqid, file, stateid,
                     offset=0, len=0xffffffffffffffff):
         ops = self.use_obj(file)
-        ops += [self.locku_op(READ_LT, seqid, stateid, offset, len)]
+        ops += [op4.locku(READ_LT, seqid, stateid, offset, len)]
         res = self.compound(ops)
         if res.status==NFS4_OK:
             res.lockid = res.resarray[-1].switch.lock_stateid
@@ -828,7 +830,7 @@ class NFS4Client(rpc.RPCClient, nfs4_ops.NFS4Operations):
                   tester="tester"):
         ops = self.use_obj(file)
         test_owner = lock_owner4(self.clientid, tester)
-        ops += [self.lockt_op(type, offset, len, test_owner)]
+        ops += [op4.lockt(type, offset, len, test_owner)]
         return self.compound(ops)
                   
     def close_file(self, owner, fh, stateid, seqid=None):
@@ -837,15 +839,15 @@ class NFS4Client(rpc.RPCClient, nfs4_ops.NFS4Operations):
         if fh is None:
             ops = []
         else:
-            ops = [self.putfh_op(fh)]
-        ops += [self.close_op(seqid, stateid)]
+            ops = [op4.putfh(fh)]
+        ops += [op4.close(seqid, stateid)]
         res = self.compound(ops)
         self.advance_seqid(owner, res)
         return res
 
     def commit_file(self, file, offset=0, count=0):
         ops = self.use_obj(file)
-        ops += [self.commit_op(offset, count)]
+        ops += [op4.commit(offset, count)]
         return self.compound(ops)
 
     def maketree(self, tree, root=None, owner=None):
diff --git a/nfs4.0/nfs4server.py b/nfs4.0/nfs4server.py
index bd848ca..37c1528 100755
--- a/nfs4.0/nfs4server.py
+++ b/nfs4.0/nfs4server.py
@@ -25,9 +25,9 @@ if  __name__ == "__main__":
     if os.path.isfile(os.path.join(sys.path[0], 'lib', 'testmod.py')):
         sys.path.insert(1, os.path.join(sys.path[0], 'lib'))
 
-from nfs4_const import *
-from nfs4_type import *
-import nfs4_pack
+from xdrdef.nfs4_const import *
+from xdrdef.nfs4_type import *
+import xdrdef.nfs4_pack as nfs4_pack
 import rpc.rpc as rpc
 import nfs4lib
 import time, StringIO, random, traceback, codecs
diff --git a/nfs4.0/nfs4state.py b/nfs4.0/nfs4state.py
index b6de12f..d32da29 100755
--- a/nfs4.0/nfs4state.py
+++ b/nfs4.0/nfs4state.py
@@ -1,6 +1,5 @@
-from nfs4_const import *
-from nfs4_type import *
-import nfs4_pack
+from xdrdef.nfs4_const import *
+from xdrdef.nfs4_type import *
 import rpc.rpc
 import nfs4acl
 import nfs4lib
diff --git a/nfs4.0/nfs_ops.py b/nfs4.0/nfs_ops.py
new file mode 120000
index 0000000..8d04f4e
--- /dev/null
+++ b/nfs4.0/nfs_ops.py
@@ -0,0 +1 @@
+../nfs4.1/nfs_ops.py
\ No newline at end of file
diff --git a/nfs4.0/servertests/environment.py b/nfs4.0/servertests/environment.py
index 11658b3..4f37d0f 100644
--- a/nfs4.0/servertests/environment.py
+++ b/nfs4.0/servertests/environment.py
@@ -11,12 +11,14 @@
 import time
 import testmod
 from nfs4lib import NFS4Client, get_attrbitnum_dict
-from nfs4_const import *
-from nfs4_type import fsid4, nfsace4, fs_locations4, fs_location4, \
+from xdrdef.nfs4_const import *
+from xdrdef.nfs4_type import fsid4, nfsace4, fs_locations4, fs_location4, \
      specdata4, nfstime4, settime4, stateid4
 import rpc
 import sys
 import os
+import nfs_ops
+op = nfs_ops.NFS4ops()
 
 class AttrInfo(object):
     def __init__(self, name, access, sample):
@@ -185,8 +187,8 @@ class Environment(testmod.Environment):
         c.init_connection()
         fh, stateid = c.create_confirm('maketree', tree + ['file'],
                                        deny=OPEN4_SHARE_DENY_NONE)
-        ops = [c.putfh_op(fh),
-               c.write_op(stateid, 0, FILE_SYNC4, self.filedata)]
+        ops = [op.putfh(fh),
+               op.write(stateid, 0, FILE_SYNC4, self.filedata)]
         res = c.compound(ops)
         check(res, msg="Writing data to /%s/file" % '/'.join(tree))
         res = c.close_file('maketree', fh, stateid )
diff --git a/nfs4.0/servertests/st_access.py b/nfs4.0/servertests/st_access.py
index f0d606a..58c42bc 100644
--- a/nfs4.0/servertests/st_access.py
+++ b/nfs4.0/servertests/st_access.py
@@ -1,5 +1,7 @@
-from nfs4_const import *
+from xdrdef.nfs4_const import *
 from environment import check
+import nfs_ops
+op = nfs_ops.NFS4ops()
 
 _maxval = ACCESS4_DELETE | ACCESS4_EXECUTE | ACCESS4_EXTEND | \
           ACCESS4_LOOKUP | ACCESS4_MODIFY | ACCESS4_READ
@@ -9,7 +11,7 @@ _invalid_access_ops = [64, 65, 66, 127, 128, 129]
 def _try_all_combos(t, c, path, forbid=0):
     baseops = c.use_obj(path)
     for i in _valid_access_ops:
-        res = c.compound(baseops + [c.access_op(i)])
+        res = c.compound(baseops + [op.access(i)])
         check(res)
         supported = res.resarray[-1].switch.switch.supported
         access = res.resarray[-1].switch.switch.access
@@ -31,14 +33,14 @@ def _try_all_combos(t, c, path, forbid=0):
 
 def _try_read(c, path):
     ops = c.use_obj(path)
-    ops += [c.access_op(ACCESS4_READ)]
+    ops += [op.access(ACCESS4_READ)]
     res = c.compound(ops)
     check(res)
 
 def _try_invalid(t, c, path):
     baseops = c.use_obj(path)
     for i in _invalid_access_ops:
-        res = c.compound(baseops + [c.access_op(i)])
+        res = c.compound(baseops + [op.access(i)])
         if res.status == NFS4_OK:
             supported = res.resarray[-1].switch.switch.supported
             access = res.resarray[-1].switch.switch.access
@@ -188,7 +190,7 @@ def testNoFh(t, env):
     CODE: ACC3
     """
     c = env.c1
-    res = c.compound([c.access_op(ACCESS4_READ)])
+    res = c.compound([op.access(ACCESS4_READ)])
     check(res, NFS4ERR_NOFILEHANDLE, "ACCESS with no <cfh>")
 
 def testInvalidsFile(t, env):
diff --git a/nfs4.0/servertests/st_acl.py b/nfs4.0/servertests/st_acl.py
index b447289..88667d2 100644
--- a/nfs4.0/servertests/st_acl.py
+++ b/nfs4.0/servertests/st_acl.py
@@ -1,6 +1,6 @@
-from nfs4_const import *
+from xdrdef.nfs4_const import *
 from environment import check
-from nfs4_type import nfsace4
+from xdrdef.nfs4_type import nfsace4
 from nfs4lib import list2bitmap
 
 # assuming server will accept any small positive integer as an owner
diff --git a/nfs4.0/servertests/st_close.py b/nfs4.0/servertests/st_close.py
index 9311bec..1690fad 100644
--- a/nfs4.0/servertests/st_close.py
+++ b/nfs4.0/servertests/st_close.py
@@ -1,4 +1,4 @@
-from nfs4_const import *
+from xdrdef.nfs4_const import *
 from environment import check, makeStaleId
 
 
diff --git a/nfs4.0/servertests/st_commit.py b/nfs4.0/servertests/st_commit.py
index bdeceae..e903739 100644
--- a/nfs4.0/servertests/st_commit.py
+++ b/nfs4.0/servertests/st_commit.py
@@ -1,4 +1,4 @@
-from nfs4_const import *
+from xdrdef.nfs4_const import *
 from environment import check
 
 _text = "Random data to write"
diff --git a/nfs4.0/servertests/st_compound.py b/nfs4.0/servertests/st_compound.py
index 0aa5148..4919289 100644
--- a/nfs4.0/servertests/st_compound.py
+++ b/nfs4.0/servertests/st_compound.py
@@ -1,8 +1,10 @@
-from nfs4_const import *
-from nfs4_type import nfs_argop4
-from nfs4_pack import NFS4Packer
+from xdrdef.nfs4_const import *
+from xdrdef.nfs4_type import nfs_argop4
+from xdrdef.nfs4_pack import NFS4Packer
 from environment import check, get_invalid_utf8strings
 from rpc import RPCError
+import nfs_ops
+op = nfs_ops.NFS4ops()
 
 def testZeroOps(t, env):
     """COMPOUND without operations should return NFS4_OK
@@ -22,7 +24,7 @@ def testGoodTag(t, env):
     """
     c = env.c1
     tag = 'tag test'
-    res = c.compound([c.putrootfh_op()], tag)
+    res = c.compound([op.putrootfh()], tag)
     check(res)
     if res.tag != tag:
         t.fail("Returned tag '%s' does not equal sent tag '%s'" %
@@ -36,7 +38,7 @@ def testBadTags(t, env):
     """
     c = env.c1
     for tag in get_invalid_utf8strings():
-        res = c.compound([c.putrootfh_op()], tag)
+        res = c.compound([op.putrootfh()], tag)
         check(res, NFS4ERR_INVAL, "Compound with invalid utf8 tag %s" %
               repr(tag))
         if res.tag != tag:
@@ -50,7 +52,7 @@ def testInvalidMinor(t, env):
     CODE: COMP4
     """
     c = env.c1
-    res = c.compound([c.putrootfh_op()], minorversion=50)
+    res = c.compound([op.putrootfh()], minorversion=50)
     check(res, NFS4ERR_MINOR_VERS_MISMATCH,
           "COMPOUND with invalid minor version")
     if res.resarray:
@@ -93,7 +95,7 @@ def testLongCompound(t, env):
     CODE: COMP6
     """
     c = env.c1
-    baseops = [c.putrootfh_op(), c.getfh_op(), c.getattr([FATTR4_SIZE])]
+    baseops = [op.putrootfh(), op.getfh(), c.getattr([FATTR4_SIZE])]
     step = 50
     count = 0
     try:
diff --git a/nfs4.0/servertests/st_create.py b/nfs4.0/servertests/st_create.py
index 149c8d7..7017fdf 100644
--- a/nfs4.0/servertests/st_create.py
+++ b/nfs4.0/servertests/st_create.py
@@ -1,6 +1,8 @@
-from nfs4_const import *
-from nfs4_type import createtype4, specdata4
+from xdrdef.nfs4_const import *
+from xdrdef.nfs4_type import createtype4, specdata4
 from environment import check
+import nfs_ops
+op = nfs_ops.NFS4ops()
 
 def getDefaultAttr(c):
     attr = {}
@@ -13,7 +15,7 @@ def _test_create(t, env, type, name, **keywords):
     c = env.c1
     ops = c.go_home()
     objtype = createtype4(type, **keywords)
-    ops += [c.create_op(objtype, t.code, getDefaultAttr(c))]
+    ops += [op.create(objtype, t.code, getDefaultAttr(c))]
     res = c.compound(ops)
     if res.status == NFS4ERR_BADTYPE:
         t.fail_support("CREATE of a %s returns _BADTYPE" % name)
@@ -147,7 +149,7 @@ def testNoFh(t, env):
     """
     c = env.c1
     objtype = createtype4(NF4DIR)
-    ops = [c.create_op(objtype, t.code, getDefaultAttr(c))]
+    ops = [op.create(objtype, t.code, getDefaultAttr(c))]
     res = c.compound(ops)
     check(res, NFS4ERR_NOFILEHANDLE, "CREATE with no <cfh>")
 
@@ -170,7 +172,7 @@ def testZeroLengthForLNK(t, env):
     c = env.c1
     ops = c.go_home()
     objtype = createtype4(NF4LNK, **{'linkdata':''})
-    ops += [c.create_op(objtype, t.code, getDefaultAttr(c))]
+    ops += [op.create(objtype, t.code, getDefaultAttr(c))]
     res = c.compound(ops)
     check(res, [NFS4ERR_INVAL, NFS4ERR_NOENT], "CREATE with zero-length name for SYMLINK")
 
diff --git a/nfs4.0/servertests/st_delegation.py b/nfs4.0/servertests/st_delegation.py
index 1d69fb5..0cc6867 100644
--- a/nfs4.0/servertests/st_delegation.py
+++ b/nfs4.0/servertests/st_delegation.py
@@ -1,9 +1,11 @@
-from nfs4_const import *
-from nfs4_type import nfs_client_id4, clientaddr4, cb_client4
+from xdrdef.nfs4_const import *
+from xdrdef.nfs4_type import nfs_client_id4, clientaddr4, cb_client4
 from environment import check
 import os
 import threading
 import time
+import nfs_ops
+op = nfs_ops.NFS4ops()
 
 _lock = threading.Lock()
 
@@ -26,8 +28,8 @@ class _handle_error(object):
             
 def _recall(c, op, cbid):
     # Note this will be run in the cb_server thread, not the tester thread
-    ops = [c.putfh_op(op.opcbrecall.fh),
-           c.delegreturn_op(op.opcbrecall.stateid)]
+    ops = [op.putfh(op.opcbrecall.fh),
+           op.delegreturn(op.opcbrecall.stateid)]
     _lock.acquire()
     try:
         res = c.compound(ops)
@@ -290,7 +292,7 @@ def testRenew(t, env, funct=None, response=NFS4_OK):
             res = c.open_file('newowner', c.homedir + [t.code],
                               access=OPEN4_SHARE_ACCESS_WRITE)
             env.sleep(lease / 2, "Waiting to send RENEW")
-            res = c.compound([c.renew_op(c.clientid)])
+            res = c.compound([op.renew(c.clientid)])
             check(res, [NFS4_OK, NFS4ERR_CB_PATH_DOWN], "RENEW")
             if res.status != NFS4_OK:
                 noticed = True
@@ -381,7 +383,7 @@ def _set_clientid(c, id, server):
     r_addr = c.ipaddress + server.dotport
     cb_location = clientaddr4('tcp', r_addr)
     callback = cb_client4(server.prog, cb_location)
-    return c.setclientid_op(client_id, callback, 1)
+    return op.setclientid(client_id, callback, 1)
 
 def testChangeDeleg(t, env, funct=_recall):
     """Get a read delegation, change to a different callback server, then
@@ -408,7 +410,7 @@ def testChangeDeleg(t, env, funct=_recall):
     check(res, msg="Switch to new callback server")
     c.clientid = res.resarray[0].switch.switch.clientid
     confirm = res.resarray[0].switch.switch.setclientid_confirm
-    confirmop = c.setclientid_confirm_op(c.clientid, confirm)
+    confirmop = op.setclientid_confirm(c.clientid, confirm)
     res = c.compound([confirmop])
     check(res, [NFS4_OK, NFS4ERR_RESOURCE])
     if res.status == NFS4ERR_RESOURCE:
@@ -531,7 +533,7 @@ def testClaimCur(t, env):
                             claim_type=CLAIM_DELEGATE_CUR,
                             deleg_stateid=deleg_info.read.stateid)
     check(res)
-    ops = c.use_obj(path) + [c.delegreturn_op(deleg_info.read.stateid)]
+    ops = c.use_obj(path) + [op.delegreturn(deleg_info.read.stateid)]
     res = c.compound(ops)
     check(res)
 
@@ -558,7 +560,7 @@ def testRemove(t, env):
     count = c.cb_server.opcounts[OP_CB_RECALL]
     c.init_connection('pynfs%i_%s' % (os.getpid(), t.code), cb_ident=0)
     _get_deleg(t, c, c.homedir + [t.code], _recall, NFS4_OK)
-    ops = c.use_obj(c.homedir) + [c.remove_op(t.code)]
+    ops = c.use_obj(c.homedir) + [op.remove(t.code)]
     _retry_conflicting_op(env, c, ops, "remove")
     _verify_cb_occurred(t, c, count)
 
@@ -575,8 +577,8 @@ def testLink(t, env):
     count = c.cb_server.opcounts[OP_CB_RECALL]
     c.init_connection('pynfs%i_%s' % (os.getpid(), t.code), cb_ident=0)
     _get_deleg(t, c, c.homedir + [t.code], _recall, NFS4_OK)
-    ops = c.use_obj(c.homedir + [t.code]) + [c.savefh_op()];
-    ops += c.use_obj(c.homedir) + [c.link_op(t.code + '.link')];
+    ops = c.use_obj(c.homedir + [t.code]) + [op.savefh()];
+    ops += c.use_obj(c.homedir) + [op.link(t.code + '.link')];
     _retry_conflicting_op(env, c, ops, "link")
     _verify_cb_occurred(t, c, count)
 
@@ -593,8 +595,8 @@ def testRename(t, env):
     count = c.cb_server.opcounts[OP_CB_RECALL]
     c.init_connection('pynfs%i_%s' % (os.getpid(), t.code), cb_ident=0)
     _get_deleg(t, c, c.homedir + [t.code], _recall, NFS4_OK)
-    ops = c.use_obj(c.homedir) + [c.savefh_op()];
-    ops += c.use_obj(c.homedir) + [c.rename_op(t.code, t.code + '.rename')]
+    ops = c.use_obj(c.homedir) + [op.savefh()];
+    ops += c.use_obj(c.homedir) + [op.rename(t.code, t.code + '.rename')]
     _retry_conflicting_op(env, c, ops, "rename")
     _verify_cb_occurred(t, c, count)
 
@@ -612,8 +614,8 @@ def testRenameOver(t, env):
     c.init_connection('pynfs%i_%s' % (os.getpid(), t.code), cb_ident=0)
     res = c.create_file(t.code, c.homedir + [t.code])
     _get_deleg(t, c, c.homedir + [t.code + '.rename'], _recall, NFS4_OK)
-    ops = c.use_obj(c.homedir) + [c.savefh_op()];
-    ops += c.use_obj(c.homedir) + [c.rename_op(t.code, t.code + '.rename')]
+    ops = c.use_obj(c.homedir) + [op.savefh()];
+    ops += c.use_obj(c.homedir) + [op.rename(t.code, t.code + '.rename')]
     _retry_conflicting_op(env, c, ops, "rename")
     _verify_cb_occurred(t, c, count)
 
diff --git a/nfs4.0/servertests/st_fslocations.py b/nfs4.0/servertests/st_fslocations.py
index f02c2f5..102db52 100644
--- a/nfs4.0/servertests/st_fslocations.py
+++ b/nfs4.0/servertests/st_fslocations.py
@@ -1,6 +1,8 @@
-from nfs4_const import *
+from xdrdef.nfs4_const import *
 from nfs4lib import list2bitmap
 from environment import check
+import nfs_ops
+op = nfs_ops.NFS4ops()
 
 def testReference(t, env):
     """FSLOCATION test of referral node
@@ -12,9 +14,9 @@ def testReference(t, env):
     """
     c = env.c1
     path = env.opts.usespecial
-    ops = [c.putrootfh_op(), c.getfh_op()]
+    ops = [op.putrootfh(), op.getfh()]
     for comp in path:
-        ops += [c.lookup_op(comp), c.getfh_op()]
+        ops += [op.lookup(comp), op.getfh()]
     res = c.compound(ops)
     check(res, NFS4ERR_MOVED, "GETFH of path indicated by --usespecial")
     locs = c.do_getattr(FATTR4_FS_LOCATIONS, path)
@@ -71,7 +73,7 @@ def testAttr1b(t, env):
     path = env.opts.usespecial[:-1]
     attrlist = [FATTR4_SIZE, FATTR4_FILEHANDLE, FATTR4_FSID]
     ops = c.use_obj(path)
-    ops += [c.readdir_op(0, '', 4096, 4096, list2bitmap(attrlist))]
+    ops += [op.readdir(0, '', 4096, 4096, list2bitmap(attrlist))]
     res = c.compound(ops)
     check(res, NFS4ERR_MOVED, "READDIR w/o FSLOC or RDATTR_ERROR")
 
diff --git a/nfs4.0/servertests/st_getattr.py b/nfs4.0/servertests/st_getattr.py
index 9dede73..3627f9e 100644
--- a/nfs4.0/servertests/st_getattr.py
+++ b/nfs4.0/servertests/st_getattr.py
@@ -1,6 +1,8 @@
-from nfs4_const import *
+from xdrdef.nfs4_const import *
 from environment import check
 from nfs4lib import get_attr_name
+import nfs_ops
+op = nfs_ops.NFS4ops()
 
 def _try_mandatory(t, env, path):
     c = env.c1
@@ -531,8 +533,8 @@ def testOwnerName(t, env):
         """
 
         request = [FATTR4_MOUNTED_ON_FILEID, FATTR4_FILEID, FATTR4_FSID]
-        lookupops = [self.ncl.lookup_op("unix")]
-        ops = [self.ncl.putrootfh_op()]
+        lookupops = [op.lookup("unix")]
+        ops = [op.putrootfh()]
         ops.append(self.ncl.getattr(request))
 	ops += lookupops
         ops.append(self.ncl.getattr(request))
@@ -543,7 +545,7 @@ def testOwnerName(t, env):
         print
         print "From Getattr /unix - ", res.resarray[-1].obj_attributes
 
-        ops = [self.ncl.putrootfh_op()]
+        ops = [op.putrootfh()]
         attrmask = nfs4lib.list2bitmap(request)
         ops.append(self.ncl.readdir(attr_request=attrmask))
         res = self.ncl.do_ops(ops)
diff --git a/nfs4.0/servertests/st_getfh.py b/nfs4.0/servertests/st_getfh.py
index 7f022ab..6fd22e7 100644
--- a/nfs4.0/servertests/st_getfh.py
+++ b/nfs4.0/servertests/st_getfh.py
@@ -1,5 +1,7 @@
-from nfs4_const import *
+from xdrdef.nfs4_const import *
 from environment import check
+import nfs_ops
+op = nfs_ops.NFS4ops()
 
 def testFile(t, env):
     """GETFH on testtree file
@@ -72,7 +74,7 @@ def testNoFh(t, env):
     CODE: GF9
     """
     c = env.c1
-    ops = [c.getfh_op()]
+    ops = [op.getfh()]
     res = c.compound(ops)
     check(res, NFS4ERR_NOFILEHANDLE, "GETFH with no <cfh>")
               
diff --git a/nfs4.0/servertests/st_gss.py b/nfs4.0/servertests/st_gss.py
index eed707b..c67a802 100644
--- a/nfs4.0/servertests/st_gss.py
+++ b/nfs4.0/servertests/st_gss.py
@@ -1,9 +1,11 @@
-from nfs4_const import *
+from xdrdef.nfs4_const import *
 from environment import check
 from socket import timeout
 import rpc
 import rpc.rpcsec.gss_const as gss
 from rpc.rpcsec.gss_type import rpc_gss_cred_t
+import nfs_ops
+op = nfs_ops.NFS4ops()
 
 class BadGssHeader(object):
     """Screw up gss cred.
@@ -66,14 +68,14 @@ def testBadGssSeqnum(t, env):
     CODE: GSS1
     """
     c = env.c1
-    res = c.compound([c.putrootfh_op()])
+    res = c.compound([op.putrootfh()])
     check(res)
     success = False
     orig = c.security.gss_seq_num
     try:
         c.security.gss_seq_num -= 1
         try:
-            res = c.compound([c.putrootfh_op()])
+            res = c.compound([op.putrootfh()])
         except timeout:
             success = True
         if not success:
@@ -105,7 +107,7 @@ def testInconsistentGssSeqnum(t, env):
     try:
         c.security.secure_data = bad_secure_data
         try:
-            res = c.compound([c.putrootfh_op()])
+            res = c.compound([op.putrootfh()])
             e = "operation erroneously suceeding"
         except rpc.RPCAcceptError, e:
             if e.stat == rpc.GARBAGE_ARGS:
@@ -134,7 +136,7 @@ def testBadVerfChecksum(t, env):
     try:
         c.security.make_verf = bad_make_verf
         try:
-            res = c.compound([c.putrootfh_op()])
+            res = c.compound([op.putrootfh()])
             e = "peration erroneously suceeding"
         except rpc.RPCDeniedError, e:
             if e.stat == rpc.AUTH_ERROR and e.astat == rpc.RPCSEC_GSS_CREDPROBLEM:
@@ -170,7 +172,7 @@ def testBadDataChecksum(t, env):
     try:
         c.security.secure_data = bad_secure_data
         try:
-            res = c.compound([c.putrootfh_op()])
+            res = c.compound([op.putrootfh()])
             e = "operation erroneously suceeding"
         except rpc.RPCAcceptError, e:
             if e.stat == rpc.GARBAGE_ARGS:
@@ -210,7 +212,7 @@ def testBadVersion(t, env):
         bad_versions = [0, 2, 3, 1024]
         for version in bad_versions:
             try:
-                res = c.compound([c.putrootfh_op()])
+                res = c.compound([op.putrootfh()])
                 e = "operation erroneously suceeding"
             except rpc.RPCDeniedError, e:
                 if e.stat == rpc.AUTH_ERROR and e.astat == rpc.AUTH_BADCRED:
@@ -237,7 +239,7 @@ def testHighSeqNum(t, env):
     try:
         c.security.gss_seq_num = gss.MAXSEQ + 1
         try:
-            res = c.compound([c.putrootfh_op()])
+            res = c.compound([op.putrootfh()])
             e = "operation erroneously suceeding"
         except rpc.RPCDeniedError, e:
             if e.stat == rpc.AUTH_ERROR and e.astat == rpc.RPCSEC_GSS_CTXPROBLEM:
@@ -275,7 +277,7 @@ def testBadProcedure(t, env):
         bad_procss = [4, 5, 1024]
         for proc in bad_procss:
             try:
-                res = c.compound([c.putrootfh_op()])
+                res = c.compound([op.putrootfh()])
                 e = "operation erroneously suceeding"
             except rpc.RPCDeniedError, e:
                 if e.stat == rpc.AUTH_ERROR and e.astat == rpc.AUTH_BADCRED:
@@ -317,7 +319,7 @@ def testBadService(t, env):
         bad_services = [0, 4, 5, 1024]
         for service in bad_services:
             try:
-                res = c.compound([c.putrootfh_op()])
+                res = c.compound([op.putrootfh()])
                 e = "operation erroneously suceeding"
             except rpc.RPCDeniedError, e:
                 if e.stat == rpc.AUTH_ERROR and e.astat == rpc.AUTH_BADCRED:
diff --git a/nfs4.0/servertests/st_link.py b/nfs4.0/servertests/st_link.py
index 0629ef1..49e0538 100644
--- a/nfs4.0/servertests/st_link.py
+++ b/nfs4.0/servertests/st_link.py
@@ -1,5 +1,7 @@
-from nfs4_const import *
+from xdrdef.nfs4_const import *
 from environment import check, get_invalid_utf8strings
+import nfs_ops
+op = nfs_ops.NFS4ops()
 
 def _basictest(t, c, path, error=NFS4_OK):
     """Link to path, and make sure FATTR4_NUMLINKS increases by one"""
@@ -99,7 +101,7 @@ def testNoSfh(t, env):
     """
     c = env.c1
     ops = c.go_home()
-    ops += [c.link_op(t.code)]
+    ops += [op.link(t.code)]
     res = c.compound(ops)
     check(res, NFS4ERR_NOFILEHANDLE, "LINK with no <sfh>")
 
@@ -111,7 +113,7 @@ def testNoCfh(t, env):
     CODE: LINK3
     """
     c = env.c1
-    ops = [c.link_op(t.code)]
+    ops = [op.link(t.code)]
     res = c.compound(ops)
     check(res, NFS4ERR_NOFILEHANDLE, "LINK with no <cfh>")
 
diff --git a/nfs4.0/servertests/st_lock.py b/nfs4.0/servertests/st_lock.py
index deba4c3..69cdc74 100644
--- a/nfs4.0/servertests/st_lock.py
+++ b/nfs4.0/servertests/st_lock.py
@@ -1,7 +1,9 @@
-from nfs4_const import *
-from nfs4_type import stateid4
+from xdrdef.nfs4_const import *
+from xdrdef.nfs4_type import stateid4
 from environment import check, get_invalid_clientid, makeStaleId, makeBadIDganesha
 import time
+import nfs_ops
+op = nfs_ops.NFS4ops()
 
 def testFile(t, env):
     """LOCK and LOCKT a regular file
@@ -659,7 +661,7 @@ def testBlockTimeout(t, env):
     # Wait for queued lock to timeout
     for i in range(3):
         env.sleep(sleeptime, "Waiting for queued blocking lock to timeout")
-        res = c.compound([c.renew_op(c.clientid)])
+        res = c.compound([op.renew(c.clientid)])
         check(res, [NFS4_OK, NFS4ERR_CB_PATH_DOWN])
     # Standard owner releases lock
     res1 = c.unlock_file(1, fh1, res1.lockid)
diff --git a/nfs4.0/servertests/st_lockt.py b/nfs4.0/servertests/st_lockt.py
index 94b685b..7f8c5e1 100644
--- a/nfs4.0/servertests/st_lockt.py
+++ b/nfs4.0/servertests/st_lockt.py
@@ -1,4 +1,4 @@
-from nfs4_const import *
+from xdrdef.nfs4_const import *
 from environment import check, get_invalid_clientid
 
 def testUnlockedFile(t, env):
diff --git a/nfs4.0/servertests/st_locku.py b/nfs4.0/servertests/st_locku.py
index b07f7e2..3006445 100644
--- a/nfs4.0/servertests/st_locku.py
+++ b/nfs4.0/servertests/st_locku.py
@@ -1,5 +1,5 @@
-from nfs4_const import *
-from nfs4_type import stateid4
+from xdrdef.nfs4_const import *
+from xdrdef.nfs4_type import stateid4
 from environment import check, makeStaleId
 
 def testFile(t, env):
diff --git a/nfs4.0/servertests/st_lookup.py b/nfs4.0/servertests/st_lookup.py
index d4636d0..c3203f9 100644
--- a/nfs4.0/servertests/st_lookup.py
+++ b/nfs4.0/servertests/st_lookup.py
@@ -1,6 +1,8 @@
-from nfs4_const import *
+from xdrdef.nfs4_const import *
 from environment import check, get_invalid_utf8strings
 import rpc
+import nfs_ops
+op = nfs_ops.NFS4ops()
 
 def testDir(t, env):
     """LOOKUP testtree dir
@@ -86,7 +88,7 @@ def testNoFh(t, env):
     CODE: LOOK1
     """
     c = env.c1
-    ops = [c.lookup_op('foo')]
+    ops = [op.lookup('foo')]
     res = c.compound(ops)
     check(res, NFS4ERR_NOFILEHANDLE, "LOOKUP with no <cfh>")
 
@@ -98,7 +100,7 @@ def testNonExistent(t, env):
     """
     c = env.c1
     ops = c.go_home()
-    ops += [c.lookup_op(t.code)]
+    ops += [op.lookup(t.code)]
     res = c.compound(ops)
     check(res, NFS4ERR_NOENT,
           "LOOKUP with no non-existant component '%s'" % t.code)
@@ -110,7 +112,7 @@ def testZeroLength(t, env):
     CODE: LOOK3
     """
     c = env.c1
-    ops = [c.putrootfh_op(), c.lookup_op('')]
+    ops = [op.putrootfh(), op.lookup('')]
     res = c.compound(ops)
     check(res, NFS4ERR_INVAL, "LOOKUP with no zero-length component")
 
@@ -121,7 +123,7 @@ def testLongName(t, env):
     CODE: LOOK4
     """
     c = env.c1
-    ops = [c.putrootfh_op(), c.lookup_op(env.longname)]
+    ops = [op.putrootfh(), op.lookup(env.longname)]
     res = c.compound(ops)
     check(res, NFS4ERR_NAMETOOLONG, "LOOKUP with very long component")
 
@@ -307,7 +309,7 @@ def testBadOpaque(t, env):
         p = c.nfs4packer
         orig = p.pack_opaque
         p.pack_opaque = bad_opaque
-        res = c.compound([c.putrootfh_op(), c.lookup_op("setlength=0xcccccccc")])
+        res = c.compound([op.putrootfh(), op.lookup("setlength=0xcccccccc")])
         e = "operation erroneously suceeding"
         check(res, NFS4ERR_BADXDR)
     except rpc.RPCAcceptError, e:
@@ -340,8 +342,8 @@ def testBadOpaque(t, env):
         # Ok, lets try LOOKUP on all accepted names
         lookup_dir_ops = self.ncl.lookup_path(self.tmp_dir)
         for filename in accepted_names:
-            ops = [self.ncl.putrootfh_op()] + lookup_dir_ops
-            ops.append(self.ncl.lookup_op(filename))
+            ops = [op.putrootfh()] + lookup_dir_ops
+            ops.append(op.lookup(filename))
             res = self.ncl.do_ops(ops)
             self.assert_OK(res)
             
@@ -367,7 +369,7 @@ def testBadOpaque(t, env):
         # Ok, lets try LOOKUP on all rejected names
         lookup_dir_ops = self.ncl.lookup_path(self.tmp_dir)
         for filename in rejected_names:
-            ops = [self.ncl.putrootfh_op()] + lookup_dir_ops
-            ops.append(self.ncl.lookup_op(filename))
+            ops = [op.putrootfh()] + lookup_dir_ops
+            ops.append(op.lookup(filename))
             res = self.ncl.do_ops(ops)
             self.assert_status(res, [NFS4ERR_INVAL,NFS4ERR_NOENT])
diff --git a/nfs4.0/servertests/st_lookupp.py b/nfs4.0/servertests/st_lookupp.py
index 9802ea4..13c1553 100644
--- a/nfs4.0/servertests/st_lookupp.py
+++ b/nfs4.0/servertests/st_lookupp.py
@@ -1,5 +1,7 @@
-from nfs4_const import *
+from xdrdef.nfs4_const import *
 from environment import check, get_invalid_utf8strings
+import nfs_ops
+op = nfs_ops.NFS4ops()
 
 def testDir(t, env):
     """LOOKUPP with directory (cfh)
@@ -12,7 +14,7 @@ def testDir(t, env):
     res = c.create_obj(c.homedir + [t.code])
     check(res)
     ops = c.use_obj(c.homedir)
-    ops += [c.getfh_op(), c.lookup_op(t.code), c.lookupp_op(), c.getfh_op()]
+    ops += [op.getfh(), op.lookup(t.code), op.lookupp(), op.getfh()]
     res = c.compound(ops)
     check(res)
     fh1 = res.resarray[-4].switch.switch.object
@@ -28,7 +30,7 @@ def testFile(t, env):
     CODE: LOOKP2r
     """
     c = env.c1
-    ops = c.use_obj(env.opts.usefile) + [c.lookupp_op()]
+    ops = c.use_obj(env.opts.usefile) + [op.lookupp()]
     res = c.compound(ops)
     check(res, NFS4ERR_NOTDIR, "LOOKUPP with non-dir <cfh>")
     
@@ -40,7 +42,7 @@ def testFifo(t, env):
     CODE: LOOKP2f
     """
     c = env.c1
-    ops = c.use_obj(env.opts.usefifo) + [c.lookupp_op()]
+    ops = c.use_obj(env.opts.usefifo) + [op.lookupp()]
     res = c.compound(ops)
     check(res, NFS4ERR_NOTDIR, "LOOKUPP with non-dir <cfh>")
     
@@ -52,7 +54,7 @@ def testLink(t, env):
     CODE: LOOKP2a
     """
     c = env.c1
-    ops = c.use_obj(env.opts.uselink) + [c.lookupp_op()]
+    ops = c.use_obj(env.opts.uselink) + [op.lookupp()]
     res = c.compound(ops)
     check(res, [NFS4ERR_NOTDIR, NFS4ERR_SYMLINK],
                 "LOOKUPP with non-dir <cfh>")
@@ -65,7 +67,7 @@ def testBlock(t, env):
     CODE: LOOKP2b
     """
     c = env.c1
-    ops = c.use_obj(env.opts.useblock) + [c.lookupp_op()]
+    ops = c.use_obj(env.opts.useblock) + [op.lookupp()]
     res = c.compound(ops)
     check(res, NFS4ERR_NOTDIR, "LOOKUPP with non-dir <cfh>")
     
@@ -77,7 +79,7 @@ def testChar(t, env):
     CODE: LOOKP2c
     """
     c = env.c1
-    ops = c.use_obj(env.opts.usechar) + [c.lookupp_op()]
+    ops = c.use_obj(env.opts.usechar) + [op.lookupp()]
     res = c.compound(ops)
     check(res, NFS4ERR_NOTDIR, "LOOKUPP with non-dir <cfh>")
     
@@ -89,7 +91,7 @@ def testSock(t, env):
     CODE: LOOKP2s
     """
     c = env.c1
-    ops = c.use_obj(env.opts.usesocket) + [c.lookupp_op()]
+    ops = c.use_obj(env.opts.usesocket) + [op.lookupp()]
     res = c.compound(ops)
     check(res, NFS4ERR_NOTDIR, "LOOKUPP with non-dir <cfh>")
 
@@ -100,7 +102,7 @@ def testAtRoot(t, env):
     CODE: LOOKP3
     """
     c = env.c1
-    res = c.compound([c.putrootfh_op(), c.lookupp_op()])
+    res = c.compound([op.putrootfh(), op.lookupp()])
     check(res, NFS4ERR_NOENT, "LOOKUPP at root")
 
 def testNoFh(t, env):
@@ -110,7 +112,7 @@ def testNoFh(t, env):
     CODE: LOOKP4
     """
     c = env.c1
-    res = c.compound([c.lookupp_op()])
+    res = c.compound([op.lookupp()])
     check(res, NFS4ERR_NOFILEHANDLE, "LOOKUPP at root")
 
 def testXdev(t, env):
@@ -121,8 +123,8 @@ def testXdev(t, env):
     CODE: LOOKP5
     """
     c = env.c1
-    ops = [c.putrootfh_op(), c.getfh_op(),
-           c.lookup_op(env.opts.usespecial[-1]), c.lookupp_op(), c.getfh_op()]
+    ops = [op.putrootfh(), op.getfh(),
+           op.lookup(env.opts.usespecial[-1]), op.lookupp(), op.getfh()]
     res = c.compound(ops)
     check(res)
     fh1 = res.resarray[1].switch.switch.object
@@ -138,10 +140,10 @@ def testXdevHome(t, env):
     CODE: LOOKP6
     """
     c = env.c1
-    ops = [c.putrootfh_op(), c.getfh_op()]
+    ops = [op.putrootfh(), op.getfh()]
     ops += c.lookup_path(c.homedir)
     ops += c.lookupp_path(c.homedir)
-    ops += [c.getfh_op()]
+    ops += [op.getfh()]
     res = c.compound(ops)
     check(res)
     fh1 = res.resarray[1].switch.switch.object
diff --git a/nfs4.0/servertests/st_nverify.py b/nfs4.0/servertests/st_nverify.py
index b0a8a4b..4185970 100644
--- a/nfs4.0/servertests/st_nverify.py
+++ b/nfs4.0/servertests/st_nverify.py
@@ -1,18 +1,20 @@
-from nfs4_const import *
+from xdrdef.nfs4_const import *
 from environment import check, get_invalid_clientid, makeStaleId
+import nfs_ops
+op = nfs_ops.NFS4ops()
 
 def _try_mand(env, path):
     c = env.c1
     mand_bits = [attr.bitnum for attr in env.attr_info \
                  if attr.mandatory and attr.name != 'rdattr_error']
     dict = c.do_getattrdict(path, mand_bits)
-    ops = c.use_obj(path) + [c.nverify_op(dict)] + c.use_obj(path)
+    ops = c.use_obj(path) + [op.nverify(dict)] + c.use_obj(path)
     res = c.compound(ops)
     check(res, NFS4ERR_SAME, "NVerifying mandatory attributes against getattr")
 
 def _try_type(env, path, type):
     c = env.c1
-    ops = c.use_obj(path) + [c.nverify_op({FATTR4_TYPE:type})] + c.use_obj(path)
+    ops = c.use_obj(path) + [op.nverify({FATTR4_TYPE:type})] + c.use_obj(path)
     res = c.compound(ops)
     check(res, NFS4ERR_SAME, "NVerifying type of /%s" % '/'.join(path))
 
@@ -20,7 +22,7 @@ def _try_changed_size(env, path):
     c = env.c1
     dict = c.do_getattrdict(path, [FATTR4_SIZE])
     dict[FATTR4_SIZE] += 1
-    ops = c.use_obj(path) + [c.nverify_op(dict)] + c.use_obj(path)
+    ops = c.use_obj(path) + [op.nverify(dict)] + c.use_obj(path)
     res = c.compound(ops)
     check(res, msg="NVerifying incorrect size")
 
@@ -30,7 +32,7 @@ def _try_write_only(env, path):
     wo = [attr for attr in env.attr_info \
           if attr.writeonly or attr.name=='rdattr_error']
     for attr in wo:
-        ops = baseops + [c.nverify_op({attr.bitnum: attr.sample})]
+        ops = baseops + [op.nverify({attr.bitnum: attr.sample})]
         res = c.compound(ops)
         check(res, NFS4ERR_INVAL, "NVERIFY with attr %s" % attr.name)
 
@@ -40,7 +42,7 @@ def _try_unsupported(env, path):
     supp_mask = c.supportedAttrs(path)
     unsupp = [attr for attr in env.attr_info if not (attr.mask & supp_mask)]
     for attr in unsupp:
-        ops = baseops + [c.nverify_op({attr.bitnum: attr.sample})]
+        ops = baseops + [op.nverify({attr.bitnum: attr.sample})]
         res = c.compound(ops)
         if attr.writeonly:
             check(res, [NFS4ERR_ATTRNOTSUPP, NFS4ERR_INVAL],
@@ -247,7 +249,7 @@ def testNoFh(t, env):
     CODE: NVF4
     """
     c = env.c1
-    res = c.compound([c.nverify_op({FATTR4_SIZE:17})])
+    res = c.compound([op.nverify({FATTR4_SIZE:17})])
     check(res, NFS4ERR_NOFILEHANDLE, "NVERIFY with no <cfh>")
                      
 def testWriteOnlyFile(t, env):
diff --git a/nfs4.0/servertests/st_open.py b/nfs4.0/servertests/st_open.py
index 4938fc3..437fb67 100644
--- a/nfs4.0/servertests/st_open.py
+++ b/nfs4.0/servertests/st_open.py
@@ -1,4 +1,4 @@
-from nfs4_const import *
+from xdrdef.nfs4_const import *
 from environment import check, checkdict, get_invalid_utf8strings
 from nfs4lib import get_bitnumattr_dict
 
diff --git a/nfs4.0/servertests/st_openconfirm.py b/nfs4.0/servertests/st_openconfirm.py
index 589454d..3b5b98f 100644
--- a/nfs4.0/servertests/st_openconfirm.py
+++ b/nfs4.0/servertests/st_openconfirm.py
@@ -1,10 +1,12 @@
-from nfs4_const import *
-from nfs4_type import stateid4
+from xdrdef.nfs4_const import *
+from xdrdef.nfs4_type import stateid4
 from environment import check, makeStaleId
+import nfs_ops
+op = nfs_ops.NFS4ops()
 
 def _confirm(t, c, file, stateid):
     ops = c.use_obj(file)
-    ops += [c.open_confirm_op(stateid, c.get_seqid(t.code))]
+    ops += [op.open_confirm(stateid, c.get_seqid(t.code))]
     res = c.compound(ops)
     c.advance_seqid(t.code, res)
     return res
@@ -57,7 +59,7 @@ def testBadSeqid(t, env):
     check(res)
     stateid = res.resarray[-2].switch.switch.stateid
     fh = res.resarray[-1].switch.switch.object
-    ops = [c.putfh_op(fh), c.open_confirm_op(stateid, 50)]
+    ops = [op.putfh(fh), op.open_confirm(stateid, 50)]
     res = c.compound(ops)
     check(res, NFS4ERR_BAD_SEQID, "OPEN_CONFIRM with a bad seqid=50")
 
diff --git a/nfs4.0/servertests/st_opendowngrade.py b/nfs4.0/servertests/st_opendowngrade.py
index 1ee4a35..9cbf5cb 100644
--- a/nfs4.0/servertests/st_opendowngrade.py
+++ b/nfs4.0/servertests/st_opendowngrade.py
@@ -1,4 +1,4 @@
-from nfs4_const import *
+from xdrdef.nfs4_const import *
 from environment import check, makeStaleId
 
 def testRegularOpen(t, env):
diff --git a/nfs4.0/servertests/st_putfh.py b/nfs4.0/servertests/st_putfh.py
index 1db5809..ba9ce27 100644
--- a/nfs4.0/servertests/st_putfh.py
+++ b/nfs4.0/servertests/st_putfh.py
@@ -1,13 +1,15 @@
-from nfs4_const import *
+from xdrdef.nfs4_const import *
 from environment import check
+import nfs_ops
+op = nfs_ops.NFS4ops()
 
 def _try_put(t, c, path):
     # Get fh via LOOKUP
-    res = c.compound(c.use_obj(path) + [c.getfh_op()])
+    res = c.compound(c.use_obj(path) + [op.getfh()])
     check(res)
     oldfh = res.resarray[-1].switch.switch.object
     # Now try PUTFH and GETFH, see if it agrees
-    res = c.compound([c.putfh_op(oldfh), c.getfh_op()])
+    res = c.compound([op.putfh(oldfh), op.getfh()])
     check(res)
     newfh = res.resarray[-1].switch.switch.object
     if oldfh != newfh:
@@ -83,7 +85,7 @@ def testBadHandle(t, env):
     CODE: PUTFH2
     """
     c = env.c1
-    res = c.compound([c.putfh_op('abc')])
+    res = c.compound([op.putfh('abc')])
     check(res, NFS4ERR_BADHANDLE, "PUTFH with bad filehandle='abc'")
 
 def testStaleHandle(t, env):
@@ -99,11 +101,11 @@ def testStaleHandle(t, env):
     stale_fh, stateid = c.create_confirm(t.code)
     res = c.close_file(t.code, stale_fh, stateid)
     check(res)
-    ops = c.use_obj(c.homedir) + [c.remove_op(t.code)]
+    ops = c.use_obj(c.homedir) + [op.remove(t.code)]
     res = c.compound(ops)
     check(res)
     # Now try to use it; but note a server may still allow use and
     # that's not necessarily a protocol violation; disabling this test
     # by default until we think of something better.
-    res = c.compound([c.putfh_op(stale_fh)])
+    res = c.compound([op.putfh(stale_fh)])
     check(res, NFS4ERR_STALE, "Using a stale fh")
diff --git a/nfs4.0/servertests/st_putpubfh.py b/nfs4.0/servertests/st_putpubfh.py
index 2ca19ee..0149b9d 100644
--- a/nfs4.0/servertests/st_putpubfh.py
+++ b/nfs4.0/servertests/st_putpubfh.py
@@ -1,5 +1,7 @@
-from nfs4_const import *
+from xdrdef.nfs4_const import *
 from environment import check
+import nfs_ops
+op = nfs_ops.NFS4ops()
 
 def testSupported(t, env):
     """Do a simple PUTPUBFH
@@ -9,7 +11,7 @@ def testSupported(t, env):
     """
 
     c = env.c1
-    ops = [c.putpubfh_op()]
+    ops = [op.putpubfh()]
     res = c.compound(ops)
     check(res)
 
@@ -26,12 +28,12 @@ def testSameAsRoot(t, env):
     """
 
     c = env.c1
-    ops = [c.putpubfh_op(), c.getfh_op()]
+    ops = [op.putpubfh(), op.getfh()]
     res = c.compound(ops)
     check(res)
     pubfh = res.resarray[-1].switch.switch.object
 
-    ops = [c.putrootfh_op(), c.getfh_op()]
+    ops = [op.putrootfh(), op.getfh()]
     res = c.compound(ops)
     check(res)
     rootfh = res.resarray[-1].switch.switch.object
diff --git a/nfs4.0/servertests/st_putrootfh.py b/nfs4.0/servertests/st_putrootfh.py
index 4c9e9b8..dd47f58 100644
--- a/nfs4.0/servertests/st_putrootfh.py
+++ b/nfs4.0/servertests/st_putrootfh.py
@@ -1,5 +1,7 @@
-from nfs4_const import *
+from xdrdef.nfs4_const import *
 from environment import check
+import nfs_ops
+op = nfs_ops.NFS4ops()
 
 def testSupported(t, env):
     """Do a simple PUTROOTFH
@@ -8,6 +10,6 @@ def testSupported(t, env):
     CODE: ROOT1
     """
     c = env.c1
-    ops = [c.putrootfh_op()]
+    ops = [op.putrootfh()]
     res = c.compound(ops)
     check(res)
diff --git a/nfs4.0/servertests/st_read.py b/nfs4.0/servertests/st_read.py
index 4a23e74..9b2203b 100644
--- a/nfs4.0/servertests/st_read.py
+++ b/nfs4.0/servertests/st_read.py
@@ -1,4 +1,4 @@
-from nfs4_const import *
+from xdrdef.nfs4_const import *
 from environment import check, makeBadID, makeBadIDganesha, makeStaleId
 import rpc
 
diff --git a/nfs4.0/servertests/st_readdir.py b/nfs4.0/servertests/st_readdir.py
index 0a3b45a..a88c370 100644
--- a/nfs4.0/servertests/st_readdir.py
+++ b/nfs4.0/servertests/st_readdir.py
@@ -1,4 +1,4 @@
-from nfs4_const import *
+from xdrdef.nfs4_const import *
 from nfs4lib import get_attr_name
 from environment import check
 
diff --git a/nfs4.0/servertests/st_readlink.py b/nfs4.0/servertests/st_readlink.py
index 843247d..8b905d0 100644
--- a/nfs4.0/servertests/st_readlink.py
+++ b/nfs4.0/servertests/st_readlink.py
@@ -1,5 +1,7 @@
-from nfs4_const import *
+from xdrdef.nfs4_const import *
 from environment import check
+import nfs_ops
+op = nfs_ops.NFS4ops()
 
 def testReadlink(t, env):
     """READLINK on link
@@ -9,7 +11,7 @@ def testReadlink(t, env):
     CODE: RDLK1
     """
     c = env.c1
-    res = c.compound(c.use_obj(env.opts.uselink) + [c.readlink_op()])
+    res = c.compound(c.use_obj(env.opts.uselink) + [op.readlink()])
     check(res)
     data = res.resarray[-1].switch.switch.link
     if data != env.linkdata:
@@ -23,7 +25,7 @@ def testFile(t, env):
     CODE: RDLK2r
     """
     c = env.c1
-    res = c.compound(c.use_obj(env.opts.usefile) + [c.readlink_op()])
+    res = c.compound(c.use_obj(env.opts.usefile) + [op.readlink()])
     check(res, NFS4ERR_INVAL, "READLINK on non-symlink objects")
 
 def testBlock(t, env):
@@ -34,7 +36,7 @@ def testBlock(t, env):
     CODE: RDLK2b
     """
     c = env.c1
-    res = c.compound(c.use_obj(env.opts.useblock) + [c.readlink_op()])
+    res = c.compound(c.use_obj(env.opts.useblock) + [op.readlink()])
     check(res, NFS4ERR_INVAL, "READLINK on non-symlink objects")
 
 def testChar(t, env):
@@ -45,7 +47,7 @@ def testChar(t, env):
     CODE: RDLK2c
     """
     c = env.c1
-    res = c.compound(c.use_obj(env.opts.usechar) + [c.readlink_op()])
+    res = c.compound(c.use_obj(env.opts.usechar) + [op.readlink()])
     check(res, NFS4ERR_INVAL, "READLINK on non-symlink objects")
 
 def testDir(t, env):
@@ -56,7 +58,7 @@ def testDir(t, env):
     CODE: RDLK2d
     """
     c = env.c1
-    res = c.compound(c.use_obj(env.opts.usedir) + [c.readlink_op()])
+    res = c.compound(c.use_obj(env.opts.usedir) + [op.readlink()])
     check(res, NFS4ERR_INVAL, "READLINK on non-symlink objects")
 
 def testFifo(t, env):
@@ -67,7 +69,7 @@ def testFifo(t, env):
     CODE: RDLK2f
     """
     c = env.c1
-    res = c.compound(c.use_obj(env.opts.usefifo) + [c.readlink_op()])
+    res = c.compound(c.use_obj(env.opts.usefifo) + [op.readlink()])
     check(res, NFS4ERR_INVAL, "READLINK on non-symlink objects")
 
 def testSocket(t, env):
@@ -78,7 +80,7 @@ def testSocket(t, env):
     CODE: RDLK2s
     """
     c = env.c1
-    res = c.compound(c.use_obj(env.opts.usesocket) + [c.readlink_op()])
+    res = c.compound(c.use_obj(env.opts.usesocket) + [op.readlink()])
     check(res, NFS4ERR_INVAL, "READLINK on non-symlink objects")
 
 def testNoFh(t, env):
@@ -88,7 +90,7 @@ def testNoFh(t, env):
     CODE: RDLK3
     """
     c = env.c1
-    res = c.compound([c.readlink_op()])
+    res = c.compound([op.readlink()])
     check(res, NFS4ERR_NOFILEHANDLE, "READLINK with no <cfh>")
 #####################################
 
diff --git a/nfs4.0/servertests/st_reboot.py b/nfs4.0/servertests/st_reboot.py
index 02e458c..ecfc61f 100644
--- a/nfs4.0/servertests/st_reboot.py
+++ b/nfs4.0/servertests/st_reboot.py
@@ -1,6 +1,8 @@
-from nfs4_const import *
+from xdrdef.nfs4_const import *
 from environment import check
 import os
+import nfs_ops
+op = nfs_ops.NFS4ops()
 
 # NOTE - reboot tests are NOT part of the standard test suite
 
@@ -139,7 +141,7 @@ def testEdge1(t, env):
     sleeptime = _waitForReboot(c2, env)
     try:
         # Client 1: Reclaim lock (should not work, since #2 has interfered)
-        res1 = c1.compound([c1.renew_op(c1.clientid)])
+        res1 = c1.compound([op.renew(c1.clientid)])
         check(res1, NFS4ERR_STALE_CLIENTID, "RENEW after reboot")
         c1.init_connection()
         res1 = c1.open_file(t.code, fh1, claim_type=CLAIM_PREVIOUS,
@@ -185,7 +187,7 @@ def testEdge2(t, env):
     sleeptime = _waitForReboot(c2, env)
     try:
         # Client 1: Reclaim lock (should not work, since #2 has interfered)
-        res1 = c1.compound([c1.renew_op(c1.clientid)])
+        res1 = c1.compound([op.renew(c1.clientid)])
         check(res1, NFS4ERR_STALE_CLIENTID, "RENEW after reboot")
         c1.init_connection()
         res1 = c1.open_file(t.code, fh1, claim_type=CLAIM_PREVIOUS,
@@ -251,7 +253,7 @@ def testValidDeleg(t, env):
         res = c.open_file(t.code, fh, claim_type=CLAIM_PREVIOUS,
                           deleg_type=OPEN_DELEGATE_NONE)
         check(res, NFS4ERR_STALE_CLIENTID, "Reclaim using old clientid")
-#        res = c.compound([c.renew_op(c.clientid)])
+#        res = c.compound([op.renew(c.clientid)])
 #        check(res, NFS4ERR_STALE_CLIENTID, "RENEW after reboot")
         c.init_connection(id, cb_ident=0)
         res = c.open_file(t.code, fh, claim_type=CLAIM_PREVIOUS,
diff --git a/nfs4.0/servertests/st_releaselockowner.py b/nfs4.0/servertests/st_releaselockowner.py
index a0b8949..17dfe1a 100644
--- a/nfs4.0/servertests/st_releaselockowner.py
+++ b/nfs4.0/servertests/st_releaselockowner.py
@@ -1,6 +1,8 @@
-from nfs4_const import *
-from nfs4_type import lock_owner4
+from xdrdef.nfs4_const import *
+from xdrdef.nfs4_type import lock_owner4
 from environment import check
+import nfs_ops
+op = nfs_ops.NFS4ops()
 
 def testFile(t, env):
     """RELEASE_LOCKOWNER - basic test
@@ -20,5 +22,5 @@ def testFile(t, env):
 
     # Release lockowner
     owner = lock_owner4(c.clientid, "lockowner_RLOWN1")
-    res = c.compound([c.release_lockowner_op(owner)])
+    res = c.compound([op.release_lockowner(owner)])
     check(res)
diff --git a/nfs4.0/servertests/st_remove.py b/nfs4.0/servertests/st_remove.py
index e5ee136..076ca41 100644
--- a/nfs4.0/servertests/st_remove.py
+++ b/nfs4.0/servertests/st_remove.py
@@ -1,5 +1,7 @@
-from nfs4_const import *
+from xdrdef.nfs4_const import *
 from environment import check, get_invalid_utf8strings
+import nfs_ops
+op = nfs_ops.NFS4ops()
 
 def testDir(t, env):
     """REMOVE on existing, removable object
@@ -11,7 +13,7 @@ def testDir(t, env):
     c = env.c1
     res = c.create_obj(t.code)
     check(res)
-    ops = c.use_obj(c.homedir) + [c.remove_op(t.code)]
+    ops = c.use_obj(c.homedir) + [op.remove(t.code)]
     res = c.compound(ops)
     check(res, msg="Removing dir %s" % t.code)
 
@@ -25,7 +27,7 @@ def testLink(t, env):
     c = env.c1
     res = c.create_obj(t.code, NF4LNK)
     check(res)
-    ops = c.use_obj(c.homedir) + [c.remove_op(t.code)]
+    ops = c.use_obj(c.homedir) + [op.remove(t.code)]
     res = c.compound(ops)
     check(res, msg="Removing symlink %s" % t.code)
 
@@ -39,7 +41,7 @@ def testBlock(t, env):
     c = env.c1
     res = c.create_obj(t.code, NF4BLK)
     check(res)
-    ops = c.use_obj(c.homedir) + [c.remove_op(t.code)]
+    ops = c.use_obj(c.homedir) + [op.remove(t.code)]
     res = c.compound(ops)
     check(res, msg="Removing block device %s" % t.code)
 
@@ -53,7 +55,7 @@ def testChar(t, env):
     c = env.c1
     res = c.create_obj(t.code, NF4CHR)
     check(res)
-    ops = c.use_obj(c.homedir) + [c.remove_op(t.code)]
+    ops = c.use_obj(c.homedir) + [op.remove(t.code)]
     res = c.compound(ops)
     check(res, msg="Removing character device %s" % t.code)
 
@@ -67,7 +69,7 @@ def testFifo(t, env):
     c = env.c1
     res = c.create_obj(t.code, NF4FIFO)
     check(res)
-    ops = c.use_obj(c.homedir) + [c.remove_op(t.code)]
+    ops = c.use_obj(c.homedir) + [op.remove(t.code)]
     res = c.compound(ops)
     check(res, msg="Removing fifo %s" % t.code)
 
@@ -81,7 +83,7 @@ def testSocket(t, env):
     c = env.c1
     res = c.create_obj(t.code, NF4SOCK)
     check(res)
-    ops = c.use_obj(c.homedir) + [c.remove_op(t.code)]
+    ops = c.use_obj(c.homedir) + [op.remove(t.code)]
     res = c.compound(ops)
     check(res, msg="Removing socket %s" % t.code)
 
@@ -95,7 +97,7 @@ def testFile(t, env):
     c = env.c1
     c.init_connection()
     fh, stateid = c.create_confirm(t.code)
-    ops = c.use_obj(c.homedir) + [c.remove_op(t.code)]
+    ops = c.use_obj(c.homedir) + [op.remove(t.code)]
     res = c.compound(ops)
     check(res, msg="Removing file %s" % t.code)
     
@@ -107,7 +109,7 @@ def testCfhFile(t, env):
     CODE: RM2r
     """
     c = env.c1
-    ops = c.use_obj(env.opts.usefile) + [c.remove_op(t.code)]
+    ops = c.use_obj(env.opts.usefile) + [op.remove(t.code)]
     res = c.compound(ops)
     check(res, NFS4ERR_NOTDIR, "REMOVE with non-dir cfh")
 
@@ -119,7 +121,7 @@ def testCfhLink(t, env):
     CODE: RM2a
     """
     c = env.c1
-    ops = c.use_obj(env.opts.uselink) + [c.remove_op(t.code)]
+    ops = c.use_obj(env.opts.uselink) + [op.remove(t.code)]
     res = c.compound(ops)
     check(res, [NFS4ERR_NOTDIR, NFS4ERR_SYMLINK], "REMOVE with non-dir cfh")
 
@@ -131,7 +133,7 @@ def testCfhBlock(t, env):
     CODE: RM2b
     """
     c = env.c1
-    ops = c.use_obj(env.opts.useblock) + [c.remove_op(t.code)]
+    ops = c.use_obj(env.opts.useblock) + [op.remove(t.code)]
     res = c.compound(ops)
     check(res, NFS4ERR_NOTDIR, "REMOVE with non-dir cfh")
 
@@ -143,7 +145,7 @@ def testCfhChar(t, env):
     CODE: RM2c
     """
     c = env.c1
-    ops = c.use_obj(env.opts.usechar) + [c.remove_op(t.code)]
+    ops = c.use_obj(env.opts.usechar) + [op.remove(t.code)]
     res = c.compound(ops)
     check(res, NFS4ERR_NOTDIR, "REMOVE with non-dir cfh")
 
@@ -155,7 +157,7 @@ def testCfhFifo(t, env):
     CODE: RM2f
     """
     c = env.c1
-    ops = c.use_obj(env.opts.usefifo) + [c.remove_op(t.code)]
+    ops = c.use_obj(env.opts.usefifo) + [op.remove(t.code)]
     res = c.compound(ops)
     check(res, NFS4ERR_NOTDIR, "REMOVE with non-dir cfh")
 
@@ -167,7 +169,7 @@ def testCfhSocket(t, env):
     CODE: RM2s
     """
     c = env.c1
-    ops = c.use_obj(env.opts.usesocket) + [c.remove_op(t.code)]
+    ops = c.use_obj(env.opts.usesocket) + [op.remove(t.code)]
     res = c.compound(ops)
     check(res, NFS4ERR_NOTDIR, "REMOVE with non-dir cfh")
 
@@ -178,7 +180,7 @@ def testNoFh(t, env):
     CODE: RM3
     """
     c = env.c1
-    res = c.compound([c.remove_op(t.code)])
+    res = c.compound([op.remove(t.code)])
     check(res, NFS4ERR_NOFILEHANDLE, "REMOVE with no <cfh>")
 
 def testZeroLengthTarget(t, env):
@@ -188,7 +190,7 @@ def testZeroLengthTarget(t, env):
     CODE: RM4
     """
     c = env.c1
-    ops = c.use_obj(c.homedir) + [c.remove_op('')]
+    ops = c.use_obj(c.homedir) + [op.remove('')]
     res = c.compound(ops)
     check(res, NFS4ERR_INVAL, "REMOVE with zero length target")
 
@@ -204,7 +206,7 @@ def testNonUTF8(t, env):
     res = c.create_obj(basedir)
     check(res)
     for name in get_invalid_utf8strings():
-        ops = c.use_obj(basedir) + [c.remove_op(name)]
+        ops = c.use_obj(basedir) + [op.remove(name)]
         res = c.compound(ops)
         check(res, NFS4ERR_INVAL, "Trying to remove file with invalid utf8 "
                                   "name %s/%s" % (t.code, repr(name)[1:-1]))
@@ -216,7 +218,7 @@ def testNonExistent(t, env):
     CODE: RM6
     """
     c = env.c1
-    ops = c.use_obj(c.homedir) + [c.remove_op(t.code)]
+    ops = c.use_obj(c.homedir) + [op.remove(t.code)]
     res = c.compound(ops)
     check(res, NFS4ERR_NOENT, "REMOVE non-existing object %s" % t.code)
 
@@ -231,10 +233,10 @@ def testDots(t, env):
     basedir = c.homedir + [t.code]
     res = c.create_obj(basedir)
     check(res)
-    ops =  c.use_obj(basedir) + [c.remove_op('.')]
+    ops =  c.use_obj(basedir) + [op.remove('.')]
     res = c.compound(ops)
     check(res, NFS4ERR_BADNAME, "REMOVE nonexistant '.'", [NFS4ERR_NOENT])
-    ops =  c.use_obj(basedir) + [c.remove_op('..')]
+    ops =  c.use_obj(basedir) + [op.remove('..')]
     res = c.compound(ops)
     check(res, NFS4ERR_BADNAME, "REMOVE nonexistant '..'", [NFS4ERR_NOENT])
     
@@ -253,7 +255,7 @@ def testNotEmpty(t, env):
     res = c.create_obj(basedir + [t.code])
     check(res)
     # Now try to remove it
-    ops =  c.use_obj(c.homedir) + [c.remove_op(t.code)]
+    ops =  c.use_obj(c.homedir) + [op.remove(t.code)]
     res = c.compound(ops)
     check(res, NFS4ERR_NOTEMPTY, "REMOVE called on nonempty directory")
 
@@ -278,8 +280,8 @@ def testNotEmpty(t, env):
         # Ok, lets try REMOVE on all accepted names
         lookup_dir_ops = self.ncl.lookup_path(self.tmp_dir)
         for filename in accepted_names:
-            ops = [self.ncl.putrootfh_op()] + lookup_dir_ops
-            ops.append(self.ncl.remove_op(filename))
+            ops = [op.putrootfh()] + lookup_dir_ops
+            ops.append(op.remove(filename))
             res = self.ncl.do_ops(ops)
             self.assert_OK(res)
 
@@ -303,8 +305,8 @@ def testNotEmpty(t, env):
         # Ok, lets try REMOVE on all rejected names
         lookup_dir_ops = self.ncl.lookup_path(self.tmp_dir)
         for filename in rejected_names:
-            ops = [self.ncl.putrootfh_op()] + lookup_dir_ops
-            ops.append(self.ncl.remove_op(filename))
+            ops = [op.putrootfh()] + lookup_dir_ops
+            ops.append(op.remove(filename))
             res = self.ncl.do_ops(ops)
             self.assert_status(res, [NFS4ERR_NOENT,NFS4ERR_INVAL])
 
diff --git a/nfs4.0/servertests/st_rename.py b/nfs4.0/servertests/st_rename.py
index ca22554..5698a8c 100644
--- a/nfs4.0/servertests/st_rename.py
+++ b/nfs4.0/servertests/st_rename.py
@@ -1,5 +1,7 @@
-from nfs4_const import *
+from xdrdef.nfs4_const import *
 from environment import check, get_invalid_utf8strings
+import nfs_ops
+op = nfs_ops.NFS4ops()
 
 def testValidDir(t, env):
     """RENAME : normal operation
diff --git a/nfs4.0/servertests/st_renew.py b/nfs4.0/servertests/st_renew.py
index 4582c01..3a9f774 100644
--- a/nfs4.0/servertests/st_renew.py
+++ b/nfs4.0/servertests/st_renew.py
@@ -1,5 +1,7 @@
-from nfs4_const import *
+from xdrdef.nfs4_const import *
 from environment import check
+import nfs_ops
+op = nfs_ops.NFS4ops()
 
 def testRenew(t, env):
     """RENEW with valid clientid
@@ -9,7 +11,7 @@ def testRenew(t, env):
     """
     c = env.c1
     c.init_connection()
-    res = c.compound([c.renew_op(c.clientid)])
+    res = c.compound([op.renew(c.clientid)])
     check(res, msg="RENEW")
 
 def testBadRenew(t, env):
@@ -19,7 +21,7 @@ def testBadRenew(t, env):
     CODE: RENEW2
     """
     c = env.c1
-    res = c.compound([c.renew_op(0)])
+    res = c.compound([op.renew(0)])
     check(res, NFS4ERR_STALE_CLIENTID, "RENEW with bad clientid")
 
 def testExpired(t, env):
@@ -38,6 +40,6 @@ def testExpired(t, env):
     c2.init_connection()
     c2.open_confirm(t.code, access=OPEN4_SHARE_ACCESS_READ,
                     deny=OPEN4_SHARE_DENY_NONE)
-    res = c.compound([c.renew_op(c.clientid)])
+    res = c.compound([op.renew(c.clientid)])
     check(res, NFS4ERR_EXPIRED, "RENEW with expired lease")
 
diff --git a/nfs4.0/servertests/st_replay.py b/nfs4.0/servertests/st_replay.py
index 7a63910..81b8332 100644
--- a/nfs4.0/servertests/st_replay.py
+++ b/nfs4.0/servertests/st_replay.py
@@ -1,6 +1,8 @@
-from nfs4_const import *
+from xdrdef.nfs4_const import *
 from environment import check
-from nfs4_type import *
+from xdrdef.nfs4_type import *
+import nfs_ops
+op = nfs_ops.NFS4ops()
 
 def _replay(env, c, ops, error=NFS4_OK):
     # Can send in an error list, but replays must return same error as orig
@@ -43,7 +45,7 @@ def testOpen(t, env):
     c = env.c1
     c.init_connection()
     ops = c.use_obj(c.homedir)
-    ops += [c.open(t.code, type=OPEN4_CREATE), c.getfh_op()]
+    ops += [c.open(t.code, type=OPEN4_CREATE), op.getfh()]
     _replay(env, c, ops)
     # Note that seqid is now off on this and other replay tests
 
@@ -59,7 +61,7 @@ def testReplayState1(t, env):
     c.init_connection()
     c.maketree([t.code])
     ops = c.use_obj(c.homedir + [t.code])
-    ops += [c.open(t.code, 'vapor'), c.getfh_op()]
+    ops += [c.open(t.code, 'vapor'), op.getfh()]
     _replay(env, c, ops, NFS4ERR_NOENT)
     
 def testReplayState2(t, env):
@@ -73,7 +75,7 @@ def testReplayState2(t, env):
     c.init_connection()
     c.maketree([t.code])
     ops = c.use_obj(c.homedir)
-    ops += [c.open(t.code), c.getfh_op()]
+    ops += [c.open(t.code), op.getfh()]
     _replay(env, c, ops, NFS4ERR_ISDIR)
 
 def testReplayNonState(t, env):
@@ -105,7 +107,7 @@ def testLock(t, env):
     ops = c.use_obj(fh)
     lock_owner = exist_lock_owner4(res.lockid, 1)
     locker = locker4(FALSE, lock_owner=lock_owner)
-    ops += [c.lock_op(WRITE_LT, FALSE, 0, 10, locker)]
+    ops += [op.lock(WRITE_LT, FALSE, 0, 10, locker)]
     _replay(env, c, ops)
     
 def testLockDenied(t, env):
@@ -127,7 +129,7 @@ def testLockDenied(t, env):
     ops = c.use_obj(fh)
     lock_owner = exist_lock_owner4(res1.lockid, 1)
     locker = locker4(FALSE, lock_owner=lock_owner)
-    ops += [c.lock_op(WRITE_LT, FALSE, 0, 10, locker)]
+    ops += [op.lock(WRITE_LT, FALSE, 0, 10, locker)]
     _replay(env, c, ops, NFS4ERR_DENIED)
     
 def testUnlock(t, env):
@@ -143,7 +145,7 @@ def testUnlock(t, env):
     res = c.lock_file(t.code, fh, stateid, 20, 100)
     check(res, msg="Locking file %s" % t.code)
     ops = c.use_obj(fh)
-    ops += [c.locku_op(READ_LT, 1, res.lockid, 0, 0xffffffffffffffff)]
+    ops += [op.locku(READ_LT, 1, res.lockid, 0, 0xffffffffffffffff)]
     _replay(env, c, ops)
 
 def testUnlockWait(t, env):
@@ -161,7 +163,7 @@ def testUnlockWait(t, env):
     sleeptime = c.getLeaseTime() * 2
     env.sleep(sleeptime)
     ops = c.use_obj(fh)
-    ops += [c.locku_op(READ_LT, 1, res.lockid, 0, 0xffffffffffffffff)]
+    ops += [op.locku(READ_LT, 1, res.lockid, 0, 0xffffffffffffffff)]
     _replay(env, c, ops, [NFS4_OK, NFS4ERR_EXPIRED])
 
 def testClose(t, env):
@@ -175,7 +177,7 @@ def testClose(t, env):
     c.init_connection()
     fh, stateid = c.create_confirm(t.code)
     ops = c.use_obj(fh)
-    ops += [c.close_op(c.get_seqid(t.code), stateid)]
+    ops += [op.close(c.get_seqid(t.code), stateid)]
     _replay(env, c, ops)
     
 def testCloseWait(t, env):
@@ -191,7 +193,7 @@ def testCloseWait(t, env):
     sleeptime = c.getLeaseTime() * 2
     env.sleep(sleeptime)
     ops = c.use_obj(fh)
-    ops += [c.close_op(c.get_seqid(t.code), stateid)]
+    ops += [op.close(c.get_seqid(t.code), stateid)]
     _replay(env, c, ops, [NFS4_OK, NFS4ERR_EXPIRED])
     
 def testCloseFail(t, env):
@@ -205,7 +207,7 @@ def testCloseFail(t, env):
     c.init_connection()
     fh, stateid = c.create_confirm(t.code)
     ops = c.use_obj(fh)
-    ops += [c.close_op(c.get_seqid(t.code)+1, stateid)]
+    ops += [op.close(c.get_seqid(t.code)+1, stateid)]
     _replay(env, c, ops, NFS4ERR_BAD_SEQID)
     
 def testOpenConfirm(t, env):
@@ -225,7 +227,7 @@ def testOpenConfirm(t, env):
     if not rflags & OPEN4_RESULT_CONFIRM:
         t.pass_warn("OPEN did not require CONFIRM")
     ops = c.use_obj(fh)
-    ops += [c.open_confirm_op(stateid, c.get_seqid(t.code))]
+    ops += [op.open_confirm(stateid, c.get_seqid(t.code))]
     _replay(env, c, ops)
     
 def testOpenConfirmFail(t, env):
@@ -245,7 +247,7 @@ def testOpenConfirmFail(t, env):
     if not rflags & OPEN4_RESULT_CONFIRM:
         t.pass_warn("OPEN did not require CONFIRM")
     ops = c.use_obj(fh)
-    ops += [c.open_confirm_op(stateid, c.get_seqid(t.code)+1)]
+    ops += [op.open_confirm(stateid, c.get_seqid(t.code)+1)]
     _replay(env, c, ops, NFS4ERR_BAD_SEQID)
 
 def testMkdirReplay(t, env):
@@ -257,5 +259,5 @@ def testMkdirReplay(t, env):
     """
     c = env.c1
     c.init_connection()
-    ops = c.go_home() + [c.create_op(createtype4(NF4DIR), t.code, {})]
+    ops = c.go_home() + [op.create(createtype4(NF4DIR), t.code, {})]
     _replay(env, c, ops)
diff --git a/nfs4.0/servertests/st_restorefh.py b/nfs4.0/servertests/st_restorefh.py
index d8158e0..839079f 100644
--- a/nfs4.0/servertests/st_restorefh.py
+++ b/nfs4.0/servertests/st_restorefh.py
@@ -1,11 +1,13 @@
-from nfs4_const import *
+from xdrdef.nfs4_const import *
 from environment import check
+import nfs_ops
+op = nfs_ops.NFS4ops()
 
 def _try_sequence(t, c, path):
     """Try saving path, looking elsewhere, then restoring path"""
-    ops = c.use_obj(path) + [c.getfh_op(), c.savefh_op()]
-    ops += [c.putrootfh_op()]
-    ops += [c.restorefh_op(), c.getfh_op()]
+    ops = c.use_obj(path) + [op.getfh(), op.savefh()]
+    ops += [op.putrootfh()]
+    ops += [op.restorefh(), op.getfh()]
     res = c.compound(ops)
     check(res)
 
@@ -84,7 +86,7 @@ def testNoFh1(t, env):
     CODE: RSFH1
     """
     c = env.c1
-    res = c.compound([c.restorefh_op()])
+    res = c.compound([op.restorefh()])
     check(res, NFS4ERR_RESTOREFH, "RESTOREFH with no <cfh>")
 
 def testNoFh2(t, env):
@@ -94,5 +96,5 @@ def testNoFh2(t, env):
     CODE: RSFH2
     """
     c = env.c1
-    res = c.compound([c.putrootfh_op(), c.restorefh_op()])
+    res = c.compound([op.putrootfh(), op.restorefh()])
     check(res, NFS4ERR_RESTOREFH, "RESTOREFH with no <cfh>")
diff --git a/nfs4.0/servertests/st_savefh.py b/nfs4.0/servertests/st_savefh.py
index e193fe3..eef810c 100644
--- a/nfs4.0/servertests/st_savefh.py
+++ b/nfs4.0/servertests/st_savefh.py
@@ -1,5 +1,7 @@
-from nfs4_const import *
+from xdrdef.nfs4_const import *
 from environment import check
+import nfs_ops
+op = nfs_ops.NFS4ops()
 
 # NOTE other tests in restorefh.py
 def testNoFh(t, env):
@@ -9,6 +11,6 @@ def testNoFh(t, env):
     CODE: SVFH1
     """
     c = env.c1
-    res = c.compound([c.savefh_op()])
+    res = c.compound([op.savefh()])
     check(res, NFS4ERR_NOFILEHANDLE, "SAVEFH with no <cfh>")
 
diff --git a/nfs4.0/servertests/st_secinfo.py b/nfs4.0/servertests/st_secinfo.py
index d922903..eb874b1 100644
--- a/nfs4.0/servertests/st_secinfo.py
+++ b/nfs4.0/servertests/st_secinfo.py
@@ -1,5 +1,7 @@
-from nfs4_const import *
+from xdrdef.nfs4_const import *
 from environment import check, get_invalid_utf8strings
+import nfs_ops
+op = nfs_ops.NFS4ops()
 
 # XXX Do this for each object type
 def testValid(t, env):
@@ -13,7 +15,7 @@ def testValid(t, env):
     dir = env.opts.usefile[:-1]
     filename = env.opts.usefile[-1]
     ops = c.use_obj(dir)
-    ops += [c.secinfo_op(filename)]
+    ops += [op.secinfo(filename)]
     res = c.compound(ops)
     check(res)
     # Make sure at least one security mechanisms is returned.
@@ -29,7 +31,7 @@ def testNotDir(t, env):
     """
     c = env.c1
     ops = c.use_obj(env.opts.usefile)
-    ops += [c.secinfo_op('foo')]
+    ops += [op.secinfo('foo')]
     res = c.compound(ops)
     check(res, NFS4ERR_NOTDIR, "SECINFO with cfh a file")
 
@@ -45,7 +47,7 @@ def testVaporFile(t, env):
     res = c.create_obj(newdir)
     check(res)
     ops = c.use_obj(newdir)
-    ops += [c.secinfo_op('vapor')]
+    ops += [op.secinfo('vapor')]
     res = c.compound(ops)
     check(res, NFS4ERR_NOENT, "SECINFO on nonexistant file %s/vapor" % t.code)
 
@@ -57,7 +59,7 @@ def testNoFh(t, env):
     CODE: SEC4
     """
     c = env.c1
-    ops = [c.secinfo_op('vapor')]
+    ops = [op.secinfo('vapor')]
     res = c.compound(ops)
     check(res, NFS4ERR_NOFILEHANDLE, "SECINFO with no <cfh>")
 
@@ -73,7 +75,7 @@ def testZeroLenName(t, env):
     res = c.create_obj(newdir)
     check(res)
     ops = c.use_obj(newdir)
-    ops += [c.secinfo_op('')]
+    ops += [op.secinfo('')]
     res = c.compound(ops)
     check(res, NFS4ERR_INVAL, "SECINFO with zero-length name")
 
@@ -90,7 +92,7 @@ def testInvalidUtf8(t, env):
     check(res)
     baseops = c.use_obj(newdir)
     for name in get_invalid_utf8strings():
-        res = c.compound(baseops + [c.secinfo_op(name)])
+        res = c.compound(baseops + [op.secinfo(name)])
         check(res, NFS4ERR_INVAL, "SECINFO of non-existant file with invalid "
                                   "utf8 name %s" % repr(name))
         
@@ -108,7 +110,7 @@ def testRPCSEC_GSS(t, env):
     dir = env.opts.usefile[:-1]
     filename = env.opts.usefile[-1]
     ops = c.use_obj(dir)
-    ops += [c.secinfo_op(filename)]
+    ops += [op.secinfo(filename)]
     res = c.compound(ops)
     check(res)
     # Make sure at least one security mechanisms is RPCSEC_GSS
diff --git a/nfs4.0/servertests/st_setattr.py b/nfs4.0/servertests/st_setattr.py
index 18c11a4..4a80f65 100644
--- a/nfs4.0/servertests/st_setattr.py
+++ b/nfs4.0/servertests/st_setattr.py
@@ -1,7 +1,9 @@
-from nfs4_const import *
+from xdrdef.nfs4_const import *
 from environment import check, get_invalid_utf8strings
 from nfs4lib import bitmap2list, dict2fattr
-from nfs4_type import nfstime4, settime4
+from xdrdef.nfs4_type import nfstime4, settime4
+import nfs_ops
+op = nfs_ops.NFS4ops()
 
 def _set_mode(t, c, file, stateid=None, msg=" using stateid=0",
               warnlist=[]):
@@ -399,7 +401,7 @@ def testInvalidAttr1(t, env):
     check(res)
     badattr = dict2fattr({FATTR4_MODE: 0644})
     badattr.attr_vals = ''
-    res = c.compound(c.use_obj(path) + [c.setattr_op(env.stateid0, badattr)])
+    res = c.compound(c.use_obj(path) + [op.setattr(env.stateid0, badattr)])
     check(res, NFS4ERR_BADXDR, "SETATTR(FATTR4_MODE) with no data")
 
 def testInvalidAttr2(t, env):
@@ -418,7 +420,7 @@ def testInvalidAttr2(t, env):
     check(res)
     badattr = dict2fattr({FATTR4_MODE: 0644})
     badattr.attr_vals += 'Garbage data'
-    res = c.compound(c.use_obj(path) + [c.setattr_op(env.stateid0, badattr)])
+    res = c.compound(c.use_obj(path) + [op.setattr(env.stateid0, badattr)])
     check(res, NFS4ERR_BADXDR,
           "SETATTR(FATTR4_MODE) with extraneous attribute data appended")
 
@@ -673,7 +675,7 @@ def testInodeLocking(t, env):
     # In a single compound statement, setattr on dir and then
     # do a state operation on a file in dir (like write or remove)
     ops = c.use_obj(basedir) + [c.setattr({FATTR4_MODE:0754})]
-    ops += [c.lookup_op('file'), c.write_op(stateid, 0, 0, 'blahblah')]
+    ops += [op.lookup('file'), op.write(stateid, 0, 0, 'blahblah')]
     res = c.compound(ops)
     check(res, msg="SETATTR on dir and state operation on file in dir")
 
diff --git a/nfs4.0/servertests/st_setclientid.py b/nfs4.0/servertests/st_setclientid.py
index dbcb12e..7f42d2d 100644
--- a/nfs4.0/servertests/st_setclientid.py
+++ b/nfs4.0/servertests/st_setclientid.py
@@ -1,7 +1,9 @@
-from nfs4_const import *
+from xdrdef.nfs4_const import *
 from environment import check
 import os
 import struct, time
+import nfs_ops
+op = nfs_ops.NFS4ops()
 
 def _checkprinciples(t, env):
     """Make sure c1 and c2 have different principles"""
@@ -239,7 +241,7 @@ def testConfUnConfDiffVerifier1(t, env):
     tconfirm = res.resarray[0].switch.switch.setclientid_confirm
 
     # removes the unconfirmed { w, x, d, m, t }
-    ops = [c1.setclientid_confirm_op(uclientid, uconfirm)]
+    ops = [op.setclientid_confirm(uclientid, uconfirm)]
     res = c1.compound(ops)
     check(res, NFS4ERR_STALE_CLIENTID)
 
@@ -284,7 +286,7 @@ def testConfUnConfDiffVerifier2(t, env):
     tconfirm = res.resarray[0].switch.switch.setclientid_confirm
 
     # removes the unconfirmed { w, x, d, m, t }
-    ops = [c1.setclientid_confirm_op(uclientid, uconfirm)]
+    ops = [op.setclientid_confirm(uclientid, uconfirm)]
     res = c1.compound(ops)
     check(res, NFS4ERR_STALE_CLIENTID)
 
@@ -330,7 +332,7 @@ def testUnConfReplaced(t, env):
     tconfirm = res.resarray[0].switch.switch.setclientid_confirm
 
     # removes the unconfirmed { w, x, d, m, t }
-    ops = [c1.setclientid_confirm_op(uclientid, uconfirm)]
+    ops = [op.setclientid_confirm(uclientid, uconfirm)]
     res = c1.compound(ops)
     check(res, NFS4ERR_STALE_CLIENTID)
 
diff --git a/nfs4.0/servertests/st_setclientidconfirm.py b/nfs4.0/servertests/st_setclientidconfirm.py
index 44547a0..51f7981 100644
--- a/nfs4.0/servertests/st_setclientidconfirm.py
+++ b/nfs4.0/servertests/st_setclientidconfirm.py
@@ -1,6 +1,8 @@
-from nfs4_const import *
+from xdrdef.nfs4_const import *
 from environment import check
 import os
+import nfs_ops
+op = nfs_ops.NFS4ops()
 
 def testStale(t, env):
     """SETCLIENTID_CONFIRM with unknown id should return NFS4ERR_STALE_CLIENTID
@@ -9,7 +11,7 @@ def testStale(t, env):
     CODE: CIDCF1
     """
     c = env.c1
-    res = c.compound([c.setclientid_confirm_op(0,'')])
+    res = c.compound([op.setclientid_confirm(0,'')])
     check(res, NFS4ERR_STALE_CLIENTID, "SETCLIENTID_CONFIRM with unknown id=0")
 
 def testBadConfirm(t, env):
@@ -25,7 +27,7 @@ def testBadConfirm(t, env):
     res = c.compound([c.setclientid(id=id)])
     check(res)
     # Now confirm 1st set again, instead of 2nd
-    res = c.compound([c.setclientid_confirm_op(clientid, idconfirm)])
+    res = c.compound([op.setclientid_confirm(clientid, idconfirm)])
     check(res, msg="SETCLIENTID_CONFIRM with case not covered in RFC, "
           "seems most likely should do nothing and")
 
@@ -38,14 +40,14 @@ def testAllCases(t, env):
     c = env.c1
     id = "Clientid_for_%s_pid=%i" % (t.code, os.getpid())
     # no (**c*s), no (**c*s)
-    res = c.compound([c.setclientid_confirm_op(0,'')])
+    res = c.compound([op.setclientid_confirm(0,'')])
     check(res, NFS4ERR_STALE_CLIENTID, "SETCLIENTID_CONFIRM with unknown id=0")
     # no (**c*s) and no (*xd*t), (*xc*s)
     c.init_connection(id)
     # no (**c*s) and (*xd*t), (*xc*s)
     clientid, idconfirm = c.init_connection(id, verifier='')
     # (vxc*s), no (vxc**)
-    res = c.compound([c.setclientid_confirm_op(clientid, idconfirm)])
+    res = c.compound([op.setclientid_confirm(clientid, idconfirm)])
     check(res)
     # (vxc*t), (vxc*s)
     c.init_connection(id, verifier='')
diff --git a/nfs4.0/servertests/st_spoof.py b/nfs4.0/servertests/st_spoof.py
index b9dca89..777985e 100644
--- a/nfs4.0/servertests/st_spoof.py
+++ b/nfs4.0/servertests/st_spoof.py
@@ -1,4 +1,4 @@
-from nfs4_const import *
+from xdrdef.nfs4_const import *
 from environment import check
 
 def testSpoofUser(t, env):
diff --git a/nfs4.0/servertests/st_verify.py b/nfs4.0/servertests/st_verify.py
index 696575e..219d0a0 100644
--- a/nfs4.0/servertests/st_verify.py
+++ b/nfs4.0/servertests/st_verify.py
@@ -1,18 +1,20 @@
-from nfs4_const import *
+from xdrdef.nfs4_const import *
 from environment import check, get_invalid_clientid, makeStaleId
+import nfs_ops
+op = nfs_ops.NFS4ops()
 
 def _try_mand(env, path):
     c = env.c1
     mand_bits = [attr.bitnum for attr in env.attr_info \
                  if attr.mandatory and attr.name != 'rdattr_error']
     dict = c.do_getattrdict(path, mand_bits)
-    ops = c.use_obj(path) + [c.verify_op(dict)] + c.use_obj(path)
+    ops = c.use_obj(path) + [op.verify(dict)] + c.use_obj(path)
     res = c.compound(ops)
     check(res, msg="Verifying mandatory attributes against getattr")
 
 def _try_type(env, path, type):
     c = env.c1
-    ops = c.use_obj(path) + [c.verify_op({FATTR4_TYPE:type})] + c.use_obj(path)
+    ops = c.use_obj(path) + [op.verify({FATTR4_TYPE:type})] + c.use_obj(path)
     res = c.compound(ops)
     check(res, msg="Verifying type of /%s" % '/'.join(path))
 
@@ -20,7 +22,7 @@ def _try_changed_size(env, path):
     c = env.c1
     dict = c.do_getattrdict(path, [FATTR4_SIZE])
     dict[FATTR4_SIZE] += 1
-    ops = c.use_obj(path) + [c.verify_op(dict)] + c.use_obj(path)
+    ops = c.use_obj(path) + [op.verify(dict)] + c.use_obj(path)
     res = c.compound(ops)
     check(res, NFS4ERR_NOT_SAME, "Verifying incorrect size")
 
@@ -30,7 +32,7 @@ def _try_write_only(env, path):
     wo = [attr for attr in env.attr_info \
           if attr.writeonly or attr.name=='rdattr_error']
     for attr in wo:
-        ops = baseops + [c.verify_op({attr.bitnum: attr.sample})]
+        ops = baseops + [op.verify({attr.bitnum: attr.sample})]
         res = c.compound(ops)
         check(res, NFS4ERR_INVAL, "VERIFY with attr %s" % attr.name)
 
@@ -40,7 +42,7 @@ def _try_unsupported(env, path):
     supp_mask = c.supportedAttrs(path)
     unsupp = [attr for attr in env.attr_info if not (attr.mask & supp_mask)]
     for attr in unsupp:
-        ops = baseops + [c.verify_op({attr.bitnum: attr.sample})]
+        ops = baseops + [op.verify({attr.bitnum: attr.sample})]
         res = c.compound(ops)
         if attr.writeonly:
             check(res, [NFS4ERR_ATTRNOTSUPP, NFS4ERR_INVAL],
@@ -247,7 +249,7 @@ def testNoFh(t, env):
     CODE: VF4
     """
     c = env.c1
-    res = c.compound([c.verify_op({FATTR4_SIZE:17})])
+    res = c.compound([op.verify({FATTR4_SIZE:17})])
     check(res, NFS4ERR_NOFILEHANDLE, "VERIFY with no <cfh>")
                      
 def testWriteOnlyFile(t, env):
@@ -382,8 +384,8 @@ def testUnsupportedSocket(t, env):
                 error=[NFS4_OK]):
         """call verify and then getattr
         """
-        ops = [self.ncl.putrootfh_op()] + lookupops
-        ops.append(self.ncl.verify_op(attrs))
+        ops = [op.putrootfh()] + lookupops
+        ops.append(op.verify(attrs))
         ops.append(self.ncl.getattr(attrdict.keys()))
         res = self.ncl.do_ops(ops)
         self.assert_status(res,error)
diff --git a/nfs4.0/servertests/st_write.py b/nfs4.0/servertests/st_write.py
index 8f351ff..2f73cbb 100644
--- a/nfs4.0/servertests/st_write.py
+++ b/nfs4.0/servertests/st_write.py
@@ -1,8 +1,10 @@
-from nfs4_const import *
-from nfs4_type import *
+from xdrdef.nfs4_const import *
+from xdrdef.nfs4_type import *
 from environment import check, compareTimes, makeBadID, makeBadIDganesha, makeStaleId
 import struct
 import rpc
+import nfs_ops
+op = nfs_ops.NFS4ops()
 
 _text = 'write data' # len=10
 
@@ -358,8 +360,8 @@ def testDoubleWrite(t, env):
     c.init_connection()
     fh, stateid = c.create_confirm(t.code, deny=OPEN4_SHARE_DENY_NONE)
     ops = c.use_obj(fh)
-    ops += [c.write_op(stateid4(0, ''), 0, UNSTABLE4, 'one')]
-    ops += [c.write_op(stateid4(0, ''), 3, UNSTABLE4, 'two')]
+    ops += [op.write(stateid4(0, ''), 0, UNSTABLE4, 'one')]
+    ops += [op.write(stateid4(0, ''), 3, UNSTABLE4, 'two')]
     res = c.compound(ops)
     res = c.read_file(fh, 0, 6)
     _compare(t, res, 'onetwo', True)
@@ -407,7 +409,7 @@ def testSizes(t, env):
     fh, stateid = c.create_confirm(t.code, deny=OPEN4_SHARE_DENY_NONE)
     for i in range(0, max):
         ops = c.use_obj(fh)
-        ops += [c.write_op(stateid4(0, ''), 0, UNSTABLE4, buf[0:i])]
+        ops += [op.write(stateid4(0, ''), 0, UNSTABLE4, buf[0:i])]
         ops += [c.getattr([FATTR4_SIZE]), c.getattr([FATTR4_SIZE])]
         res = c.compound(ops)
         check(res, msg="length %d WRITE" % i)
@@ -430,8 +432,8 @@ def testLargeReadWrite(t, env):
     fh, stateid = c.create_confirm(t.code, attrs=attrs,
                                     deny=OPEN4_SHARE_DENY_NONE)
     ops = c.use_obj(fh)
-    ops += [c.read_op(stateid, 0, size)]
-    ops += [c.write_op(stateid, 0, UNSTABLE4, writedata)]
+    ops += [op.read(stateid, 0, size)]
+    ops += [op.write(stateid, 0, UNSTABLE4, writedata)]
     res = c.compound(ops)
     check(res)
     data = res.resarray[-2].switch.switch.data
@@ -462,7 +464,7 @@ def testMultipleReadWrites(t,env):
     fh, stateid = c.create_confirm(t.code)
     ops = c.use_obj(fh)
     for i in range(0, len(offsets) - 1):
-        ops += [c.write_op(stateid, offsets[i], UNSTABLE4,
+        ops += [op.write(stateid, offsets[i], UNSTABLE4,
 					data[offsets[i]:offsets[i+1]])]
     res = c.compound(ops)
     check(res, msg="compound with multiple WRITE operations")
@@ -472,7 +474,7 @@ def testMultipleReadWrites(t,env):
     for i in range(0, len(read_offsets) - 1):
         offset = read_offsets[i]
         bytes = read_offsets[i+1] - offset;
-        ops += [c.read_op(stateid, offset, bytes)]
+        ops += [op.read(stateid, offset, bytes)]
     res = c.compound(ops)
     check(res, msg="compound with multiple READ operations")
     for i in range(0, len(read_offsets) - 2):
@@ -496,10 +498,10 @@ def testChangeGranularityWrite(t, env):
     c.init_connection()
     fh, stateid = c.create_confirm(t.code)
     ops = c.use_obj(fh) + [c.getattr([FATTR4_CHANGE])] \
-        + [c.write_op(stateid, 0,  UNSTABLE4, _text)] + [c.getattr([FATTR4_CHANGE])] \
-        + [c.write_op(stateid, 10, UNSTABLE4, _text)] + [c.getattr([FATTR4_CHANGE])] \
-        + [c.write_op(stateid, 20, UNSTABLE4, _text)] + [c.getattr([FATTR4_CHANGE])] \
-        + [c.write_op(stateid, 30, UNSTABLE4, _text)] + [c.getattr([FATTR4_CHANGE])]
+        + [op.write(stateid, 0,  UNSTABLE4, _text)] + [c.getattr([FATTR4_CHANGE])] \
+        + [op.write(stateid, 10, UNSTABLE4, _text)] + [c.getattr([FATTR4_CHANGE])] \
+        + [op.write(stateid, 20, UNSTABLE4, _text)] + [c.getattr([FATTR4_CHANGE])] \
+        + [op.write(stateid, 30, UNSTABLE4, _text)] + [c.getattr([FATTR4_CHANGE])]
     res = c.compound(ops)
     check(res)
     chattr1 = res.resarray[1].obj_attributes
diff --git a/nfs4.0/setup.py b/nfs4.0/setup.py
index d5d3ad8..fa680e2 100755
--- a/nfs4.0/setup.py
+++ b/nfs4.0/setup.py
@@ -1,10 +1,7 @@
 #!/usr/bin/env python
 
-DESCRIPTION = """\
-pynfs is a collection of tools and libraries for NFS4. It includes
-a NFS4 library and a server test application.
-"""
-
+from __future__ import print_function
+from __future__ import absolute_import
 import sys
 from distutils.core import setup, Extension
 from distutils.dep_util import newer_group
@@ -16,6 +13,11 @@ except ImportError:
     import use_local
     import xdrgen
 
+DESCRIPTION = """\
+pynfs is a collection of tools and libraries for NFS4. It includes
+a NFS4 library and a server test application.
+"""
+
 topdir = os.getcwd()
 if  __name__ == "__main__":
     if os.path.isfile(os.path.join(topdir, 'lib', 'testmod.py')):
@@ -38,20 +40,17 @@ def use_xdr(dir, xdrfile):
     if needs_updating(xdrfile):
         xdrgen.run(xdrfile)
         for file in glob.glob(os.path.join(dir, 'parse*')):
-            print "deleting", file
+            print("deleting", file)
             os.remove(file)
 
 def generate_files():
     home = os.getcwd()
-    use_xdr(topdir, 'nfs4.x')
-    import ops_gen # this must be delayed until nfs4.x is parsed
-    sources = [ os.path.join(topdir, 'lib', 'ops_gen.py'),
-                'nfs4_const.py', 'nfs4_type.py' ]
-    if newer_group(sources, 'nfs4_ops.py'):
-        print "Generating nfs4_ops.py"
-        ops_gen.run()
+    use_xdr(os.path.join(topdir, 'xdrdef'), 'nfs4.x')
+    use_xdr(os.path.join(topdir, 'xdrdef'), 'nfs3.x')
+
     dir = os.path.join(topdir, 'lib', 'rpc')
     use_xdr(dir, 'rpc.x')
+
     dir = os.path.join(topdir, 'lib', 'rpc', 'rpcsec')
     use_xdr(dir, 'gss.x')
     os.chdir(home)
@@ -83,4 +82,4 @@ information on various ways to set the search path.
 One easy way is to set the environment variable PYTHONPATH.
 """
 if "install" in sys.argv:
-    print PATHHELP
+    print(PATHHELP)
diff --git a/nfs4.0/testserver.py b/nfs4.0/testserver.py
index fd3e6e7..9af7703 100755
--- a/nfs4.0/testserver.py
+++ b/nfs4.0/testserver.py
@@ -213,7 +213,7 @@ def run_filter(test, options):
 
 def printflags(list):
     """Print all legal flag names, which are given in list"""
-    from nfs4_const import nfs_opnum4
+    from xdrdef.nfs4_const import nfs_opnum4
     command_names = [s.lower()[3:].replace('_', '') \
                      for s in nfs_opnum4.values()]
     list.sort()
diff --git a/nfs4.0/xdrdef b/nfs4.0/xdrdef
new file mode 120000
index 0000000..c6a775b
--- /dev/null
+++ b/nfs4.0/xdrdef
@@ -0,0 +1 @@
+../nfs4.1/xdrdef
\ No newline at end of file
-- 
2.14.3

