Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:52876 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754783Ab1HRCRH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 17 Aug 2011 22:17:07 -0400
Message-ID: <4E4C771B.2030405@cn.fujitsu.com>
Date: Thu, 18 Aug 2011 10:21:15 +0800
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
To: "J. Bruce Fields" <bfields@fieldses.org>, NFS <linux-nfs@vger.kernel.org>
Subject: [PATCH 3/4 v3] 4.1 CLNT: test open before RECLAIM_COMPLETE
References: <4E4C7679.7000108@cn.fujitsu.com>
In-Reply-To: <4E4C7679.7000108@cn.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
---
 nfs4.1/server41tests/st_reclaim_complete.py |   21 ++++++++++++++++++++-
 1 files changed, 20 insertions(+), 1 deletions(-)

diff --git a/nfs4.1/server41tests/st_reclaim_complete.py b/nfs4.1/server41tests/st_reclaim_complete.py
index 3940b7b..921d537 100644
--- a/nfs4.1/server41tests/st_reclaim_complete.py
+++ b/nfs4.1/server41tests/st_reclaim_complete.py
@@ -1,6 +1,6 @@
 from st_create_session import create_session
 from nfs4_const import *
-from environment import check, fail, open_file, create_confirm
+from environment import check, fail, open_file, create_file, create_confirm
 import nfs4_ops as op
 import nfs4lib
 
@@ -47,3 +47,22 @@ def testReclaimAfterRECC(t, env):
                     deleg_type=OPEN_DELEGATE_NONE)
 
     check(res,NFS4ERR_NO_GRACE)
+
+def testOpenBeforeRECC(t, env):
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
+
+    # Try to open file before RECLAIM_COMPLETE
+    res = create_file(sess, fname, path, access=OPEN4_SHARE_ACCESS_BOTH)
+    check(res,NFS4ERR_GRACE)
-- 
1.7.6


