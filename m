Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f173.google.com ([209.85.223.173]:37165 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752043AbaFDVCa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Jun 2014 17:02:30 -0400
Received: by mail-ie0-f173.google.com with SMTP id lx4so68752iec.18
        for <linux-nfs@vger.kernel.org>; Wed, 04 Jun 2014 14:02:29 -0700 (PDT)
From: Weston Andros Adamson <dros@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH pynfs 11/17] 4.1 server: move nfs4_ops.py to nfs_ops.py
Date: Wed,  4 Jun 2014 17:01:59 -0400
Message-Id: <1401915726-29092-12-git-send-email-dros@primarydata.com>
In-Reply-To: <1401915726-29092-1-git-send-email-dros@primarydata.com>
References: <1401915726-29092-1-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Also replace ugly exec & inspect code to just define a class with
a __getattr__ switch.

Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
---
 nfs4.1/dataserver.py | 32 ++++++++++---------
 nfs4.1/fs.py         |  2 --
 nfs4.1/nfs4_ops.py   | 61 -----------------------------------
 nfs4.1/nfs4client.py | 16 +++++-----
 nfs4.1/nfs4lib.py    |  8 +++--
 nfs4.1/nfs4state.py  |  8 +++--
 nfs4.1/nfs_ops.py    | 89 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 7 files changed, 125 insertions(+), 91 deletions(-)
 delete mode 100644 nfs4.1/nfs4_ops.py
 create mode 100644 nfs4.1/nfs_ops.py

diff --git a/nfs4.1/dataserver.py b/nfs4.1/dataserver.py
index a825615..c73e195 100644
--- a/nfs4.1/dataserver.py
+++ b/nfs4.1/dataserver.py
@@ -8,11 +8,13 @@ import logging
 import nfs4client
 import hashlib
 import sys
-import nfs4_ops as op
+import nfs_ops
 import socket
 
 log = logging.getLogger("Dataserver Manager")
 
+op4 = nfs_ops.NFS4ops()
+
 class DataServer41(object):
     def __init__(self, server, port, path, flavor=rpc.AUTH_SYS, active=True, mdsds=True, multipath_servers=None, summary=None):
         self.mdsds = mdsds
@@ -121,12 +123,12 @@ class DataServer41(object):
                                exceptions=[const4.NFS4ERR_NOENT])
             if res.status == const4.NFS4ERR_NOENT:
                 cr_ops = nfs4lib.use_obj(existing_path[:-1]) + \
-                    [op.create(kind, comp, attrs)]
+                    [op4.create(kind, comp, attrs)]
                 self._execute(cr_ops)
-        res = self._execute(nfs4lib.use_obj(self.path) + [op.getfh()])
+        res = self._execute(nfs4lib.use_obj(self.path) + [op4.getfh()])
         self.path_fh = res.resarray[-1].object
         need = const4.ACCESS4_READ | const4.ACCESS4_LOOKUP | const4.ACCESS4_MODIFY | const4.ACCESS4_EXTEND
-        res = self._execute(nfs4lib.use_obj(self.path_fh) + [op.access(need)])
+        res = self._execute(nfs4lib.use_obj(self.path_fh) + [op4.access(need)])
         if res.resarray[-1].access != need:
             raise RuntimeError
         # XXX clean DS directory
@@ -143,10 +145,10 @@ class DataServer41(object):
         while True:
             if mds_fh in self.filehandles:
                 return
