Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:49921 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751801Ab1CBGc2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Mar 2011 01:32:28 -0500
Message-ID: <4D6DE4A5.1050702@cn.fujitsu.com>
Date: Wed, 02 Mar 2011 14:33:09 +0800
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: NFS <linux-nfs@vger.kernel.org>
Subject: [PATCH 10/17] CLNT: test resues slot ID
References: <4D6DE26C.3010103@cn.fujitsu.com>
In-Reply-To: <4D6DE26C.3010103@cn.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
---
 nfs4.1/server41tests/st_sequence.py |   18 ++++++++++++++++++
 1 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/nfs4.1/server41tests/st_sequence.py b/nfs4.1/server41tests/st_sequence.py
index 4ea5cab..391fc45 100644
--- a/nfs4.1/server41tests/st_sequence.py
+++ b/nfs4.1/server41tests/st_sequence.py
@@ -363,3 +363,21 @@ def testBadSequenceidAtSlot(t, env):
 
     res = c.c.compound([op.sequence(sid, nfs4lib.dec_u32(seqid), 2, 3, True)])
     check(res, NFS4ERR_SEQ_MISORDERED)
+
+def testReuseSlotID(t, env):
+    """
+
+    FLAGS: sequence all
+    CODE: SEQ14
+    """
+    c = env.c1.new_client(env.testname(t))
+    # CREATE_SESSION
+    sess1 = c.create_session()
+
+    sid = sess1.sessionid 
+    res = c.c.compound([op.sequence(sid, 1, 2, 3, True), op.putrootfh()])
+    check(res)
+
+    res = c.c.compound([op.sequence(sid, 1, 2, 3, True)])
+    # should we also check the ERROR of NFS4ERR_SEQ_FALSE_RETRY ??
+    check(res)
-- 
1.7.4.1



