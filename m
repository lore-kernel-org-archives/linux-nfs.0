Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp-out-1.desy.de ([131.169.56.84]:45893 "EHLO
	smtp-out-1.desy.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751451Ab2AOTDA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 15 Jan 2012 14:03:00 -0500
Received: from smtp-map-1.desy.de (smtp-map-1.desy.de [131.169.56.66])
	by smtp-out-1.desy.de (DESY_OUT_1) with ESMTP id 67E8F176A
	for <linux-nfs@vger.kernel.org>; Sun, 15 Jan 2012 20:02:59 +0100 (MET)
Received: from ZITSWEEP1.win.desy.de (zitsweep1.win.desy.de [131.169.97.95])
	by smtp-map-1.desy.de (DESY_MAP_1) with ESMTP id 0218F13E83
	for <linux-nfs@vger.kernel.org>; Sun, 15 Jan 2012 20:02:58 +0100 (MET)
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: linux-nfs@vger.kernel.org, bfields@fieldses.org
Cc: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Subject: [PATCH 4/5] client: test current stateid processing with OPEN and SETATTR
Date: Sun, 15 Jan 2012 20:05:27 +0100
Message-Id: <1326654328-20557-5-git-send-email-tigran.mkrtchyan@desy.de>
In-Reply-To: <1326654328-20557-1-git-send-email-tigran.mkrtchyan@desy.de>
References: <1326654328-20557-1-git-send-email-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
---
 nfs4.1/server41tests/st_current_stateid.py |   15 +++++++++++++++
 1 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/nfs4.1/server41tests/st_current_stateid.py b/nfs4.1/server41tests/st_current_stateid.py
index 788c095..3732907 100644
--- a/nfs4.1/server41tests/st_current_stateid.py
+++ b/nfs4.1/server41tests/st_current_stateid.py
@@ -131,3 +131,18 @@ def testOpenLayoutGet(t, env):
                         0, 8192, 8192, current_stateid, 0xffff)])
     check(res, NFS4_OK)
 
+def testOpenSetattr(t, env):
+    """test current state id processing by having OPEN and SETATTR
+       in a single compound
+
+    FLAGS: currentstateid all
+    CODE: CSID8
+    """
+    size = 8
+    sess = env.c1.new_client_session(env.testname(t),
+                                        flags=EXCHGID4_FLAG_USE_PNFS_MDS)
+
+    open_op = open_create_file_op(sess, env.testname(t), open_create=OPEN4_CREATE)
+    res = sess.compound( open_op + 
+           [ op.setattr(current_stateid, {FATTR4_SIZE: size})])
+    check(res, NFS4_OK)
-- 
1.7.7.5

