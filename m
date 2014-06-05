Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f175.google.com ([209.85.223.175]:50972 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751658AbaFENz5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Jun 2014 09:55:57 -0400
Received: by mail-ie0-f175.google.com with SMTP id y20so915973ier.34
        for <linux-nfs@vger.kernel.org>; Thu, 05 Jun 2014 06:55:56 -0700 (PDT)
From: Weston Andros Adamson <dros@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH pynfs v2 08/16] dataserver: make generic interface to ops
Date: Thu,  5 Jun 2014 09:55:36 -0400
Message-Id: <1401976544-36374-9-git-send-email-dros@primarydata.com>
In-Reply-To: <1401976544-36374-1-git-send-email-dros@primarydata.com>
References: <1401976544-36374-1-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hide the execute method to make DataServer objects more generic.

Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
---
 nfs4.1/dataserver.py | 41 ++++++++++++++++++++++++++++++++++-------
 nfs4.1/fs.py         | 24 ++++--------------------
 2 files changed, 38 insertions(+), 27 deletions(-)

diff --git a/nfs4.1/dataserver.py b/nfs4.1/dataserver.py
index dd81b20..16be4c4 100644
--- a/nfs4.1/dataserver.py
+++ b/nfs4.1/dataserver.py
@@ -64,7 +64,7 @@ class DataServer41(object):
     def disconnect(self):
         pass
 
-    def execute(self, ops, exceptions=[], delay=5, maxretries=3):
+    def _execute(self, ops, exceptions=[], delay=5, maxretries=3):
         """ execute the NFS call
         If an error code is specified in the exceptions it means that the
         caller wants to handle the error himself
@@ -118,16 +118,16 @@ class DataServer41(object):
         kind = createtype4(NF4DIR)
         for comp in self.path:
             existing_path.append(comp)
-            res = self.execute(nfs4lib.use_obj(existing_path),
+            res = self._execute(nfs4lib.use_obj(existing_path),
                                exceptions=[NFS4ERR_NOENT])
             if res.status == NFS4ERR_NOENT:
                 cr_ops = nfs4lib.use_obj(existing_path[:-1]) + \
                     [op.create(kind, comp, attrs)]
-                self.execute(cr_ops)
-        res = self.execute(nfs4lib.use_obj(self.path) + [op.getfh()])
+                self._execute(cr_ops)
+        res = self._execute(nfs4lib.use_obj(self.path) + [op.getfh()])
         self.path_fh = res.resarray[-1].object
         need = ACCESS4_READ | ACCESS4_LOOKUP | ACCESS4_MODIFY | ACCESS4_EXTEND
-        res = self.execute(nfs4lib.use_obj(self.path_fh) + [op.access(need)])
+        res = self._execute(nfs4lib.use_obj(self.path_fh) + [op.access(need)])
         if res.resarray[-1].access != need:
             raise RuntimeError
         # XXX clean DS directory
@@ -147,7 +147,7 @@ class DataServer41(object):
             open_op = op.open(seqid, access, deny,
                               open_owner4(self.sess.client.clientid, owner),
                               openflag, open_claim4(CLAIM_NULL, name))
-            res = self.execute(nfs4lib.use_obj(self.path_fh) + [open_op, op.getfh()], exceptions=[NFS4ERR_EXIST])
+            res = self._execute(nfs4lib.use_obj(self.path_fh) + [open_op, op.getfh()], exceptions=[NFS4ERR_EXIST])
             if res.status == NFS4_OK:
                  ds_fh = res.resarray[-1].opgetfh.resok4.object
                  ds_openstateid = stateid4(0, res.resarray[-2].stateid.other)
@@ -163,10 +163,37 @@ class DataServer41(object):
         seqid=0 #FIXME: seqid must be !=0
         fh, stateid = self.filehandles[mds_fh]
         ops = [op.putfh(fh)] + [op.close(seqid, stateid)]
-        res = self.execute(ops)
+        res = self._execute(ops)
         # ignoring return
         del self.filehandles[mds_fh]
 
+    def read(self, fh, pos, count):
+        ops = [op.putfh(fh),
+               op.read(nfs4lib.state00, pos, count)]
+        # There are all sorts of error handling issues here
+        res = self._execute(ops)
+        data = res.resarray[-1].data
+        return data
+
+    def write(self, fh, pos, data):
+        ops = [op.putfh(fh),
+               op.write(nfs4lib.state00, pos, FILE_SYNC4, data)]
+        # There are all sorts of error handling issues here
+        res = self._execute(ops)
+
+    def truncate(self, fh, size):
+        ops = [op.putfh(fh),
+               op.setattr(nfs4lib.state00, {FATTR4_SIZE: size})]
+        res = self._execute(ops)
+
+    def get_size(self, fh):
+        ops = [op.putfh(fh),
+               op.getattr(1L << FATTR4_SIZE)]
+        res = self._execute(ops)
+        attrdict = res.resarray[-1].obj_attributes
+        return attrdict.get(FATTR4_SIZE, 0)
+
+
 class DSDevice(object):
     def __init__(self, mdsds):
         self.list = [] # list of DataServer instances
diff --git a/nfs4.1/fs.py b/nfs4.1/fs.py
index 6ef283b..8fc49ef 100644
--- a/nfs4.1/fs.py
+++ b/nfs4.1/fs.py
@@ -1567,12 +1567,7 @@ class FilelayoutVolWrapper(object):
         self._pos = 0
 
     def read(self, count):
-        # STUB stateid0 is illegal to a ds
-        ops = [op.putfh(self._fh),
-               op.read(nfs4lib.state00, self._pos, count)]
-        # There are all sorts of error handling issues here
-        res = self._ds.execute(ops)
-        data = res.resarray[-1].data
+        data = self._ds.read(self._fh, self._pos, count)
         self._pos += len(data)
         return data
 
@@ -1580,25 +1575,14 @@ class FilelayoutVolWrapper(object):
         self._pos = offset
 
     def write(self, data):
-        ops = [op.putfh(self._fh),
-               op.write(nfs4lib.state00, self._pos, FILE_SYNC4, data)]
-        # There are all sorts of error handling issues here
-        res = self._ds.execute(ops)
+        self._ds.write(self._fh, self._pos, data)
         self._pos += len(data)
-        return
 
     def truncate(self, size):
-        ops = [op.putfh(self._fh),
-               op.setattr(nfs4lib.state00, {FATTR4_SIZE: size})]
-        res = self._ds.execute(ops)
-        return
+        self._ds.truncate(self._fh, size)
 
     def get_size(self):
-        ops = [op.putfh(self._fh),
-               op.getattr(1L << FATTR4_SIZE)]
-        res = self._ds.execute(ops)
-        attrdict = res.resarray[-1].obj_attributes
-        return attrdict.get(FATTR4_SIZE, 0)
+        return self._ds.get_size(self._fh)
 
 ################################################
 
-- 
1.8.5.2 (Apple Git-48)

