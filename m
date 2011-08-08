Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:59039 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751310Ab1HHWkI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Aug 2011 18:40:08 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Fred Isaman <iisaman@netapp.com>
Cc: linux-nfs@vger.kernel.org, "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 1/2] read+write+readwrite open test
Date: Mon,  8 Aug 2011 18:40:00 -0400
Message-Id: <1312843201-6653-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1312843201-6653-1-git-send-email-bfields@redhat.com>
References: <1312843201-6653-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

---
 nfs4.0/lib/nfs4/servertests/st_open.py |   26 ++++++++++++++++++++++++++
 1 files changed, 26 insertions(+), 0 deletions(-)

diff --git a/nfs4.0/lib/nfs4/servertests/st_open.py b/nfs4.0/lib/nfs4/servertests/st_open.py
index 1e5ec70..88134f1 100644
--- a/nfs4.0/lib/nfs4/servertests/st_open.py
+++ b/nfs4.0/lib/nfs4/servertests/st_open.py
@@ -566,4 +566,30 @@ def testDenyWrite4(t, env):
         t.fail("READ returned %s, expected 'data'" % repr(res2.data))
 
 
+def testUpgrades(t, env):
+    """OPEN read, write, and read-write, then close
+
+    Inspired by a linux nfsd regression: the final close closes all the
+    opens, and nfsd did that right, but some misaccounting somewhere
+    leaked a file reference with the result that the filesystem would be
+    unmountable after running this test.
+
+    FLAGS: open all
+    DEPEND: MKFILE
+    CODE: OPEN29
+    """
+    c = env.c1
+    c.init_connection()
+    file = c.homedir + [t.code]
+    c.create_confirm('owner1', file, access=OPEN4_SHARE_ACCESS_READ,
+                                     deny=OPEN4_SHARE_DENY_NONE)
+    c.open_file('owner1', file, access=OPEN4_SHARE_ACCESS_WRITE,
+                                     deny=OPEN4_SHARE_DENY_NONE)
+    res = c.open_file('owner1', file, access=OPEN4_SHARE_ACCESS_BOTH,
+                                     deny=OPEN4_SHARE_DENY_NONE)
+    fh = res.resarray[-1].switch.switch.object
+    stateid = res.resarray[-2].switch.switch.stateid
+    c.close_file(t.code, fh, stateid)
+
+
 #FRED - dot test
-- 
1.7.4.1

