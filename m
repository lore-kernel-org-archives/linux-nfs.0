Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp-out-1.desy.de ([131.169.56.84]:55529 "EHLO
	smtp-out-1.desy.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751951Ab1LINDa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Dec 2011 08:03:30 -0500
Received: from smtp-map-1.desy.de (smtp-map-1.desy.de [131.169.56.66])
	by smtp-out-1.desy.de (DESY_OUT_1) with ESMTP id 874B419C9
	for <linux-nfs@vger.kernel.org>; Fri,  9 Dec 2011 14:03:29 +0100 (MET)
Received: from ZITSWEEP3.win.desy.de (zitsweep3.win.desy.de [131.169.97.97])
	by smtp-map-1.desy.de (DESY_MAP_1) with ESMTP id 7C97F13E87
	for <linux-nfs@vger.kernel.org>; Fri,  9 Dec 2011 14:03:29 +0100 (MET)
Received: from smtp-intra-1.desy.de (lb-40-26.desy.de) by ZITSWEEP3.win.desy.de
 (Clearswift SMTPRS 5.4.1) with ESMTP id <Ta12f8b8e8883a96161fa0@ZITSWEEP3.win.desy.de> for <linux-nfs@vger.kernel.org>;
 Fri, 9 Dec 2011 14:03:29 +0100
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: linux-nfs@vger.kernel.org
Cc: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Subject: [PATCH v2 2/2] client: add open+close test with current stateid
Date: Fri,  9 Dec 2011 13:58:53 +0100
Message-Id: <1323435533-32571-2-git-send-email-tigran.mkrtchyan@desy.de>
In-Reply-To: <1323435533-32571-1-git-send-email-tigran.mkrtchyan@desy.de>
References: <1323435533-32571-1-git-send-email-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
---
 nfs4.1/server41tests/st_open.py |   19 ++++++++++++++++++-
 1 files changed, 18 insertions(+), 1 deletions(-)

diff --git a/nfs4.1/server41tests/st_open.py b/nfs4.1/server41tests/st_open.py
index 87b58b3..89f3e2d 100644
--- a/nfs4.1/server41tests/st_open.py
+++ b/nfs4.1/server41tests/st_open.py
@@ -1,8 +1,10 @@
 from st_create_session import create_session
 from nfs4_const import *
+
 from environment import check, checklist, fail, create_file, open_file, close_file
+from environment import open_create_file_op
 from nfs4_type import open_owner4, openflag4, createhow4, open_claim4
-from nfs4_type import creatverfattr, fattr4
+from nfs4_type import creatverfattr, fattr4, stateid4
 import nfs4_ops as op
 import threading
 
@@ -236,3 +238,18 @@ def testOPENClaimFH(t, env):
     desired = "\0"*5 + data
     if res.resarray[-1].data != desired:
         fail("Expected %r, got %r" % (desired, res.resarray[-1].data))
+
+def testOpenAndClose(t, env):
+    """test current state id processing by having OPEN and CLOSE
+       in a single compound
+
+    FLAGS: open all
+    CODE: OPEN31
+    """
+    current_stateid = stateid4(1, '\0' * 12)
+    sess1 = env.c1.new_client_session(env.testname(t))
+
+    open_op = open_create_file_op(sess1, env.testname(t), open_create=OPEN4_CREATE)
+    res = sess1.compound(open_op + [op.close(0, current_stateid)])
+    check(res, NFS4_OK)
+
-- 
1.7.7

