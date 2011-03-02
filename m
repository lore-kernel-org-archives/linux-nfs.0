Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:56376 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751035Ab1CBGby (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Mar 2011 01:31:54 -0500
Message-ID: <4D6DE484.6010608@cn.fujitsu.com>
Date: Wed, 02 Mar 2011 14:32:36 +0800
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: NFS <linux-nfs@vger.kernel.org>
Subject: [PATCH 09/17] CLNT: test Bad Sequenceid At Slot
References: <4D6DE26C.3010103@cn.fujitsu.com>
In-Reply-To: <4D6DE26C.3010103@cn.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
---
 nfs4.1/server41tests/st_sequence.py |   25 +++++++++++++++++++++++++
 1 files changed, 25 insertions(+), 0 deletions(-)

diff --git a/nfs4.1/server41tests/st_sequence.py b/nfs4.1/server41tests/st_sequence.py
index ed0cc8c..4ea5cab 100644
--- a/nfs4.1/server41tests/st_sequence.py
+++ b/nfs4.1/server41tests/st_sequence.py
@@ -338,3 +338,28 @@ def testSessionidSequenceidSlotid(t, env):
 
     if not nfs4lib.test_equal(res.resarray[0].sr_slotid, 2, "int"):
         fail("server return bad slotid")
+
+def testBadSequenceidAtSlot(t, env):
+    """ If the difference between sa_sequenceid and the server's cached
+        sequence ID at the slot ID is two (2) or more, or if sa_sequenceid
+        is less than the cached sequence ID , server MUST return
+        NFS4ERR_SEQ_MISORDERED. rfc5661 18.46.3
+
+    FLAGS: sequence all
+    CODE: SEQ13
+    """
+    c = env.c1.new_client(env.testname(t))
+    # CREATE_SESSION
+    sess1 = c.create_session()
+
+    sid = sess1.sessionid 
+    res = c.c.compound([op.sequence(sid, 1, 2, 3, True)])
+    check(res)
+
+    seqid = res.resarray[0].sr_sequenceid
+    # SEQUENCE with bad sr_sequenceid
+    res = c.c.compound([op.sequence(sid, seqid + 2, 2, 3, True)])
+    check(res, NFS4ERR_SEQ_MISORDERED)
+
+    res = c.c.compound([op.sequence(sid, nfs4lib.dec_u32(seqid), 2, 3, True)])
+    check(res, NFS4ERR_SEQ_MISORDERED)
-- 
1.7.4.1



