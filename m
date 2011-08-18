Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:60513 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754424Ab1HRCPn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 17 Aug 2011 22:15:43 -0400
Message-ID: <4E4C76C6.8020901@cn.fujitsu.com>
Date: Thu, 18 Aug 2011 10:19:50 +0800
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
To: "J. Bruce Fields" <bfields@fieldses.org>, NFS <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/4 v3] 4.1 CLNT: add a simple test about RECLAIM_COMPLETE
References: <4E4C7679.7000108@cn.fujitsu.com>
In-Reply-To: <4E4C7679.7000108@cn.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
---
 nfs4.1/server41tests/__init__.py            |    1 +
 nfs4.1/server41tests/st_reclaim_complete.py |   21 +++++++++++++++++++++
 2 files changed, 22 insertions(+), 0 deletions(-)
 create mode 100644 nfs4.1/server41tests/st_reclaim_complete.py

diff --git a/nfs4.1/server41tests/__init__.py b/nfs4.1/server41tests/__init__.py
index 3b4411a..1cc2048 100644
--- a/nfs4.1/server41tests/__init__.py
+++ b/nfs4.1/server41tests/__init__.py
@@ -2,6 +2,7 @@ __all__ = ["st_exchange_id.py", # draft 21
            "st_compound.py",
            "st_create_session.py",
            "st_destroy_session.py",
+           "st_reclaim_complete.py",
            "st_secinfo_no_name.py",
            "st_secinfo.py",
            "st_sequence.py",
diff --git a/nfs4.1/server41tests/st_reclaim_complete.py b/nfs4.1/server41tests/st_reclaim_complete.py
new file mode 100644
index 0000000..a591ef5
--- /dev/null
+++ b/nfs4.1/server41tests/st_reclaim_complete.py
@@ -0,0 +1,21 @@
+from st_create_session import create_session
+from nfs4_const import *
+from environment import check, fail
+import nfs4_ops as op
+import nfs4lib
+
+def testSupported(t, env):
+    """Do a simple RECLAIM_COMPLETE
+
+    FLAGS: reclaim_complete all
+    CODE: RECC1
+    """
+    c = env.c1.new_client(env.testname(t))
+    sess = c.create_session()
+
+    # RECLAIM_COMPLETE
+    res = sess.compound([op.putrootfh(), op.reclaim_complete(TRUE)])
+    check(res)
+
+    res = sess.compound([op.reclaim_complete(FALSE)])
+    check(res)
-- 
1.7.6


