Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:55928 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751154Ab1CBGZT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Mar 2011 01:25:19 -0500
Message-ID: <4D6DE2F8.8010309@cn.fujitsu.com>
Date: Wed, 02 Mar 2011 14:26:00 +0800
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: NFS <linux-nfs@vger.kernel.org>
Subject: [PATCH 01/17] CLNT: check NFS4ERR_NOT_ONLY_OP for CREATE_SESSION
References: <4D6DE26C.3010103@cn.fujitsu.com>
In-Reply-To: <4D6DE26C.3010103@cn.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
---
 nfs4.1/server41tests/st_create_session.py |   14 ++++++++++++++
 1 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/nfs4.1/server41tests/st_create_session.py b/nfs4.1/server41tests/st_create_session.py
index a213a3c..1d02a50 100644
--- a/nfs4.1/server41tests/st_create_session.py
+++ b/nfs4.1/server41tests/st_create_session.py
@@ -382,3 +382,17 @@ def testMaxreqs(t, env):
     if nfs4lib.test_equal(sess1.fore_channel.maxrequests,
                           chan_attrs.ca_maxrequests, "count4"):
         fail("Server allows surprisingly large fore_channel maxreqs")
+
+def testNotOnlyOp(t, env):
+    """Check for NFS4ERR_NOT_ONLY_OP
+
+    FLAGS: create_session all
+    CODE: CSESS23
+    """
+    c = env.c1.new_client(env.testname(t))
+    # CREATE_SESSION with PUT_ROOTFH
+    chan_attrs = channel_attrs4(0,8192,8192,8192,128,8,[])
+    res = c.c.compound([op.create_session(c.clientid, c.seqid, 0,
+                                        chan_attrs, chan_attrs,
+                                        123, []), op.putrootfh()], None)
+    check(res, NFS4ERR_NOT_ONLY_OP)
-- 
1.7.4.1



