Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:62966 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752002Ab1CBGdJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Mar 2011 01:33:09 -0500
Message-ID: <4D6DE4CE.7050501@cn.fujitsu.com>
Date: Wed, 02 Mar 2011 14:33:50 +0800
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: NFS <linux-nfs@vger.kernel.org>
Subject: [PATCH 11/17] CLNT: DESTROY_SESSION not the fianl operation
References: <4D6DE26C.3010103@cn.fujitsu.com>
In-Reply-To: <4D6DE26C.3010103@cn.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
---
 nfs4.1/server41tests/st_destroy_session.py |   16 ++++++++++++++++
 1 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/nfs4.1/server41tests/st_destroy_session.py b/nfs4.1/server41tests/st_destroy_session.py
index a60daf1..d7be8a1 100644
--- a/nfs4.1/server41tests/st_destroy_session.py
+++ b/nfs4.1/server41tests/st_destroy_session.py
@@ -133,3 +133,19 @@ def testDestroy3(t, env):
     if not recall.happened:
         fail("Did not get callback")
 
+def testDestoryNotFinalOps(t, env):
+    """ If the COMPOUND request starts with SEQUENCE, DESTROY_SESSION
+        MUST be the final operation in the COMPOUND request.
+        rfc5661 18.37.3
+
+    FLAGS: destroy_session
+    CODE: DSESS9004
+    """
+    c = env.c1.new_client(env.testname(t))
+    sess1 = c.create_session()
+
+    sid = sess1.sessionid
+    res = c.c.compound([op.sequence(sid, 1, 2, 3, False),
+                        op.destroy_session(sess1.sessionid),
+                        op.putrootfh()])
+    check(res, NFS4ERR_NOT_ONLY_OP)
-- 
1.7.4.1


