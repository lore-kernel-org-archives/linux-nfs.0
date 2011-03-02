Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:62183 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750950Ab1CBGbP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Mar 2011 01:31:15 -0500
Message-ID: <4D6DE458.4040809@cn.fujitsu.com>
Date: Wed, 02 Mar 2011 14:31:52 +0800
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: NFS <linux-nfs@vger.kernel.org>
Subject: [PATCH 08/17] CLNT: test the sessionid, slotid and sequenceid for
 SEQUENCE
References: <4D6DE26C.3010103@cn.fujitsu.com>
In-Reply-To: <4D6DE26C.3010103@cn.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
---
 nfs4.1/server41tests/st_sequence.py |   24 ++++++++++++++++++++++++
 1 files changed, 24 insertions(+), 0 deletions(-)

diff --git a/nfs4.1/server41tests/st_sequence.py b/nfs4.1/server41tests/st_sequence.py
index c6a5959..ed0cc8c 100644
--- a/nfs4.1/server41tests/st_sequence.py
+++ b/nfs4.1/server41tests/st_sequence.py
@@ -314,3 +314,27 @@ def testOpNotInSession(t, env):
     # putrootfh with out session
     res = c.c.compound([op.putrootfh()])
     check(res, NFS4ERR_OP_NOT_IN_SESSION)
+
+def testSessionidSequenceidSlotid(t, env):
+    """ The sr_sessionid result MUST equal sa_sessionid.
+        The sr_slotid result MUST equal sa_slotid. 
+        The sr_sequenceid result MUST equal sa_sequenceid.
+        rfc5661 18.46.3 
+
+    FLAGS: sequence all
+    CODE: SEQ12
+    """
+    c = env.c1.new_client(env.testname(t))
+    sess1 = c.create_session()
+
+    # SEQUENCE
+    sid = sess1.sessionid 
+    res = c.c.compound([op.sequence(sid, 1, 2, 3, True)])
+    if not nfs4lib.test_equal(res.resarray[0].sr_sessionid, sid, "opaque"):
+        fail("server return bad sessionid")
+
+    if not nfs4lib.test_equal(res.resarray[0].sr_sequenceid, 1, "int"):
+        fail("server return bad sequenceid")
+
+    if not nfs4lib.test_equal(res.resarray[0].sr_slotid, 2, "int"):
+        fail("server return bad slotid")
-- 
1.7.4.1



