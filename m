Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:53224 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754272Ab1CBGfd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Mar 2011 01:35:33 -0500
Message-ID: <4D6DE55F.6040205@cn.fujitsu.com>
Date: Wed, 02 Mar 2011 14:36:15 +0800
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: NFS <linux-nfs@vger.kernel.org>
Subject: [PATCH 15/17] CLNT: test lock before RECLAIM_COMPLETE
References: <4D6DE26C.3010103@cn.fujitsu.com>
In-Reply-To: <4D6DE26C.3010103@cn.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
---
 nfs4.1/server41tests/st_reclaim_complete.py |   26 ++++++++++++++++++++++++++
 1 files changed, 26 insertions(+), 0 deletions(-)

diff --git a/nfs4.1/server41tests/st_reclaim_complete.py b/nfs4.1/server41tests/st_reclaim_complete.py
index 45ac9ad..a94f2ad 100644
--- a/nfs4.1/server41tests/st_reclaim_complete.py
+++ b/nfs4.1/server41tests/st_reclaim_complete.py
@@ -50,3 +50,29 @@ def testReclaimAfterRECC(t, env):
 
     res = sess.compound([op.putfh(cfh), op.lock(READ_LT, TRUE, 0, 1, lowner)])
     check(res, NFS4ERR_NO_GRACE)
+
+def testLockBeforeRECC(t, env):
+    """After a client establishes a new client ID, if non-reclaim
+       locking operations are done before the RECLAIM_COMPLETE,
+       error NFS4ERR_GRACE will be returned. rfc5661 18.51.3
+
+    FLAGS: all
+    CODE: RECC3
+    """
+    name = env.testname(t)
+    c = env.c1.new_client(name)
+    sess = c.create_session()
+
+    fname = "owner_%s" % name
+    path = sess.c.homedir + [name]
+    res = create_file(sess, fname, path, access=OPEN4_SHARE_ACCESS_BOTH)
+    check(res)
+
+    oseqid = res.resarray[2].stateid
+    cfh = res.resarray[3].object
+    owner = open_owner4(0, "My Open Owner")
+    otlowner = open_to_lock_owner4(0, oseqid, 0, owner)
+    lowner = locker4(TRUE, otlowner)
+
+    res = sess.compound([op.putfh(cfh), op.lock(READ_LT, FALSE, 0, 1, lowner)])
+    check(res, NFS4ERR_NO_GRACE)
-- 
1.7.4.1



