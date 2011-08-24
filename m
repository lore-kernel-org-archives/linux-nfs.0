Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:59787 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1755977Ab1HXIt4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Aug 2011 04:49:56 -0400
Message-ID: <4E54BC22.6050700@cn.fujitsu.com>
Date: Wed, 24 Aug 2011 16:53:54 +0800
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
To: "J. Bruce Fields" <bfields@fieldses.org>, NFS <linux-nfs@vger.kernel.org>
Subject: [PATCH 2/4 v4] 4.1 CLNT: test reclaims after RECLAIM_COMPLETE
References: <4E4C7679.7000108@cn.fujitsu.com>
In-Reply-To: <4E4C7679.7000108@cn.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
---
 nfs4.1/server41tests/st_reclaim_complete.py |   29 ++++++++++++++++++++++++++-
 1 files changed, 28 insertions(+), 1 deletions(-)

diff --git a/nfs4.1/server41tests/st_reclaim_complete.py b/nfs4.1/server41tests/st_reclaim_complete.py
index bc63ed8..108e7b6 100644
--- a/nfs4.1/server41tests/st_reclaim_complete.py
+++ b/nfs4.1/server41tests/st_reclaim_complete.py
@@ -1,6 +1,6 @@
 from st_create_session import create_session
 from nfs4_const import *
-from environment import check, fail
+from environment import check, fail, open_file, create_confirm
 import nfs4_ops as op
 import nfs4lib
 
@@ -18,3 +18,30 @@ def testSupported(t, env):
 
     res = sess.compound([op.reclaim_complete(FALSE)])
     check(res)
+
+def testReclaimAfterRECC(t, env):
+    """If client does subsequent reclaims of locking state after
+       RECLAIM_COMPLETE is done, server will return NFS4ERR_NO_GRACE.
+       rfc5661 18.51.3
+
+    FLAGS: reclaim_complete all
+    CODE: RECC2
+    """
+    name = env.testname(t)
+    c = env.c1.new_client(name)
+    sess = c.create_session()
+
+    res = sess.compound([op.reclaim_complete(FALSE)])
+    check(res)
+
+    owner = "owner_%s" % name
+    path = sess.c.homedir + [name]
+    fh, stateid = create_confirm(sess, owner)
+
+    # Try to reclaims a file which is noexist after RECLAIM_COMPLETE
+    res = open_file(sess, owner, path=fh, claim_type=CLAIM_PREVIOUS,
+                    access=OPEN4_SHARE_ACCESS_BOTH,
+                    deny=OPEN4_SHARE_DENY_NONE,
+                    deleg_type=OPEN_DELEGATE_NONE)
+
+    check(res, NFS4ERR_NO_GRACE, warnlist = [NFS4ERR_EXIST | NFS4ERR_RECLAIM_BAD])
-- 
1.7.6


