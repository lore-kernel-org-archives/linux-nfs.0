Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f173.google.com ([209.85.213.173]:42406 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751658AbaFEN4A (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Jun 2014 09:56:00 -0400
Received: by mail-ig0-f173.google.com with SMTP id hn18so7580261igb.6
        for <linux-nfs@vger.kernel.org>; Thu, 05 Jun 2014 06:55:59 -0700 (PDT)
From: Weston Andros Adamson <dros@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH pynfs v2 12/16] dataserver: separate generic and 4.1 code
Date: Thu,  5 Jun 2014 09:55:40 -0400
Message-Id: <1401976544-36374-13-git-send-email-dros@primarydata.com>
In-Reply-To: <1401976544-36374-1-git-send-email-dros@primarydata.com>
References: <1401976544-36374-1-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
---
 nfs4.1/dataserver.py | 102 ++++++++++++++++++++++++++++-----------------------
 1 file changed, 57 insertions(+), 45 deletions(-)

diff --git a/nfs4.1/dataserver.py b/nfs4.1/dataserver.py
index d092cf7..5c604dc 100644
--- a/nfs4.1/dataserver.py
+++ b/nfs4.1/dataserver.py
@@ -15,7 +15,7 @@ log = logging.getLogger("Dataserver Manager")
 
 op4 = nfs_ops.NFS4ops()
 
-class DataServer41(object):
+class DataServer(object):
     def __init__(self, server, port, path, flavor=rpc.AUTH_SYS, active=True, mdsds=True, multipath_servers=None, summary=None):
         self.mdsds = mdsds
         self.server = server
@@ -43,29 +43,47 @@ class DataServer41(object):
         self.active = True
         if not self.mdsds:
             self.connect()
+            self.make_root()
 
     def down(self):
+        self.disconnect()
         self.active = False
 
+    def reset(self):
+        self.down()
+        self.up()
+
+    def get_netaddr4(self):
+        # STUB server multipathing not supported yet
+        uaddr = '.'.join([self.server,
+                          str(self.port >> 8),
+                          str(self.port & 0xff)])
+        return type4.netaddr4(self.proto, uaddr)
+
+    def get_multipath_netaddr4s(self):
+        netaddr4s = []
+        for addr in self.multipath_servers:
+            server, port = addr
+            uaddr = '.'.join([server,
+                            str(port >> 8),
+                            str(port & 0xff)])
+            proto = "tcp"
+            if server.find(':') >= 0:
+                proto = "tcp6"
+
+            netaddr4s.append(type4.netaddr4(proto, uaddr))
+        return netaddr4s
+
+    def fh_to_name(self, mds_fh):
+        return hashlib.sha1("%r" % mds_fh).hexdigest()
+
     def connect(self):
-        # only support root with AUTH_SYS for now
-        s1 = rpc.security.instance(rpc.AUTH_SYS)
-        self.cred1 = s1.init_cred(uid=0, gid=0)
-        self.c1 = nfs4client.NFS4Client(self.server, self.port,
-                                        summary=self.summary)
-        self.c1.set_cred(self.cred1)
-        self.c1.null()
-        c = self.c1.new_client("DS.init_%s" % self.server)
-        # This is a hack to ensure MDS/DS communication path is at least
-        # as wide as the client/MDS channel (at least for linux client)
-        fore_attrs = type4.channel_attrs4(0, 16384, 16384, 2868, 8, 8, [])
-        self.sess = c.create_session(fore_attrs=fore_attrs)
-        sess.compound([op.reclaim_complete(FALSE)])
-        self.make_root()
+        raise NotImplemented
 
     def disconnect(self):
         pass
 
+class DataServer41(DataServer):
     def _execute(self, ops, exceptions=[], delay=5, maxretries=3):
         """ execute the NFS call
         If an error code is specified in the exceptions it means that the
@@ -86,36 +104,29 @@ class DataServer41(object):
                     log.error("Too many retries with DS %s" % self.server)
                     raise Exception("Dataserver communication retry error")
             elif res.status in state_errors:
-                self.disconnect()
-                self.connect()
+                self.reset()
             else:
                 log.error("Unhandled status %s from DS %s" %
                           (nfsstat4[res.status], self.server))
                 raise Exception("Dataserver communication error")
 
-    def get_netaddr4(self):
-        # STUB server multipathing not supported yet
-        uaddr = '.'.join([self.server,
-                          str(self.port >> 8),
-                          str(self.port & 0xff)])
-        return type4.netaddr4(self.proto, uaddr)
-
-    def get_multipath_netaddr4s(self):
-        netaddr4s = []
-        for addr in self.multipath_servers:
-            server, port = addr
-            uaddr = '.'.join([server,
-                            str(port >> 8),
-                            str(port & 0xff)])
-            proto = "tcp"
-            if server.find(':') >= 0:
-                proto = "tcp6"
-
-            netaddr4s.append(type4.netaddr4(proto, uaddr))
-        return netaddr4s
-
+    def connect(self):
+        # only support root with AUTH_SYS for now
+        s1 = rpc.security.instance(rpc.AUTH_SYS)
+        self.cred1 = s1.init_cred(uid=0, gid=0)
+        self.c1 = nfs4client.NFS4Client(self.server, self.port,
+                                        summary=self.summary)
+        self.c1.set_cred(self.cred1)
+        self.c1.null()
+        c = self.c1.new_client("DS.init_%s" % self.server)
+        # This is a hack to ensure MDS/DS communication path is at least
+        # as wide as the client/MDS channel (at least for linux client)
+        fore_attrs = type4.channel_attrs4(0, 16384, 16384, 2868, 8, 8, [])
+        self.sess = c.create_session(fore_attrs=fore_attrs)
+        self.sess.compound([op4.reclaim_complete(const4.FALSE)])
 
-    def make_root(self, attrs={const4.FATTR4_MODE:0777}):
+    def make_root(self):
+        attrs = {const4.FATTR4_MODE:0777}
         existing_path = []
         kind = type4.createtype4(const4.NF4DIR)
         for comp in self.path:
@@ -134,12 +145,13 @@ class DataServer41(object):
             raise RuntimeError
         # XXX clean DS directory
 
-    def fh_to_name(self, mds_fh):
-        return hashlib.sha1("%r" % mds_fh).hexdigest()
-
-    def open_file(self, mds_fh, seqid=0,
-                  access=const4.OPEN4_SHARE_ACCESS_BOTH, deny=const4.OPEN4_SHARE_DENY_NONE,
-                  attrs={const4.FATTR4_MODE: 0777}, owner = "mds", mode=const4.GUARDED4):
+    def open_file(self, mds_fh):
+        seqid=0
+        access = const4.OPEN4_SHARE_ACCESS_BOTH
+        deny = const4.OPEN4_SHARE_DENY_NONE
+        attrs = {const4.FATTR4_MODE: 0777}
+        owner = "mds"
+        mode = const4.GUARDED4
         verifier = self.sess.c.verifier
         openflag = type4.openflag4(const4.OPEN4_CREATE, type4.createhow4(mode, attrs, verifier))
         name = self.fh_to_name(mds_fh)
-- 
1.8.5.2 (Apple Git-48)

