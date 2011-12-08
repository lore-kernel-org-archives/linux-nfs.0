Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp-out-3.desy.de ([131.169.56.86]:43967 "EHLO
	smtp-out-3.desy.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752270Ab1LHQ4a (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Dec 2011 11:56:30 -0500
Received: from smtp-map-3.desy.de (smtp-map-3.desy.de [131.169.56.68])
	by smtp-out-3.desy.de (DESY_OUT_3) with ESMTP id D581B141C
	for <linux-nfs@vger.kernel.org>; Thu,  8 Dec 2011 17:56:29 +0100 (MET)
Received: from ZITSWEEP3.win.desy.de (zitsweep3.win.desy.de [131.169.97.97])
	by smtp-map-3.desy.de (DESY_MAP_3) with ESMTP id CE9991295
	for <linux-nfs@vger.kernel.org>; Thu,  8 Dec 2011 17:56:29 +0100 (MET)
Received: from smtp-intra-3.desy.de (lb-40-26.desy.de) by ZITSWEEP3.win.desy.de
 (Clearswift SMTPRS 5.4.1) with ESMTP id <Ta12b3a851e83a96161fa0@ZITSWEEP3.win.desy.de> for <linux-nfs@vger.kernel.org>;
 Thu, 8 Dec 2011 17:56:30 +0100
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: linux-nfs@vger.kernel.org
Cc: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Subject: [PATCH 2/2] client: add open+close test with current stateid
Date: Thu,  8 Dec 2011 17:51:52 +0100
Message-Id: <1323363112-13256-2-git-send-email-tigran.mkrtchyan@desy.de>
In-Reply-To: <1323363112-13256-1-git-send-email-tigran.mkrtchyan@desy.de>
References: <1323363112-13256-1-git-send-email-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
---
 nfs4.1/server41tests/st_open.py |   17 ++++++++++++++++-
 1 files changed, 16 insertions(+), 1 deletions(-)

diff --git a/nfs4.1/server41tests/st_open.py b/nfs4.1/server41tests/st_open.py
index bd995a5..6b82e9d 100644
--- a/nfs4.1/server41tests/st_open.py
+++ b/nfs4.1/server41tests/st_open.py
@@ -1,8 +1,9 @@
 from st_create_session import create_session
 from nfs4_const import *
 from environment import check, checklist, fail, create_file, open_file
+from environment import open_create_file_op
 from nfs4_type import open_owner4, openflag4, createhow4, open_claim4
-from nfs4_type import creatverfattr, fattr4
+from nfs4_type import creatverfattr, fattr4, stateid4
 import nfs4_ops as op
 import threading
 
@@ -200,3 +201,17 @@ def testEXCLUSIVE4AtNameAttribute(t, env):
     res = create_file(sess1, env.testname(t), mode=EXCLUSIVE4_1,
                         verifier = "Justtest")
     check(res, NFS4ERR_EXIST)
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
-- 
1.7.7

