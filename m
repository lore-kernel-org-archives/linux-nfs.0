Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-o-1.desy.de ([131.169.56.154]:36766 "EHLO smtp-o-1.desy.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753801AbbKWI1H (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 Nov 2015 03:27:07 -0500
Received: from smtp-map-1.desy.de (smtp-map-1.desy.de [131.169.56.66])
	by smtp-o-1.desy.de (DESY-O-1) with ESMTP id 00D702806DB
	for <linux-nfs@vger.kernel.org>; Mon, 23 Nov 2015 09:27:06 +0100 (CET)
Received: from ZITSWEEP1.win.desy.de (zitsweep1.win.desy.de [131.169.97.95])
	by smtp-map-1.desy.de (DESY_MAP_1) with ESMTP id E86A213E8A
	for <linux-nfs@vger.kernel.org>; Mon, 23 Nov 2015 09:27:04 +0100 (MET)
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Subject: [PATCH] nfs4.0 tests: discover max supported file size
Date: Mon, 23 Nov 2015 09:27:02 +0100
Message-Id: <1448267222-20720-1-git-send-email-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

current implementation amuses, that all servers
support 64-bit file sizes. This is not always true.
Use FATTR4_MAXFILESIZE attribute to discover supported
maximum. Update LOCK6 test to use it.

Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
---
 nfs4.0/nfs4lib.py             | 6 ++++++
 nfs4.0/servertests/st_lock.py | 3 ++-
 2 files changed, 8 insertions(+), 1 deletion(-)

diff --git a/nfs4.0/nfs4lib.py b/nfs4.0/nfs4lib.py
index 5031feb..41870dc 100644
--- a/nfs4.0/nfs4lib.py
+++ b/nfs4.0/nfs4lib.py
@@ -587,6 +587,12 @@ class NFS4Client(rpc.RPCClient, nfs4_ops.NFS4Operations):
         d = self.do_getattrdict([], [FATTR4_LEASE_TIME])
         return d[FATTR4_LEASE_TIME]
 
+    def getMaxFileSize(self):
+        """Get maximum supported file size"""
+        d = self.do_getattrdict([], [FATTR4_MAXFILESIZE])
+        return d[FATTR4_MAXFILESIZE]
+
+
     def create_obj(self, path, type=NF4DIR, attrs={FATTR4_MODE:0755},
                    linkdata="/etc/X11"):
         if __builtins__['type'](path) is str:
diff --git a/nfs4.0/servertests/st_lock.py b/nfs4.0/servertests/st_lock.py
index d54614d..80518f4 100644
--- a/nfs4.0/servertests/st_lock.py
+++ b/nfs4.0/servertests/st_lock.py
@@ -189,8 +189,9 @@ def testLenTooLong(t, env):
     """
     c = env.c1
     c.init_connection()
+    max_size = c.getMaxFileSize();
     fh, stateid = c.create_confirm(t.code)
-    res = c.lock_file(t.code, fh, stateid, 100, 0xfffffffffffffffe)
+    res = c.lock_file(t.code, fh, stateid, 100, max_size)
     check(res, NFS4ERR_INVAL, "LOCK with offset+len overflow")
 
 def testNoFh(t, env):
-- 
2.5.0

