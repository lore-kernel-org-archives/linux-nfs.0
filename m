Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:63758 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752005Ab1C1I5y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Mar 2011 04:57:54 -0400
Message-ID: <4D904DD9.8080909@cn.fujitsu.com>
Date: Mon, 28 Mar 2011 16:59:05 +0800
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: NFS <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 2/5] CLNT: add a simple test about RECLAIM_COMPLETE
References: <4D6DE26C.3010103@cn.fujitsu.com> <4D904BEB.1060101@cn.fujitsu.com>
In-Reply-To: <4D904BEB.1060101@cn.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
---
 nfs4.1/server41tests/__init__.py            |    1 +
 nfs4.1/server41tests/st_reclaim_complete.py |   22 ++++++++++++++++++++++
 2 files changed, 23 insertions(+), 0 deletions(-)
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
index 0000000..5e3174c
--- /dev/null
+++ b/nfs4.1/server41tests/st_reclaim_complete.py
@@ -0,0 +1,22 @@
+from st_create_session import create_session
+from nfs4_const import *
+from environment import check, fail, use_obj, create_file
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
+    sess.destroy()
-- 
1.7.4.1



