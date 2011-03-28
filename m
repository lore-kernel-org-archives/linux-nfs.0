Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:64973 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753465Ab1C1I7O (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Mar 2011 04:59:14 -0400
Message-ID: <4D904E31.8070506@cn.fujitsu.com>
Date: Mon, 28 Mar 2011 17:00:33 +0800
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: NFS <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 5/5] CLNT: test double RECLAIM_COMPLETE after create session
References: <4D6DE26C.3010103@cn.fujitsu.com> <4D904BEB.1060101@cn.fujitsu.com>
In-Reply-To: <4D904BEB.1060101@cn.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
---
 nfs4.1/server41tests/st_reclaim_complete.py |   20 ++++++++++++++++++++
 1 files changed, 20 insertions(+), 0 deletions(-)

diff --git a/nfs4.1/server41tests/st_reclaim_complete.py b/nfs4.1/server41tests/st_reclaim_complete.py
index c712d0e..ad2178c 100644
--- a/nfs4.1/server41tests/st_reclaim_complete.py
+++ b/nfs4.1/server41tests/st_reclaim_complete.py
@@ -107,3 +107,23 @@ def testLockBeforeRECC(t, env):
     res = sess.compound([op.putfh(cfh), op.lock(READ_LT, FALSE, 0, 1, lowner)])
     check(res, NFS4ERR_NO_GRACE)
     sess.destroy()
+
+def testDoubleRECC(t, env):
+    """If RECLAIM_COMPLETE is done a second time, error
+       NFS4ERR_COMPLETE_ALREADY will be returned. rfc5661 18.51.4
+
+    FLAGS: reclaim_complete all
+    CODE: RECC4
+    """
+    name = env.testname(t)
+    c = env.c1.new_client(name)
+    sess = c.create_session()
+
+    # RECLAIM_COMPLETE
+    res = sess.compound([op.reclaim_complete(FALSE)])
+    check(res)
+
+    # RECLAIM_COMPLETE again
+    res = sess.compound([op.reclaim_complete(FALSE)])
+    check(res, NFS4ERR_COMPLETE_ALREADY)
+    sess.destroy()
-- 
1.7.4.1



