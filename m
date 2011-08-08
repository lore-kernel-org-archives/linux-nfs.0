Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:59041 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752252Ab1HHWkJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Aug 2011 18:40:09 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Fred Isaman <iisaman@netapp.com>
Cc: linux-nfs@vger.kernel.org, "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/2] check another odd linux server case
Date: Mon,  8 Aug 2011 18:40:01 -0400
Message-Id: <1312843201-6653-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1312843201-6653-1-git-send-email-bfields@redhat.com>
References: <1312843201-6653-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

---
 nfs4.0/lib/nfs4/servertests/st_lock.py |   17 +++++++++++++++++
 1 files changed, 17 insertions(+), 0 deletions(-)

diff --git a/nfs4.0/lib/nfs4/servertests/st_lock.py b/nfs4.0/lib/nfs4/servertests/st_lock.py
index 90b93ee..8be25cd 100644
--- a/nfs4.0/lib/nfs4/servertests/st_lock.py
+++ b/nfs4.0/lib/nfs4/servertests/st_lock.py
@@ -846,3 +846,20 @@ def xxtestLockowner2(t, env):
         self.ncl.lock_test(self.fh)
         self.ncl.lock_file(self.fh, self.stateid, error=[NFS4ERR_BAD_STATEID])
 
+def testOpenDowngradeLock(t, env):
+    """OPEN a file RW, then lock R, then downgrade to R, then unlock.
+
+    FLAGS: lock all
+    DEPEND: MKFILE
+    CODE: LOCK23
+    """
+    c = env.c1
+    c.init_connection()
+    fh, oldstateid = c.create_confirm(t.code, access=OPEN4_SHARE_ACCESS_READ,
+                                      deny=OPEN4_SHARE_DENY_NONE)
+    fh, stateid = c.open_confirm(t.code, access=OPEN4_SHARE_ACCESS_BOTH,
+                                   deny=OPEN4_SHARE_DENY_NONE)
+    res = c.lock_file(t.code, fh, stateid);
+    res = c.downgrade_file(t.code, fh, res.lockid,
+                           access=OPEN4_SHARE_ACCESS_READ,
+                           deny=OPEN4_SHARE_DENY_NONE)
-- 
1.7.4.1

