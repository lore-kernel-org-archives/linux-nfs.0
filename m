Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp-out-1.desy.de ([131.169.56.84]:33494 "EHLO
	smtp-out-1.desy.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750721Ab1LIPox (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Dec 2011 10:44:53 -0500
Received: from smtp-map-1.desy.de (smtp-map-1.desy.de [131.169.56.66])
	by smtp-out-1.desy.de (DESY_OUT_1) with ESMTP id 9C88A1978
	for <linux-nfs@vger.kernel.org>; Fri,  9 Dec 2011 16:44:51 +0100 (MET)
Received: from ZITSWEEP2.win.desy.de (zitsweep2.win.desy.de [131.169.97.96])
	by smtp-map-1.desy.de (DESY_MAP_1) with ESMTP id 71DE913E86
	for <linux-nfs@vger.kernel.org>; Fri,  9 Dec 2011 16:44:50 +0100 (MET)
Received: from smtp-intra-3.desy.de (lb-40-26.desy.de) by ZITSWEEP2.win.desy.de
 (Clearswift SMTPRS 5.4.1) with ESMTP id <Ta1301f46eb83a96160b60@ZITSWEEP2.win.desy.de> for <linux-nfs@vger.kernel.org>;
 Fri, 9 Dec 2011 16:44:50 +0100
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: linux-nfs@vger.kernel.org
Cc: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Subject: [PATCH] client: test LOCK and LOCKU in a single compound
Date: Fri,  9 Dec 2011 16:40:15 +0100
Message-Id: <1323445215-3654-1-git-send-email-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
---
 nfs4.1/server41tests/st_open.py |   24 +++++++++++++++++++++++-
 1 files changed, 23 insertions(+), 1 deletions(-)

diff --git a/nfs4.1/server41tests/st_open.py b/nfs4.1/server41tests/st_open.py
index 89f3e2d..1c965b2 100644
--- a/nfs4.1/server41tests/st_open.py
+++ b/nfs4.1/server41tests/st_open.py
@@ -4,7 +4,8 @@ from nfs4_const import *
 from environment import check, checklist, fail, create_file, open_file, close_file
 from environment import open_create_file_op
 from nfs4_type import open_owner4, openflag4, createhow4, open_claim4
-from nfs4_type import creatverfattr, fattr4, stateid4
+from nfs4_type import creatverfattr, fattr4, stateid4, locker4, lock_owner4
+from nfs4_type import open_to_lock_owner4
 import nfs4_ops as op
 import threading
 
@@ -253,3 +254,24 @@ def testOpenAndClose(t, env):
     res = sess1.compound(open_op + [op.close(0, current_stateid)])
     check(res, NFS4_OK)
 
+def testLockLockU(t, env):
+    """test current state id processing by having LOCK and LOCKU
+       in a single compound
+
+    FLAGS: open all
+    CODE: OPEN32
+    """
+    current_stateid = stateid4(1, '\0' * 12)
+    sess1 = env.c1.new_client_session(env.testname(t))
+
+    res = create_file(sess1, env.testname(t))
+    check(res)
+    fh = res.resarray[-1].object
+    stateid = res.resarray[-2].stateid
+
+    open_to_lock_owner = open_to_lock_owner4( 0, stateid, 0, lock_owner4(0, "lock1"))
+    lock_owner = locker4(open_owner=open_to_lock_owner, new_lock_owner=True)
+    lock_ops = [ op.lock(WRITE_LT, False, 0, NFS4_UINT64_MAX, lock_owner),
+	op.locku(WRITE_LT, 0, current_stateid, 0, NFS4_UINT64_MAX) ]
+    res = sess1.compound([op.putfh(fh)] + lock_ops)
+    check(res, NFS4_OK)
-- 
1.7.7

