Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp-out-2.desy.de ([131.169.56.85]:49636 "EHLO
	smtp-out-2.desy.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753634Ab1LLUbq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Dec 2011 15:31:46 -0500
Received: from smtp-map-2.desy.de (smtp-map-2.desy.de [131.169.56.67])
	by smtp-out-2.desy.de (DESY_OUT_1) with ESMTP id D1CA210B8
	for <linux-nfs@vger.kernel.org>; Mon, 12 Dec 2011 21:31:44 +0100 (MET)
Received: from ZITSWEEP3.win.desy.de (zitsweep3.win.desy.de [131.169.97.97])
	by smtp-map-2.desy.de (DESY_MAP_2) with ESMTP id B6CA9109C
	for <linux-nfs@vger.kernel.org>; Mon, 12 Dec 2011 21:31:44 +0100 (MET)
Received: from smtp-intra-1.desy.de (lb-40-26.desy.de) by ZITSWEEP3.win.desy.de
 (Clearswift SMTPRS 5.4.1) with ESMTP id <Ta1409905db83a96161fa0@ZITSWEEP3.win.desy.de> for <linux-nfs@vger.kernel.org>;
 Mon, 12 Dec 2011 21:31:44 +0100
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: linux-nfs@vger.kernel.org
Cc: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Subject: [PATCH 1/3] client: test OPEN+WRITE+CLOSE in a single compound
Date: Mon, 12 Dec 2011 21:26:26 +0100
Message-Id: <1323721588-8259-1-git-send-email-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
---
 nfs4.1/server41tests/st_open.py |   16 ++++++++++++++++
 1 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/nfs4.1/server41tests/st_open.py b/nfs4.1/server41tests/st_open.py
index 1c965b2..c809c95 100644
--- a/nfs4.1/server41tests/st_open.py
+++ b/nfs4.1/server41tests/st_open.py
@@ -275,3 +275,19 @@ def testLockLockU(t, env):
 	op.locku(WRITE_LT, 0, current_stateid, 0, NFS4_UINT64_MAX) ]
     res = sess1.compound([op.putfh(fh)] + lock_ops)
     check(res, NFS4_OK)
+
+def testOpenWriteClose(t, env):
+    """test current state id processing by having OPEN, WRITE and CLOSE
+       in a single compound
+
+    FLAGS: open all
+    CODE: OPEN33
+    """
+    current_stateid = stateid4(1, '\0' * 12)
+    sess1 = env.c1.new_client_session(env.testname(t))
+
+    data = "write test data"
+    open_op = open_create_file_op(sess1, env.testname(t), open_create=OPEN4_CREATE)
+    res = sess1.compound(open_op + [op.write(current_stateid, 5, FILE_SYNC4, data),
+        op.close(0, current_stateid)])
+    check(res, NFS4_OK)
\ No newline at end of file
-- 
1.7.7

