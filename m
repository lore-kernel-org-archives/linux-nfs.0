Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cn.fujitsu.com ([222.73.24.84]:51494 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752923Ab1JTIwT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 Oct 2011 04:52:19 -0400
Message-ID: <4E9FE273.80500@cn.fujitsu.com>
Date: Thu, 20 Oct 2011 16:57:23 +0800
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: NFS <linux-nfs@vger.kernel.org>
Subject: [PATCH] CLNT: add some tests for DESTROY_CLIENTID
Content-Type: text/plain; charset=ISO-2022-JP
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Some tests for DESTROY_CLIENTID at pynfs41.

Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
---
 nfs4.1/server41tests/__init__.py            |    1 +
 nfs4.1/server41tests/st_destroy_clientid.py |   85 +++++++++++++++++++++++++++
 2 files changed, 86 insertions(+), 0 deletions(-)
 create mode 100644 nfs4.1/server41tests/st_destroy_clientid.py

diff --git a/nfs4.1/server41tests/__init__.py b/nfs4.1/server41tests/__init__.py
index 1cc2048..eb92538 100644
--- a/nfs4.1/server41tests/__init__.py
+++ b/nfs4.1/server41tests/__init__.py
@@ -2,6 +2,7 @@ __all__ = ["st_exchange_id.py", # draft 21
            "st_compound.py",
            "st_create_session.py",
            "st_destroy_session.py",
+           "st_destroy_clientid.py",
            "st_reclaim_complete.py",
            "st_secinfo_no_name.py",
            "st_secinfo.py",
diff --git a/nfs4.1/server41tests/st_destroy_clientid.py b/nfs4.1/server41tests/st_destroy_clientid.py
new file mode 100644
index 0000000..c2ea0c7
--- /dev/null
+++ b/nfs4.1/server41tests/st_destroy_clientid.py
@@ -0,0 +1,85 @@
+from st_create_session import create_session
+from nfs4_const import *
+from environment import check, fail
+import nfs4_ops as op
+import nfs4lib
+
+def testSupported(t, env):
+    """Do a simple DESTROY_CLIENTID
+       destroy an unconfirmed clientid without session
+
+    FLAGS: destroy_clientid all
+    CODE: DESCID1
+    """
+    c = env.c1.new_client(env.testname(t))
+
+    res = env.c1.compound([op.destroy_clientid(c.clientid)])
+    check(res)
+
+def testDestroyBadCIDWS(t, env):
+    """ destroy an clientid which not exist without session
+
+    FLAGS: destroy_clientid all
+    CODE: DESCID2
+    """
+    res = env.c1.compound([op.destroy_clientid(0)])
+    check(res, NFS4ERR_STALE_CLIENTID)
+
+def testDestroyBadCIDIS(t, env):
+    """ destroy an clientid which not exist in session
+
+    FLAGS: destroy_clientid all
+    CODE: DESCID3
+    """
+    c = env.c1.new_client(env.testname(t))
+    sess = c.create_session()
+
+    res = sess.compound([op.destroy_clientid(0)])
+    check(res, NFS4ERR_STALE_CLIENTID)
+
+def testDestroyCIDThisSession(t, env):
+    """ destroy clientid of itself in session
+
+    FLAGS: destroy_clientid all
+    CODE: DESCID4
+    """
+    c = env.c1.new_client(env.testname(t))
+    sess = c.create_session()
+
+    res = sess.compound([op.destroy_clientid(c.clientid)])
+    check(res, NFS4ERR_CLIENTID_BUSY)
+
+def testDestroyCIDInSession(t, env):
+    """ destroy a clientid of other session without session
+
+    FLAGS: destroy_clientid all
+    CODE: DESCID5
+    """
+    c = env.c1.new_client(env.testname(t))
+    sess = c.create_session()
+
+    res = env.c1.compound([op.destroy_clientid(c.clientid)])
+    check(res, NFS4ERR_CLIENTID_BUSY)
+
+def testDestroyCIDNotOnly(t, env):
+    """ destroy a clientid without session with other compound
+
+    FLAGS: destroy_clientid all
+    CODE: DESCID6
+    """
+    res = env.c1.compound([op.destroy_clientid(0), op.reclaim_complete(TRUE)])
+    check(res, NFS4ERR_NOT_ONLY_OP)
+
+def testDestroyCIDTwice(t, env):
+    """ destroy a clientid without session twice
+
+    FLAGS: destroy_clientid all
+    CODE: DESCID7
+    """
+    c = env.c1.new_client(env.testname(t))
+
+    res = env.c1.compound([op.destroy_clientid(c.clientid)])
+    check(res)
+
+    res = env.c1.compound([op.destroy_clientid(c.clientid)])
+    check(res, NFS4ERR_STALE_CLIENTID)
-- 
1.7.6


