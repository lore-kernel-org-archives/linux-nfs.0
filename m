Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:65525 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751801Ab1CBGfD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Mar 2011 01:35:03 -0500
Message-ID: <4D6DE53F.4050904@cn.fujitsu.com>
Date: Wed, 02 Mar 2011 14:35:43 +0800
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: NFS <linux-nfs@vger.kernel.org>
Subject: [PATCH 14/17] CLNT: test reclaim after RECLAIM_COMPLETE
References: <4D6DE26C.3010103@cn.fujitsu.com>
In-Reply-To: <4D6DE26C.3010103@cn.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
---
 nfs4.1/server41tests/st_reclaim_complete.py |   31 +++++++++++++++++++++++++++
 1 files changed, 31 insertions(+), 0 deletions(-)

diff --git a/nfs4.1/server41tests/st_reclaim_complete.py b/nfs4.1/server41tests/st_reclaim_complete.py
index 1d2d815..45ac9ad 100644
--- a/nfs4.1/server41tests/st_reclaim_complete.py
+++ b/nfs4.1/server41tests/st_reclaim_complete.py
@@ -1,6 +1,7 @@
 from st_create_session import create_session
 from nfs4_const import *
 from environment import check, fail, use_obj, create_file
+from nfs4_type import open_owner4, locker4, open_to_lock_owner4
 import nfs4_ops as op
 import nfs4lib
 
@@ -19,3 +20,33 @@ def testSupported(t, env):
 
     res = sess.compound([op.putrootfh(), op.reclaim_complete(TRUE)])
     check(res)
+
+def testReclaimAfterRECC(t, env):
+    """If client does subsequent reclaims of locking state after
+       RECLAIM_COMPLETE is done, server will return NFS4ERR_NO_GRACE.
+       rfc5661 18.51.3
+
+    FLAGS: all
+    CODE: RECC2
+    """
+    name = env.testname(t)
+    c = env.c1.new_client(name)
+    sess = c.create_session()
+
+    # RECLAIM_COMPLETE
+    res = sess.compound([op.reclaim_complete(FALSE)])
+    check(res)
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
+    res = sess.compound([op.putfh(cfh), op.lock(READ_LT, TRUE, 0, 1, lowner)])
+    check(res, NFS4ERR_NO_GRACE)
-- 
1.7.4.1



