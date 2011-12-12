Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp-out-1.desy.de ([131.169.56.84]:33959 "EHLO
	smtp-out-1.desy.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753638Ab1LLUbq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Dec 2011 15:31:46 -0500
Received: from smtp-map-1.desy.de (smtp-map-1.desy.de [131.169.56.66])
	by smtp-out-1.desy.de (DESY_OUT_1) with ESMTP id D27341830
	for <linux-nfs@vger.kernel.org>; Mon, 12 Dec 2011 21:31:44 +0100 (MET)
Received: from ZITSWEEP1.win.desy.de (zitsweep1.win.desy.de [131.169.97.95])
	by smtp-map-1.desy.de (DESY_MAP_1) with ESMTP id C80F913F1E
	for <linux-nfs@vger.kernel.org>; Mon, 12 Dec 2011 21:31:44 +0100 (MET)
Received: from smtp-intra-1.desy.de (lb-40-26.desy.de) by ZITSWEEP1.win.desy.de
 (Clearswift SMTPRS 5.4.1) with ESMTP id <Ta14099056383a9615f1458@ZITSWEEP1.win.desy.de> for <linux-nfs@vger.kernel.org>;
 Mon, 12 Dec 2011 21:31:44 +0100
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: linux-nfs@vger.kernel.org
Cc: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Subject: [PATCH 2/3] client: test LOCK+WRITE+LOCKU in a single compound
Date: Mon, 12 Dec 2011 21:26:27 +0100
Message-Id: <1323721588-8259-2-git-send-email-tigran.mkrtchyan@desy.de>
In-Reply-To: <1323721588-8259-1-git-send-email-tigran.mkrtchyan@desy.de>
References: <1323721588-8259-1-git-send-email-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
---
 nfs4.1/server41tests/st_open.py |   27 ++++++++++++++++++++++++++-
 1 files changed, 26 insertions(+), 1 deletions(-)

diff --git a/nfs4.1/server41tests/st_open.py b/nfs4.1/server41tests/st_open.py
index c809c95..6c991c8 100644
--- a/nfs4.1/server41tests/st_open.py
+++ b/nfs4.1/server41tests/st_open.py
@@ -290,4 +290,29 @@ def testOpenWriteClose(t, env):
     open_op = open_create_file_op(sess1, env.testname(t), open_create=OPEN4_CREATE)
     res = sess1.compound(open_op + [op.write(current_stateid, 5, FILE_SYNC4, data),
         op.close(0, current_stateid)])
-    check(res, NFS4_OK)
\ No newline at end of file
+    check(res, NFS4_OK)
+
+def testLockWriteLocku(t, env):
+    """test current state id processing by having LOCK, WRITE and LOCKU
+       in a single compound
+
+    FLAGS: open all
+    CODE: OPEN34
+    """
+    current_stateid = stateid4(1, '\0' * 12)
+    sess1 = env.c1.new_client_session(env.testname(t))
+
+    res = create_file(sess1, env.testname(t))
+    check(res)
+    fh = res.resarray[-1].object
+    stateid = res.resarray[-2].stateid
+
+    data = "write test data"
+    open_to_lock_owner = open_to_lock_owner4( 0, stateid, 0, lock_owner4(0, "lock1"))
+    lock_owner = locker4(open_owner=open_to_lock_owner, new_lock_owner=True)
+    lock_ops = [ op.lock(WRITE_LT, False, 0, NFS4_UINT64_MAX, lock_owner),
+        op.write(current_stateid, 5, FILE_SYNC4, data),
+        op.locku(WRITE_LT, 0, current_stateid, 0, NFS4_UINT64_MAX),
+        op.close(0, stateid)]
+    res = sess1.compound([op.putfh(fh)] + lock_ops)
+    check(res, NFS4_OK)
-- 
1.7.7

