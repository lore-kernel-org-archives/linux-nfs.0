Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cn.fujitsu.com ([222.73.24.84]:64602 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1755184Ab1LGAuh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Dec 2011 19:50:37 -0500
Message-ID: <4EDEB9A7.8060406@cn.fujitsu.com>
Date: Wed, 07 Dec 2011 08:56:07 +0800
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: NFS <linux-nfs@vger.kernel.org>
Subject: [PATCH v2] 4.1 CLNT: Test Case for OPEN file with claim_type is CLAIM_FH
References: <4EC46E76.5040907@cn.fujitsu.com>
In-Reply-To: <4EC46E76.5040907@cn.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Open NFS file with filehandle, write some data to the opened file,
read and check it.

Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
---
 nfs4.1/server41tests/st_open.py |   38 +++++++++++++++++++++++++++++++++++++-
 1 files changed, 37 insertions(+), 1 deletions(-)

diff --git a/nfs4.1/server41tests/st_open.py b/nfs4.1/server41tests/st_open.py
index bd995a5..87b58b3 100644
--- a/nfs4.1/server41tests/st_open.py
+++ b/nfs4.1/server41tests/st_open.py
@@ -1,6 +1,6 @@
 from st_create_session import create_session
 from nfs4_const import *
-from environment import check, checklist, fail, create_file, open_file
+from environment import check, checklist, fail, create_file, open_file, close_file
 from nfs4_type import open_owner4, openflag4, createhow4, open_claim4
 from nfs4_type import creatverfattr, fattr4
 import nfs4_ops as op
@@ -200,3 +200,39 @@ def testEXCLUSIVE4AtNameAttribute(t, env):
     res = create_file(sess1, env.testname(t), mode=EXCLUSIVE4_1,
                         verifier = "Justtest")
     check(res, NFS4ERR_EXIST)
+
+def testOPENClaimFH(t, env):
+    """OPEN file with claim_type is CLAIM_FH
+
+    FLAGS: open all
+    CODE: OPEN7
+    """
+    sess1 = env.c1.new_client_session(env.testname(t))
+    res = create_file(sess1, env.testname(t))
+    check(res)
+
+    fh = res.resarray[-1].object
+    stateid = res.resarray[-2].stateid
+    res = close_file(sess1, fh, stateid=stateid)
+    check(res)
+
+    claim = open_claim4(CLAIM_FH)
+    how = openflag4(OPEN4_NOCREATE)
+    oowner = open_owner4(0, "My Open Owner 2")
+    open_op = op.open(0, OPEN4_SHARE_ACCESS_BOTH, OPEN4_SHARE_DENY_NONE,
+                      oowner, how, claim)
+    res = sess1.compound([op.putfh(fh), open_op])
+    check(res)
+
+    stateid = res.resarray[-1].stateid
+    stateid.seqid = 0
+    data = "write test data"
+    res = sess1.compound([op.putfh(fh), op.write(stateid, 5, FILE_SYNC4, data)])
+    check(res)
+    res = sess1.compound([op.putfh(fh), op.read(stateid, 0, 1000)])
+    check(res)
+    if not res.resarray[-1].eof:
+        fail("EOF not set on read")
+    desired = "\0"*5 + data
+    if res.resarray[-1].data != desired:
+        fail("Expected %r, got %r" % (desired, res.resarray[-1].data))
-- 
1.7.7


