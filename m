Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f171.google.com ([209.85.223.171]:36360 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751664AbaFENz5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Jun 2014 09:55:57 -0400
Received: by mail-ie0-f171.google.com with SMTP id to1so905774ieb.30
        for <linux-nfs@vger.kernel.org>; Thu, 05 Jun 2014 06:55:57 -0700 (PDT)
From: Weston Andros Adamson <dros@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH pynfs v2 09/16] dataserver: don't import * from nfs4 specific mods
Date: Thu,  5 Jun 2014 09:55:37 -0400
Message-Id: <1401976544-36374-10-git-send-email-dros@primarydata.com>
In-Reply-To: <1401976544-36374-1-git-send-email-dros@primarydata.com>
References: <1401976544-36374-1-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

don't pollute the global namespace with constants and types from nfs4_*

this is in preparation for NFSv3 DSes.

Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
---
 nfs4.1/dataserver.py | 60 ++++++++++++++++++++++++++--------------------------
 1 file changed, 30 insertions(+), 30 deletions(-)

diff --git a/nfs4.1/dataserver.py b/nfs4.1/dataserver.py
index 16be4c4..f9e9740 100644
--- a/nfs4.1/dataserver.py
+++ b/nfs4.1/dataserver.py
@@ -1,8 +1,8 @@
 import rpc
 import nfs4lib
-from xdrdef.nfs4_type import *
+import xdrdef.nfs4_type as type4
 from xdrdef.nfs4_pack import NFS4Packer
-from xdrdef.nfs4_const import *
+import xdrdef.nfs4_const as const4
 import time
 import logging
 import nfs4client
@@ -56,7 +56,7 @@ class DataServer41(object):
         c = self.c1.new_client("DS.init_%s" % self.server)
         # This is a hack to ensure MDS/DS communication path is at least
         # as wide as the client/MDS channel (at least for linux client)
-        fore_attrs = channel_attrs4(0, 16384, 16384, 2868, 8, 8, [])
+        fore_attrs = type4.channel_attrs4(0, 16384, 16384, 2868, 8, 8, [])
         self.sess = c.create_session(fore_attrs=fore_attrs)
         sess.compound([op.reclaim_complete(FALSE)])
         self.make_root()
