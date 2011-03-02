Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:63469 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750918Ab1CBGag (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Mar 2011 01:30:36 -0500
Message-ID: <4D6DE436.3050204@cn.fujitsu.com>
Date: Wed, 02 Mar 2011 14:31:18 +0800
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: NFS <linux-nfs@vger.kernel.org>
Subject: [PATCH 07/17] CLNT: test operation not in session
References: <4D6DE26C.3010103@cn.fujitsu.com>
In-Reply-To: <4D6DE26C.3010103@cn.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
---
 nfs4.1/server41tests/st_sequence.py |   13 +++++++++++++
 1 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/nfs4.1/server41tests/st_sequence.py b/nfs4.1/server41tests/st_sequence.py
index a5e344d..c6a5959 100644
--- a/nfs4.1/server41tests/st_sequence.py
+++ b/nfs4.1/server41tests/st_sequence.py
@@ -301,3 +301,16 @@ def testReplayCache007(t, env):
     res2 = sess1.compound(ops, seq_delta=0, cache_this=False)
     check(res2, NFS4ERR_RETRY_UNCACHED_REP)
 
+def testOpNotInSession(t, env):
+    """Operations other than SEQUENCE, BIND_CONN_TO_SESSION, EXCHANGE_ID,
+       CREATE_SESSION, and DESTROY_SESSION, MUST NOT appear as the
+       first operation in a COMPOUND. rfc5661 18.46.3
+
+    FLAGS: sequence all
+    CODE: SEQ11
+    """
+    c = env.c1.new_client(env.testname(t))
+
+    # putrootfh with out session
+    res = c.c.compound([op.putrootfh()])
+    check(res, NFS4ERR_OP_NOT_IN_SESSION)
-- 
1.7.4.1



