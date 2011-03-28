Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:60033 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753249Ab1C1I6r (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Mar 2011 04:58:47 -0400
Message-ID: <4D904E15.9030401@cn.fujitsu.com>
Date: Mon, 28 Mar 2011 17:00:05 +0800
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: NFS <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 4/5] CLNT: test lock before RECLAIM_COMPLETE
References: <4D6DE26C.3010103@cn.fujitsu.com> <4D904BEB.1060101@cn.fujitsu.com>
In-Reply-To: <4D904BEB.1060101@cn.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
---
 nfs4.1/server41tests/st_reclaim_complete.py |   37 +++++++++++++++++++++++++++
 1 files changed, 37 insertions(+), 0 deletions(-)

diff --git a/nfs4.1/server41tests/st_reclaim_complete.py b/nfs4.1/server41tests/st_reclaim_complete.py
index 4c9fc37..c712d0e 100644
--- a/nfs4.1/server41tests/st_reclaim_complete.py
+++ b/nfs4.1/server41tests/st_reclaim_complete.py
@@ -70,3 +70,40 @@ def testReclaimAfterRECC(t, env):
     res = sess.compound([op.putfh(cfh), op.lock(READ_LT, TRUE, 0, 1, lowner)])
     check(res, NFS4ERR_NO_GRACE)
     sess.destroy()
+
+def testLockBeforeRECC(t, env):
+    """After a client establishes a new client ID, if non-reclaim
+       locking operations are done before the RECLAIM_COMPLETE,
+       error NFS4ERR_GRACE will be returned. rfc5661 18.51.3
+
+    FLAGS: reclaim_complete all
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
+    # Get stateid from OPEN4resok for making a lockowner
+    nres = opt_result(res, OP_OPEN)
+    if nres == None:
+        fail("Can not get OPEN4resok!")
+    oseqid = nres.stateid
+
+    owner = open_owner4(0, "My Open Owner")
+    otlowner = open_to_lock_owner4(0, oseqid, 0, owner)
+    lowner = locker4(TRUE, otlowner)
+
+    # Get filehandle from GETFHresok for locking
+    nres = opt_result(res, OP_GETFH)
+    if nres == None:
+        fail("Can not get GETFHresok!")
+    cfh = nres.object
+
+    res = sess.compound([op.putfh(cfh), op.lock(READ_LT, FALSE, 0, 1, lowner)])
+    check(res, NFS4ERR_NO_GRACE)
+    sess.destroy()
-- 
1.7.4.1



