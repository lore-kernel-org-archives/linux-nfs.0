Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:54820 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S2388391AbeGXIjP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 24 Jul 2018 04:39:15 -0400
From: jiyin@redhat.com
To: bfields@redhat.com
Cc: linux-nfs@vger.kernel.org, "Jianhong.Yin" <yin-jianhong@163.com>
Subject: [PATCH 09/24] pynfs: python3 support plan: dict.has_key -> key in dict
Date: Tue, 24 Jul 2018 15:33:27 +0800
Message-Id: <20180724073342.5738-9-jiyin@redhat.com>
In-Reply-To: <20180724073342.5738-1-jiyin@redhat.com>
References: <20180724073342.5738-1-jiyin@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "Jianhong.Yin" <yin-jianhong@163.com>

and rename DirList.has_key() to DirList.has_name()
 to avoid confuse

Signed-off-by: Jianhong Yin <yin-jianhong@163.com>
---
 nfs4.0/lib/rpc/rpc.py |  2 +-
 nfs4.0/nfs4lib.py     |  2 +-
 nfs4.0/nfs4server.py  |  4 ++--
 nfs4.0/nfs4state.py   | 10 +++++-----
 4 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/nfs4.0/lib/rpc/rpc.py b/nfs4.0/lib/rpc/rpc.py
index d9c1401..be14658 100644
--- a/nfs4.0/lib/rpc/rpc.py
+++ b/nfs4.0/lib/rpc/rpc.py
@@ -514,7 +514,7 @@ class RPCServer(Server):
                                  'sys':  AUTH_SYS,
                                  'gss':  RPCSEC_GSS,
                                 }.iteritems():
-            if supported.has_key(secname):
+            if secname in supported:
                 self.security[sectype] = supported[secname]()
 
         self.readbufs = {}
diff --git a/nfs4.0/nfs4lib.py b/nfs4.0/nfs4lib.py
index 5c9e853..dddbf91 100644
--- a/nfs4.0/nfs4lib.py
+++ b/nfs4.0/nfs4lib.py
@@ -232,7 +232,7 @@ class CBServer(rpc.RPCServer):
         results = []
         ok = NFS4_OK
         for op in cmp4args.argarray:
-            if self.opcodes.has_key(op.argop):
+            if op.argop in self.opcodes:
                 ok, result = self.opcodes[op.argop](op, cbid)
             else:
                 ok = NFS4ERR_OP_ILLEGAL
diff --git a/nfs4.0/nfs4server.py b/nfs4.0/nfs4server.py
index 163bd60..18b0aad 100755
--- a/nfs4.0/nfs4server.py
+++ b/nfs4.0/nfs4server.py
@@ -504,7 +504,7 @@ class NFS4Server(rpc.RPCServer):
                         if op.opopen.openhow.how.mode == GUARDED4:
                             raise NFS4Error(NFS4ERR_EXIST)
                         # with an existing file ignore attrs except size=0
-                        if attrs.has_key(FATTR4_SIZE) and attrs[FATTR4_SIZE]==0:
+                        if FATTR4_SIZE in attrs and attrs[FATTR4_SIZE]==0:
                             attrset = existing.set_attributes(attrdict={FATTR4_SIZE:0})
                         # Now break out and use existing as is
                     else:
@@ -593,7 +593,7 @@ class NFS4Server(rpc.RPCServer):
     def op_putfh(self, op):
         print("  FILEHANDLE '%s'" % repr(op.opputfh.object))
         # check access!
-        if not self.fhcache.has_key(op.opputfh.object):
+        if not op.opputfh.object in self.fhcache:
             return simple_error(NFS4ERR_BADHANDLE)
         self.curr_fh = self.fhcache[op.opputfh.object] 
         return simple_error(NFS4_OK)
diff --git a/nfs4.0/nfs4state.py b/nfs4.0/nfs4state.py
index cd36edd..8aca178 100755
--- a/nfs4.0/nfs4state.py
+++ b/nfs4.0/nfs4state.py
@@ -1014,7 +1014,7 @@ class VirtualHandle(NFSFileHandle):
         # Must make sure that if it fails, nothing is changed
         if self.fattr4_type != NF4DIR:
             raise "create called on non-directory (%s)" % self.ref
-        if self.dirent.has_key(name):
+        if self.dirent.has_name(name):
             raise "attempted to create already existing file."
         fh = VirtualHandle(name, type, self)
         if FATTR4_SIZE in attrs and type.type != NF4REG:
@@ -1116,7 +1116,7 @@ class VirtualHandle(NFSFileHandle):
         mapping = nfs4lib.list2bitmap
         ret_list = []
         for attr in attrdict.keys():
-            if not self.supported.has_key(attr):
+            if not attr in self.supported:
                 raise NFS4Error(NFS4ERR_ATTRNOTSUPP, attrs=mapping(ret_list))
             if 'w' not in self.supported[attr]:
                 raise NFS4Error(NFS4ERR_INVAL, attrs=mapping(ret_list))
@@ -1182,7 +1182,7 @@ class VirtualHandle(NFSFileHandle):
         # Make sure any error is recorded in fattr4_rdattr_error
         ret_dict = {}
         for attr in attrlist:
-            if not self.supported.has_key(attr):
+            if not attr in self.supported:
                 # Ignore unknown attributes
                 continue
             if 'r' not in self.supported[attr]:
@@ -1419,7 +1419,7 @@ class HardHandle(NFSFileHandle):
         self.oldfiles = self.dirent.keys()
         for i in os.listdir(self.file):
             fullfile = os.path.join(self.file, i)
-            if not self.dirent.has_key(i):
+            if not self.dirent.has_name(i):
                 self.dirent[i] = HardHandle(i, self, fullfile)
             else:
                 self.oldfiles.remove(i)
@@ -1520,7 +1520,7 @@ class DirList:
         else:
             return self.list[i:]
 
-    def has_key(self, name):
+    def has_name(self, name):
         for x in self.list:
             if x.name == name:
                 return True
-- 
2.17.1

