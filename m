Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f174.google.com ([209.85.223.174]:45717 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752067AbaFDVCr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Jun 2014 17:02:47 -0400
Received: by mail-ie0-f174.google.com with SMTP id lx4so68895iec.19
        for <linux-nfs@vger.kernel.org>; Wed, 04 Jun 2014 14:02:46 -0700 (PDT)
From: Weston Andros Adamson <dros@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH pynfs 17/17] nfs3clnt: reconnect when sending on inactive pipe
Date: Wed,  4 Jun 2014 17:02:06 -0400
Message-Id: <1401915726-29092-19-git-send-email-dros@primarydata.com>
In-Reply-To: <1401915726-29092-1-git-send-email-dros@primarydata.com>
References: <1401915726-29092-1-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
---
 nfs4.1/nfs3client.py | 45 +++++++++++++++++++++++++--------------------
 1 file changed, 25 insertions(+), 20 deletions(-)

diff --git a/nfs4.1/nfs3client.py b/nfs4.1/nfs3client.py
index 79a6f0e..176765c 100644
--- a/nfs4.1/nfs3client.py
+++ b/nfs4.1/nfs3client.py
@@ -30,14 +30,19 @@ class PORTMAPClient(rpc.Client):
     def __init__(self, host='localhost', port=PMAP_PORT):
         rpc.Client.__init__(self, PMAP_PROG, PMAP_VERS)
         self.server_address = (host, port)
-        self.c1 = self.connect(self.server_address)
+        self._pipe = None
+
+    def get_pipe(self):
+        if not self._pipe or not self._pipe.is_active():
+           self._pipe = self.connect(self.server_address)
+        return self._pipe
 
     def proc_async(self, procnum, procarg, credinfo=None, pipe=None,
                    checks=True, packer=PORTMAPPacker):
         if credinfo is None:
             credinfo = self.default_cred
         if pipe is None:
-            pipe = self.c1
+            pipe = self.get_pipe()
         p = packer(check_enum=checks, check_array=checks)
         arg_packer = getattr(p, 'pack_%s' % procarg.__class__.__name__)
         arg_packer(procarg)
@@ -51,7 +56,7 @@ class PORTMAPClient(rpc.Client):
 
     def listen(self, xid, restypename, pipe=None, timeout=10.0):
         if pipe is None:
-            pipe = self.c1
+            pipe = self.get_pipe()
         header, data = pipe.listen(xid, timeout)
         if data:
             p = PORTMAPUnpacker(data)
@@ -69,14 +74,19 @@ class Mnt3Client(rpc.Client):
     def __init__(self, host='localhost', port=None):
         rpc.Client.__init__(self, MOUNT_PROGRAM, MOUNT_V3)
         self.server_address = (host, port)
-        self.c1 = self.connect(self.server_address)
+        self._pipe = None
+
+    def get_pipe(self):
+        if not self._pipe or not self._pipe.is_active():
+            self._pipe = self.connect(self.server_address)
+        return self._pipe
 
     def proc_async(self, procnum, procarg, credinfo=None, pipe=None,
                    checks=True, packer=MNT3Packer):
         if credinfo is None:
             credinfo = self.default_cred
         if pipe is None:
-            pipe = self.c1
+            pipe = self.get_pipe()
         p = packer(check_enum=checks, check_array=checks)
         arg_packer = getattr(p, 'pack_%s' % procarg.__class__.__name__)
         arg_packer(procarg)
@@ -90,7 +100,7 @@ class Mnt3Client(rpc.Client):
 
     def listen(self, xid, restypename, pipe=None, timeout=10.0):
         if pipe is None:
-            pipe = self.c1
+            pipe = self.get_pipe()
         header, data = pipe.listen(xid, timeout)
         if data:
             p = MNT3Unpacker(data)
@@ -110,15 +120,6 @@ class Mnt3Client(rpc.Client):
 class NFS3Client(rpc.Client):
     def __init__(self, host='localhost', port=None, ctrl_proc=16, summary=None):
         rpc.Client.__init__(self, 100003, 3)
-        #self.prog = 0x40000000
-        #self.versions = [1] # List of supported versions of prog
-
-        #self.minorversion = minorversion
-        #self.minor_versions = [minorversion]
-        #self.tag = "default tag"
-        #self.impl_id = nfs_impl_id4("citi.umich.edu", "pynfs X.X",
-        #                            nfs4lib.get_nfstime())
-
         self.portmap = PORTMAPClient(host=host)
         self.mntport = self.portmap.get_port(MOUNT_PROGRAM, MOUNT_V3)
         if not port:
@@ -128,17 +129,21 @@ class NFS3Client(rpc.Client):
 
         self.verifier = struct.pack('>d', time.time())
         self.server_address = (host, self.port)
-        self.c1 = self.connect(self.server_address)
-        #self.sessions = {} # XXX Really, this should be per server
         self.ctrl_proc = ctrl_proc
         self.summary = summary
+        self._pipe = None
         self.mntclnt = Mnt3Client(host=host, port=self.mntport)
 
+    def get_pipe(self):
+        if not self._pipe or not self._pipe.is_active():
+            self._pipe = self.connect(self.server_address)
+        return self._pipe
+
     def set_cred(self, credinfo):
         self.default_cred = credinfo
 
     def null_async(self, data=""):
-        return self.send_call(self.c1, 0, data)
+        return self.send_call(self.get_pipe(), 0, data)
 
     def null(self, *args, **kwargs):
         xid = self.null_async(*args, **kwargs)
@@ -149,7 +154,7 @@ class NFS3Client(rpc.Client):
         if credinfo is None:
             credinfo = self.default_cred
         if pipe is None:
-            pipe = self.c1
+            pipe = self.get_pipe()
         p = packer(check_enum=checks, check_array=checks)
         arg_packer = getattr(p, 'pack_%s' % procarg.__class__.__name__)
         arg_packer(procarg)
@@ -167,7 +172,7 @@ class NFS3Client(rpc.Client):
 
     def listen(self, xid, procarg=None, pipe=None, timeout=10.0):
         if pipe is None:
-            pipe = self.c1
+            pipe = self.get_pipe()
         header, data = pipe.listen(xid, timeout)
         if data:
             p = NFS3Unpacker(data)
-- 
1.8.5.2 (Apple Git-48)

