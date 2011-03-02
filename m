Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:50241 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751035Ab1CBGds (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Mar 2011 01:33:48 -0500
Message-ID: <4D6DE4F6.60907@cn.fujitsu.com>
Date: Wed, 02 Mar 2011 14:34:30 +0800
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: NFS <linux-nfs@vger.kernel.org>
Subject: [PATCH 12/17] CLNT: test DESTROY_SESSION not the sole operation
References: <4D6DE26C.3010103@cn.fujitsu.com>
In-Reply-To: <4D6DE26C.3010103@cn.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
---
 nfs4.1/server41tests/st_destroy_session.py |   18 ++++++++++++++++++
 1 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/nfs4.1/server41tests/st_destroy_session.py b/nfs4.1/server41tests/st_destroy_session.py
index d7be8a1..1feb671 100644
--- a/nfs4.1/server41tests/st_destroy_session.py
+++ b/nfs4.1/server41tests/st_destroy_session.py
@@ -149,3 +149,21 @@ def testDestoryNotFinalOps(t, env):
                         op.destroy_session(sess1.sessionid),
                         op.putrootfh()])
     check(res, NFS4ERR_NOT_ONLY_OP)
+
+def testDestoryNotSoleOps(t, env):
+    """ If the COMPOUND request does not start with SEQUENCE,
+        and DESTROY_SESSION is not the sole operation,
+        then server MUST return NFS4ERR_NOT_ONLY_OP. rfc5661 18.37.3
+
+    FLAGS: destroy_session
+    CODE: DSESS9005
+    """
+    c = env.c1.new_client(env.testname(t))
+    sess1 = c.create_session()
+
+    sid = sess1.sessionid
+    res = c.c.compound([op.destroy_session(sess1.sessionid), op.putrootfh()])
+    check(res, NFS4ERR_NOT_ONLY_OP)
+
+    res = c.c.compound([op.putrootfh(), op.destroy_session(sess1.sessionid)])
+    check(res, NFS4ERR_NOT_ONLY_OP)
-- 
1.7.4.1



