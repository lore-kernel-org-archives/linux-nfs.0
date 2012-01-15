Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp-out-1.desy.de ([131.169.56.84]:45887 "EHLO
	smtp-out-1.desy.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751451Ab2AOTC7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 15 Jan 2012 14:02:59 -0500
Received: from smtp-map-1.desy.de (smtp-map-1.desy.de [131.169.56.66])
	by smtp-out-1.desy.de (DESY_OUT_1) with ESMTP id 9390A1768
	for <linux-nfs@vger.kernel.org>; Sun, 15 Jan 2012 20:02:58 +0100 (MET)
Received: from ZITSWEEP1.win.desy.de (zitsweep1.win.desy.de [131.169.97.95])
	by smtp-map-1.desy.de (DESY_MAP_1) with ESMTP id F1D0513E85
	for <linux-nfs@vger.kernel.org>; Sun, 15 Jan 2012 20:02:57 +0100 (MET)
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: linux-nfs@vger.kernel.org, bfields@fieldses.org
Cc: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Subject: [PATCH 2/5] client: test current stateid processing on PUTROOTFH
Date: Sun, 15 Jan 2012 20:05:25 +0100
Message-Id: <1326654328-20557-3-git-send-email-tigran.mkrtchyan@desy.de>
In-Reply-To: <1326654328-20557-1-git-send-email-tigran.mkrtchyan@desy.de>
References: <1326654328-20557-1-git-send-email-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
---
 nfs4.1/server41tests/st_current_stateid.py |   31 ++++++++++++++++++++++++++++
 1 files changed, 31 insertions(+), 0 deletions(-)

diff --git a/nfs4.1/server41tests/st_current_stateid.py b/nfs4.1/server41tests/st_current_stateid.py
index 1f24ec9..e2da451 100644
--- a/nfs4.1/server41tests/st_current_stateid.py
+++ b/nfs4.1/server41tests/st_current_stateid.py
@@ -84,3 +84,34 @@ def testLockWriteLocku(t, env):
         op.close(0, stateid)]
     res = sess1.compound([op.putfh(fh)] + lock_ops)
     check(res, NFS4_OK)
+
+def testOpenPutrootfhClose(t, env):
+    """test current state id processing by having OPEN, PUTROOTFH and CLOSE
+       in a single compound
+
+    FLAGS: currentstateid all
+    CODE: CSID5
+    """
+    sess1 = env.c1.new_client_session(env.testname(t))
+
+    open_op = open_create_file_op(sess1, env.testname(t), open_create=OPEN4_CREATE)
+    res = sess1.compound(open_op + [op.putrootfh(), op.close(0, current_stateid)])
+    checklist(res, [NFS4ERR_STALE_STATEID, NFS4ERR_BAD_STATEID])
+
+def testCloseNoStateid(t, env):
+    """test current state id processing by having CLOSE
+       without operation which provides stateid
+
+    FLAGS: currentstateid all
+    CODE: CSID6
+    """
+    sess1 = env.c1.new_client_session(env.testname(t))
+
+    res = create_file(sess1, env.testname(t))
+    check(res)
+    fh = res.resarray[-1].object
+    stateid = res.resarray[-2].stateid
+
+    res = sess1.compound([op.putfh(fh), op.close(0, current_stateid)])
+    checklist(res, [NFS4ERR_STALE_STATEID, NFS4ERR_BAD_STATEID])
+
-- 
1.7.7.5