@@ -69,12 +69,12 @@ class DataServer41(object):
         If an error code is specified in the exceptions it means that the
         caller wants to handle the error himself
         """
-        retry_errors = [NFS4ERR_DELAY, NFS4ERR_GRACE]
-        state_errors = [NFS4ERR_STALE_CLIENTID, NFS4ERR_BADSESSION,
-                        NFS4ERR_BADSLOT, NFS4ERR_DEADSESSION]
+        retry_errors = [const4.NFS4ERR_DELAY, const4.NFS4ERR_GRACE]
+        state_errors = [const4.NFS4ERR_STALE_CLIENTID, const4.NFS4ERR_BADSESSION,
+                        const4.NFS4ERR_BADSLOT, const4.NFS4ERR_DEADSESSION]
         while True:
             res = self.sess.compound(ops)
-            if res.status == NFS4_OK or res.status in exceptions:
+            if res.status == const4.NFS4_OK or res.status in exceptions:
                 return res
             elif res.status in retry_errors:
                 if maxretries > 0:
@@ -96,7 +96,7 @@ class DataServer41(object):
         uaddr = '.'.join([self.server,
                           str(self.port >> 8),
                           str(self.port & 0xff)])
-        return netaddr4(self.proto, uaddr)
+        return type4.netaddr4(self.proto, uaddr)
 
     def get_multipath_netaddr4s(self):
         netaddr4s = []
@@ -109,24 +109,24 @@ class DataServer41(object):
             if server.find(':') >= 0:
                 proto = "tcp6"
 
-            netaddr4s.append(netaddr4(proto, uaddr))
+            netaddr4s.append(type4.netaddr4(proto, uaddr))
         return netaddr4s
 
 
-    def make_root(self, attrs={FATTR4_MODE:0777}):
+    def make_root(self, attrs={const4.FATTR4_MODE:0777}):
         existing_path = []
-        kind = createtype4(NF4DIR)
+        kind = type4.createtype4(const4.NF4DIR)
         for comp in self.path:
             existing_path.append(comp)
             res = self._execute(nfs4lib.use_obj(existing_path),
-                               exceptions=[NFS4ERR_NOENT])
-            if res.status == NFS4ERR_NOENT:
+                               exceptions=[const4.NFS4ERR_NOENT])
+            if res.status == const4.NFS4ERR_NOENT:
                 cr_ops = nfs4lib.use_obj(existing_path[:-1]) + \
                     [op.create(kind, comp, attrs)]
                 self._execute(cr_ops)
         res = self._execute(nfs4lib.use_obj(self.path) + [op.getfh()])
         self.path_fh = res.resarray[-1].object
-        need = ACCESS4_READ | ACCESS4_LOOKUP | ACCESS4_MODIFY | ACCESS4_EXTEND
+        need = const4.ACCESS4_READ | const4.ACCESS4_LOOKUP | const4.ACCESS4_MODIFY | const4.ACCESS4_EXTEND
         res = self._execute(nfs4lib.use_obj(self.path_fh) + [op.access(need)])
         if res.resarray[-1].access != need:
             raise RuntimeError
@@ -136,25 +136,25 @@ class DataServer41(object):
         return hashlib.sha1("%r" % mds_fh).hexdigest()
 
     def open_file(self, mds_fh, seqid=0,
-                  access=OPEN4_SHARE_ACCESS_BOTH, deny=OPEN4_SHARE_DENY_NONE,
-                  attrs={FATTR4_MODE: 0777}, owner = "mds", mode=GUARDED4):
+                  access=const4.OPEN4_SHARE_ACCESS_BOTH, deny=const4.OPEN4_SHARE_DENY_NONE,
+                  attrs={const4.FATTR4_MODE: 0777}, owner = "mds", mode=const4.GUARDED4):
         verifier = self.sess.c.verifier
-        openflag = openflag4(OPEN4_CREATE, createhow4(mode, attrs, verifier))
+        openflag = type4.openflag4(const4.OPEN4_CREATE, type4.createhow4(mode, attrs, verifier))
         name = self.fh_to_name(mds_fh)
         while True:
             if mds_fh in self.filehandles:
                 return
             open_op = op.open(seqid, access, deny,
-                              open_owner4(self.sess.client.clientid, owner),
-                              openflag, open_claim4(CLAIM_NULL, name))
-            res = self._execute(nfs4lib.use_obj(self.path_fh) + [open_op, op.getfh()], exceptions=[NFS4ERR_EXIST])
-            if res.status == NFS4_OK:
+                              type4.open_owner4(self.sess.client.clientid, owner),
+                              openflag, type4.open_claim4(const4.CLAIM_NULL, name))
+            res = self._execute(nfs4lib.use_obj(self.path_fh) + [open_op, op.getfh()], exceptions=[const4.NFS4ERR_EXIST])
+            if res.status == const4.NFS4_OK:
                  ds_fh = res.resarray[-1].opgetfh.resok4.object
-                 ds_openstateid = stateid4(0, res.resarray[-2].stateid.other)
+                 ds_openstateid = type4.stateid4(0, res.resarray[-2].stateid.other)
                  self.filehandles[mds_fh] = (ds_fh, ds_openstateid)
                  return
-            elif res.status == NFS4ERR_EXIST:
-                 openflag = openflag4(OPEN4_NOCREATE)
+            elif res.status == const4.NFS4ERR_EXIST:
+                 openflag = type4.openflag4(const4.OPEN4_NOCREATE)
             else:
                 raise RuntimeError
 
@@ -177,26 +177,26 @@ class DataServer41(object):
 
     def write(self, fh, pos, data):
         ops = [op.putfh(fh),
-               op.write(nfs4lib.state00, pos, FILE_SYNC4, data)]
+               op.write(nfs4lib.state00, pos, const4.FILE_SYNC4, data)]
         # There are all sorts of error handling issues here
         res = self._execute(ops)
 
     def truncate(self, fh, size):
         ops = [op.putfh(fh),
-               op.setattr(nfs4lib.state00, {FATTR4_SIZE: size})]
+               op.setattr(nfs4lib.state00, {const4.FATTR4_SIZE: size})]
         res = self._execute(ops)
 
     def get_size(self, fh):
         ops = [op.putfh(fh),
-               op.getattr(1L << FATTR4_SIZE)]
+               op.getattr(1L << const4.FATTR4_SIZE)]
         res = self._execute(ops)
         attrdict = res.resarray[-1].obj_attributes
-        return attrdict.get(FATTR4_SIZE, 0)
+        return attrdict.get(const4.FATTR4_SIZE, 0)
 
 
 class DSDevice(object):
     def __init__(self, mdsds):
-        self.list = [] # list of DataServer instances
+        self.list = [] # list of DataServer41 instances
         # STUB only one data group supported for now
         self.devid = 0
         self.active = 0
@@ -248,7 +248,7 @@ class DSDevice(object):
                 netaddrs.append(multipath)
                 stripe_indices.append(index)
                 index = index + 1
-        addr = nfsv4_1_file_layout_ds_addr4(stripe_indices, netaddrs)
+        addr = type4.nfsv4_1_file_layout_ds_addr4(stripe_indices, netaddrs)
         p = NFS4Packer()
         p.pack_nfsv4_1_file_layout_ds_addr4(addr)
         return p.get_buffer()
-- 
1.8.5.2 (Apple Git-48)