-            open_op = op.open(seqid, access, deny,
+            open_op = op4.open(seqid, access, deny,
                               type4.open_owner4(self.sess.client.clientid, owner),
                               openflag, type4.open_claim4(const4.CLAIM_NULL, name))
-            res = self._execute(nfs4lib.use_obj(self.path_fh) + [open_op, op.getfh()], exceptions=[const4.NFS4ERR_EXIST])
+            res = self._execute(nfs4lib.use_obj(self.path_fh) + [open_op, op4.getfh()], exceptions=[const4.NFS4ERR_EXIST])
             if res.status == const4.NFS4_OK:
                  ds_fh = res.resarray[-1].opgetfh.resok4.object
                  ds_openstateid = type4.stateid4(0, res.resarray[-2].stateid.other)
@@ -161,33 +163,33 @@ class DataServer41(object):
         """close the given file"""
         seqid=0 #FIXME: seqid must be !=0
         fh, stateid = self.filehandles[mds_fh]
-        ops = [op.putfh(fh)] + [op.close(seqid, stateid)]
+        ops = [op4.putfh(fh)] + [op4.close(seqid, stateid)]
         res = self._execute(ops)
         # ignoring return
         del self.filehandles[mds_fh]
 
     def read(self, fh, pos, count):
-        ops = [op.putfh(fh),
-               op.read(nfs4lib.state00, pos, count)]
+        ops = [op4.putfh(fh),
+               op4.read(nfs4lib.state00, pos, count)]
         # There are all sorts of error handling issues here
         res = self._execute(ops)
         data = res.resarray[-1].data
         return data
 
     def write(self, fh, pos, data):
-        ops = [op.putfh(fh),
-               op.write(nfs4lib.state00, pos, const4.FILE_SYNC4, data)]
+        ops = [op4.putfh(fh),
+               op4.write(nfs4lib.state00, pos, const4.FILE_SYNC4, data)]
         # There are all sorts of error handling issues here
         res = self._execute(ops)
 
     def truncate(self, fh, size):
-        ops = [op.putfh(fh),
-               op.setattr(nfs4lib.state00, {const4.FATTR4_SIZE: size})]
+        ops = [op4.putfh(fh),
+               op4.setattr(nfs4lib.state00, {const4.FATTR4_SIZE: size})]
         res = self._execute(ops)
 
     def get_size(self, fh):
-        ops = [op.putfh(fh),
-               op.getattr(1L << const4.FATTR4_SIZE)]
+        ops = [op4.putfh(fh),
+               op4.getattr(1L << const4.FATTR4_SIZE)]
         res = self._execute(ops)
         attrdict = res.resarray[-1].obj_attributes
         return attrdict.get(const4.FATTR4_SIZE, 0)
diff --git a/nfs4.1/fs.py b/nfs4.1/fs.py
index 8fc49ef..8947014 100644
--- a/nfs4.1/fs.py
+++ b/nfs4.1/fs.py
@@ -1557,8 +1557,6 @@ class FileLayoutFile(object): # XXX This should inherit from fs_base.py
         vol = FilelayoutVolWrapper(self._obj, device.list[index])
         return vol, v_pos, remaining
 
-import nfs4_ops as op
-
 class FilelayoutVolWrapper(object):
     def __init__(self, obj, dataserver):
         self._obj = obj
diff --git a/nfs4.1/nfs4_ops.py b/nfs4.1/nfs4_ops.py
deleted file mode 100644
index 35a10ca..0000000
--- a/nfs4.1/nfs4_ops.py
+++ /dev/null
@@ -1,61 +0,0 @@
-"""For each OP_<NAME> in nfs_argop4 and nfs_cb_argop4, create a function
-<name>() that returns the appropriate *_argop4 structure, hiding
-this routine packing from the user.
-"""
-import xdrdef.nfs4_type as _type
-import xdrdef.nfs4_const as _const
-
-# This string is our general function template
-code = """\
-def %(funct_name)s(%(funct_args)s):
-    %(create_args)s
-    return _type.%(argop)s(_const.OP_%(enum_name)s, %(set_args)s)
-"""
-
-def _mappings():
-    return _pull_argops(_const.nfs_opnum4) + _pull_argops(_const.nfs_cb_opnum4)
-
-def _pull_argops(op_dict):
-    """ For each entry in op_dict, create an appropriate dictionary that can
-        be used to fill the 'code' template.
-    """
-    import inspect
-    out = []
-    keys = op_dict.keys()
-    keys.sort() # Not necessary, but makes scanning the printout easier
-    for k in keys:
-        # Create a dictionary that will be used to fill the 'code' template
-        d = {}
-        d["enum_name"] = enum_name = op_dict[k][3:] # <NAME>
-        d["funct_name"] = "%s" % enum_name.lower() # <name>
-        class_name = "%s4args" % enum_name
-        klass = getattr(_type, class_name, None)
-        if klass is None:
-            # This operation takes no arguments
-            d["funct_args"] = d["create_args"] = d["set_args"] = ""
-        else:
-            if type(klass) is dict:
-                arg_list = "enum_value"
-                d["create_args"] = "args = enum_value"
-            else:
-                arg_list = ", ".join(inspect.getargspec(klass.__init__)[0][1:])
-                d["create_args"] = "args = _type.%s(%s)" % (class_name, arg_list)
-            d["funct_args"] = arg_list
-            if enum_name.startswith("CB_"):
-                d["set_args"] = "opcb%s=args" % enum_name.lower()[3:]
-            else:
-                d["set_args"] = "op%s=args" % enum_name.lower()
-        if enum_name.startswith("CB_"):
-            d["argop"] = "nfs_cb_argop4"
-        else:
-            d["argop"] = "nfs_argop4"
-        out.append(d)
-    return out
-
-if __name__ == "__main__":
-    for _d in _mappings():
-        print code % _d
-else:
-    for _d in _mappings():
-        exec code % _d
-    
diff --git a/nfs4.1/nfs4client.py b/nfs4.1/nfs4client.py
index f5d2006..263f37d 100644
--- a/nfs4.1/nfs4client.py
+++ b/nfs4.1/nfs4client.py
@@ -5,7 +5,7 @@ from nfs4lib import NFS4Error, NFS4Replay, inc_u32
 from xdrdef.nfs4_type import *
 from xdrdef.nfs4_const import *
 from xdrdef.sctrl_pack import SCTRLPacker, SCTRLUnpacker
-import nfs4_ops as op
+import nfs_ops
 import time, struct
 import threading
 import hmac
@@ -20,6 +20,8 @@ logging.basicConfig(level=logging.INFO,
                     format="%(levelname)-7s:%(name)s:%(message)s")
 log_cb = logging.getLogger("nfs.client.cb")
 
+op4 = nfs_ops.NFS4ops()
+
 class NFS4Client(rpc.Client, rpc.Server):
     def __init__(self, host='localhost', port=2049, minorversion=1, ctrl_proc=16, summary=None):
         rpc.Client.__init__(self, 100003, 4)
@@ -275,7 +277,7 @@ class NFS4Client(rpc.Client, rpc.Server):
         owner = client_owner4(verf, name)
         if protect is None:
             protect = state_protect4_a(SP4_NONE)
-        res = self.compound([op.exchange_id(owner, flags, protect,
+        res = self.compound([op4.exchange_id(owner, flags, protect,
                                             [self.impl_id])],
                             cred)
         nfs4lib.check(res, expect)
@@ -287,7 +289,7 @@ class NFS4Client(rpc.Client, rpc.Server):
     def new_client_session(self, name, flags=0, sec=None):
         c = self.new_client(name, flags=flags)
         s = c.create_session(sec=sec)
-        s.compound([op.reclaim_complete(FALSE)])
+        s.compound([op4.reclaim_complete(FALSE)])
         return s
 
 class ClientStateProtection(object):
@@ -339,7 +341,7 @@ class ClientRecord(object):
         if prog is None:
             prog = self.c.prog
         for item in xrange(max_retries):
-            res = self.c.compound([op.create_session(self.clientid, self.seqid,
+            res = self.c.compound([op4.create_session(self.clientid, self.seqid,
                                                  flags,
                                                  fore_attrs, back_attrs,
                                                  prog, sec)],
@@ -362,7 +364,7 @@ class ClientRecord(object):
         self.seqid = inc_u32(csr.csr_sequence) # XXX Do we need to check this?
         sess = SessionRecord(csr, self)
         self.c.sessions[sess.sessionid] = sess
-        sess.compound([op.reclaim_complete(FALSE)])
+        sess.compound([op4.reclaim_complete(FALSE)])
         return sess
 
     def _cb_hook(self, prefix, opname, funct):
@@ -430,7 +432,7 @@ class SessionRecord(object):
             raise RuntimeError
             slot = self.fore_channel.slots[slot]
         # STUB, need to properly set highest
-        return op.sequence(self.sessionid, slot.get_seqid(seq_delta),
+        return op4.sequence(self.sessionid, slot.get_seqid(seq_delta),
                            slot.id, slot.id, cache_this)
 
     def set_ssv(self, ssv=None, *args, **kwargs):
@@ -443,7 +445,7 @@ class SessionRecord(object):
         p = nfs4lib.FancyNFS4Packer()
         p.pack_SEQUENCE4args(seq_op.opsequence)
         digest =  protect.context.hmac(p.get_buffer(), SSV4_SUBKEY_MIC_I2T)
-        ssv_op = op.set_ssv(ssv, digest)
+        ssv_op = op4.set_ssv(ssv, digest)
         res = self.c.compound([seq_op, ssv_op], *args, **kwargs)
         # STUB - do some checking
         protect.context.set_ssv(ssv)
diff --git a/nfs4.1/nfs4lib.py b/nfs4.1/nfs4lib.py
index 116324a..02352e1 100644
--- a/nfs4.1/nfs4lib.py
+++ b/nfs4.1/nfs4lib.py
@@ -3,7 +3,7 @@ import rpc
 import xdrdef.nfs4_const
 from xdrdef.nfs4_pack import NFS4Packer, NFS4Unpacker
 import xdrdef.nfs4_type
-import nfs4_ops as op
+import nfs_ops
 import time
 import collections
 import hmac
@@ -30,6 +30,8 @@ state01 = xdrdef.nfs4_type.stateid4(1, "\0" * 12)
 
 import hashlib # Note this requires 2.5 or higher
 
+op4 = nfs_ops.NFS4ops()
+
 # Note that all the oid strings have tag and length bytes prepended, as
 # per description of sec_oid4 in draft26 sect 3.2
 
@@ -626,9 +628,9 @@ def use_obj(file):
     if file is None or file == [None]:
         return []
     elif type(file) is str:
-        return [op.putfh(file)]
+        return [op4.putfh(file)]
     else:
-        return [op.putrootfh()] + [op.lookup(comp) for comp in file]
+        return [op4.putrootfh()] + [op4.lookup(comp) for comp in file]
 
 ###############################################
 # Attribute information
diff --git a/nfs4.1/nfs4state.py b/nfs4.1/nfs4state.py
index 2f3cd59..2214c0d 100644
--- a/nfs4.1/nfs4state.py
+++ b/nfs4.1/nfs4state.py
@@ -8,12 +8,14 @@ from nfs4lib import NFS4Error
 #from xdrdef.nfs4_type import stateid4
 from xdrdef.nfs4_type import *
 from xdrdef.nfs4_const import *
-import nfs4_ops as op
+import nfs_ops
 import rpc
 import logging
 
 log = logging.getLogger("nfs.server.state")
 
+op4 = nfs_ops.NFS4ops()
+
 POSIXLOCK = False
 
 SHARE, BYTE, DELEG, LAYOUT, ANON = range(5) # State types
@@ -748,9 +750,9 @@ class DelegEntry(StateTableEntry):
         # ANSWER - we care about self.status, which can be set to 
         # INVALID anytime by deleg_return
         slot = session.channel_back.choose_slot()
-        seq_op = op.cb_sequence(session.sessionid, slot.get_seqid(),
+        seq_op = op4.cb_sequence(session.sessionid, slot.get_seqid(),
                                 slot.id, slot.id, True, []) # STUB
-        recall_op = op.cb_recall(self.get_id(cb=True), False, self.file.fh)
+        recall_op = op4.cb_recall(self.get_id(cb=True), False, self.file.fh)
         if self.invalid:
             # Race here doesn't matter, but would like to avoid the
             # RPC if possible.
diff --git a/nfs4.1/nfs_ops.py b/nfs4.1/nfs_ops.py
new file mode 100644
index 0000000..0753716
--- /dev/null
+++ b/nfs4.1/nfs_ops.py
@@ -0,0 +1,89 @@
+"""For each OP_<NAME> in nfs_argop4 and nfs_cb_argop4, create a function
+<name>() that returns the appropriate *_argop4 structure, hiding
+this routine packing from the user.
+"""
+
+from xdrdef import nfs4_type
+from xdrdef import nfs4_const
+
+from xdrdef import nfs3_type
+from xdrdef import nfs3_const
+
+def nfs4_op_names():
+    skip = len('OP_')
+    ops = [ x.lower()[skip:] for x in nfs4_const.nfs_opnum4.values() ]
+    ops.extend([ x.lower()[skip:] for x in nfs4_const.nfs_cb_opnum4.values()])
+    return ops
+
+def nfs3_proc_names():
+    pre = 'NFSPROC3_'
+    skip = len(pre)
+    procs = [ x.lower()[skip:] for x in dir(nfs3_const) if x.startswith(pre) ]
+    return procs
+
+class NFSops:
+    def __init__(self, is_v4):
+        self._is_v4 = is_v4
+        if is_v4:
+            self._op_names = nfs4_op_names()
+            self._type = nfs4_type
+            self._const = nfs4_const
+            self._args_suffix = '4args'
+            self._op_prefix = 'OP_'
+        else:
+            self._op_names = nfs3_proc_names()
+            self._type = nfs3_type
+            self._const = nfs3_const
+            self._args_suffix = '3args'
+            self._op_prefix = 'NFSPROC3_'
+
+    def __getattr__(self, attrname):
+        if attrname in self._op_names:
+            return lambda *args: self._handle_op(attrname, args)
+
+    def _handle_op(self, opname, args):
+        enum_name = opname.upper()
+
+        # RPC "args" class to create
+        class_name = "%s%s" % (enum_name, self._args_suffix)
+        klass = getattr(self._type, class_name, None)
+
+        if self._is_v4:
+            # stuff class into argop
+
+            # args to pass to argop __init__
+            opnum = getattr(self._const, self._op_prefix + enum_name)
+            kwargs = {}
+
+            if klass:
+                # otherwise it takes no arguments
+                if type(klass) is dict:
+                    assert len(args) == 1
+                    arg = args[0]
+                else:
+                    arg = klass(*args)
+
+                if enum_name.startswith("CB_"):
+                    kwargs['opcb%s' % enum_name.lower()] = arg
+                else:
+                    kwargs['op%s' % enum_name.lower()] = arg
+
+            if enum_name.startswith("CB_"):
+                argop = self._type.nfs_cb_argop4
+            else:
+                argop = self._type.nfs_argop4
+
+            return argop(opnum, **kwargs)
+
+        else:
+            # for v3 just return an instance
+            return klass(*args)
+
+class NFS3ops(NFSops):
+    def __init__(self):
+        NFSops.__init__(self, False)
+
+class NFS4ops(NFSops):
+    def __init__(self):
+        NFSops.__init__(self, True)
+
-- 
1.8.5.2 (Apple Git-48)

