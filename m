Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp-out-1.desy.de ([131.169.56.84]:45894 "EHLO
	smtp-out-1.desy.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751944Ab2AOTDB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 15 Jan 2012 14:03:01 -0500
Received: from smtp-map-1.desy.de (smtp-map-1.desy.de [131.169.56.66])
	by smtp-out-1.desy.de (DESY_OUT_1) with ESMTP id A504F176B
	for <linux-nfs@vger.kernel.org>; Sun, 15 Jan 2012 20:02:59 +0100 (MET)
Received: from ZITSWEEP1.win.desy.de (zitsweep1.win.desy.de [131.169.97.95])
	by smtp-map-1.desy.de (DESY_MAP_1) with ESMTP id 6B82313E85
	for <linux-nfs@vger.kernel.org>; Sun, 15 Jan 2012 20:02:59 +0100 (MET)
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: linux-nfs@vger.kernel.org, bfields@fieldses.org
Cc: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Subject: [PATCH 5/5] client: test OPEN+FREE_STETEID+CLOSE in a single compound
Date: Sun, 15 Jan 2012 20:05:28 +0100
Message-Id: <1326654328-20557-6-git-send-email-tigran.mkrtchyan@desy.de>
In-Reply-To: <1326654328-20557-1-git-send-email-tigran.mkrtchyan@desy.de>
References: <1326654328-20557-1-git-send-email-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
---
 nfs4.1/server41tests/st_current_stateid.py |   13 +++++++++++++
 1 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/nfs4.1/server41tests/st_current_stateid.py b/nfs4.1/server41tests/st_current_stateid.py
index 3732907..fb0c360 100644
--- a/nfs4.1/server41tests/st_current_stateid.py
+++ b/nfs4.1/server41tests/st_current_stateid.py
@@ -146,3 +146,16 @@ def testOpenSetattr(t, env):
     res = sess.compound( open_op + 
            [ op.setattr(current_stateid, {FATTR4_SIZE: size})])
     check(res, NFS4_OK)
+
+def testOpenFreestateidClose(t, env):
+    """test current state id processing by having OPEN, FREE_STATEID and CLOSE
+       in a single compound
+
+    FLAGS: currentstateid all
+    CODE: CSID9
+    """
+    sess1 = env.c1.new_client_session(env.testname(t))
+
+    open_op = open_create_file_op(sess1, env.testname(t), open_create=OPEN4_CREATE)
+    res = sess1.compound(open_op + [op.free_stateid(current_stateid), op.close(0, current_stateid)])
+    checklist(res, [NFS4ERR_STALE_STATEID, NFS4ERR_BAD_STATEID])
-- 
1.7.7.5

