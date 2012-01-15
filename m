Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp-out-1.desy.de ([131.169.56.84]:45891 "EHLO
	smtp-out-1.desy.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751785Ab2AOTDA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 15 Jan 2012 14:03:00 -0500
Received: from smtp-map-1.desy.de (smtp-map-1.desy.de [131.169.56.66])
	by smtp-out-1.desy.de (DESY_OUT_1) with ESMTP id DA9AC1769
	for <linux-nfs@vger.kernel.org>; Sun, 15 Jan 2012 20:02:58 +0100 (MET)
Received: from ZITSWEEP1.win.desy.de (zitsweep1.win.desy.de [131.169.97.95])
	by smtp-map-1.desy.de (DESY_MAP_1) with ESMTP id 90C7113E86
	for <linux-nfs@vger.kernel.org>; Sun, 15 Jan 2012 20:02:58 +0100 (MET)
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: linux-nfs@vger.kernel.org, bfields@fieldses.org
Cc: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Subject: [PATCH 3/5] client: test current stateid processing with OPEN+LAYOUTGET in a single compound
Date: Sun, 15 Jan 2012 20:05:26 +0100
Message-Id: <1326654328-20557-4-git-send-email-tigran.mkrtchyan@desy.de>
In-Reply-To: <1326654328-20557-1-git-send-email-tigran.mkrtchyan@desy.de>
References: <1326654328-20557-1-git-send-email-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
---
 nfs4.1/server41tests/st_current_stateid.py |   16 ++++++++++++++++
 1 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/nfs4.1/server41tests/st_current_stateid.py b/nfs4.1/server41tests/st_current_stateid.py
index e2da451..788c095 100644
--- a/nfs4.1/server41tests/st_current_stateid.py
+++ b/nfs4.1/server41tests/st_current_stateid.py
@@ -115,3 +115,19 @@ def testCloseNoStateid(t, env):
     res = sess1.compound([op.putfh(fh), op.close(0, current_stateid)])
     checklist(res, [NFS4ERR_STALE_STATEID, NFS4ERR_BAD_STATEID])
 
+def testOpenLayoutGet(t, env):
+    """test current state id processing by having OPEN and LAYOUTGET
+       in a single compound
+
+    FLAGS: currentstateid all
+    CODE: CSID7
+    """
+    sess = env.c1.new_client_session(env.testname(t),
+                                        flags=EXCHGID4_FLAG_USE_PNFS_MDS)
+
+    open_op = open_create_file_op(sess, env.testname(t), open_create=OPEN4_CREATE)
+    res = sess.compound( open_op + 
+           [op.layoutget(False, LAYOUT4_NFSV4_1_FILES, LAYOUTIOMODE4_RW,
+                        0, 8192, 8192, current_stateid, 0xffff)])
+    check(res, NFS4_OK)
+
-- 
1.7.7.5

