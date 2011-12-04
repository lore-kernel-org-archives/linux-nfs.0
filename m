Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp-out-2.desy.de ([131.169.56.85]:57914 "EHLO
	smtp-out-2.desy.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752993Ab1LDMQf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 4 Dec 2011 07:16:35 -0500
Received: from smtp-map-2.desy.de (smtp-map-2.desy.de [131.169.56.67])
	by smtp-out-2.desy.de (DESY_OUT_1) with ESMTP id 8628AE48
	for <linux-nfs@vger.kernel.org>; Sun,  4 Dec 2011 13:06:28 +0100 (MET)
Received: from ZITSWEEP1.win.desy.de (zitsweep1.win.desy.de [131.169.97.95])
	by smtp-map-2.desy.de (DESY_MAP_2) with ESMTP id 62771E42
	for <linux-nfs@vger.kernel.org>; Sun,  4 Dec 2011 13:06:28 +0100 (MET)
Received: from smtp-intra-2.desy.de (lb-40-26.desy.de) by ZITSWEEP1.win.desy.de
 (Clearswift SMTPRS 5.4.1) with ESMTP id <Ta115978eae83a9615f1a88@ZITSWEEP1.win.desy.de> for <linux-nfs@vger.kernel.org>;
 Sun, 4 Dec 2011 13:06:28 +0100
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: linux-nfs@vger.kernel.org
Cc: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Subject: [PATCH] demo test for current stateid
Date: Sun,  4 Dec 2011 13:01:51 +0100
Message-Id: <1323000111-21355-1-git-send-email-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
---
 nfs4.1/server41tests/environment.py |   26 ++++++++++++++++++++++++++
 nfs4.1/server41tests/st_open.py     |   13 +++++++++++++
 2 files changed, 39 insertions(+), 0 deletions(-)

diff --git a/nfs4.1/server41tests/environment.py b/nfs4.1/server41tests/environment.py
index 6e68e83..74fe42f 100644
--- a/nfs4.1/server41tests/environment.py
+++ b/nfs4.1/server41tests/environment.py
@@ -502,6 +502,32 @@ def create_file(sess, owner, path=None, attrs={FATTR4_MODE: 0644},
                             verifier, claim_type, want_deleg, deleg_type,
                             open_create, seqid, clientid)
 
+def create_and_close_file(sess, owner, path=None, attrs={FATTR4_MODE: 0644},
+                access=OPEN4_SHARE_ACCESS_BOTH,
+                deny=OPEN4_SHARE_DENY_NONE,
+                mode=GUARDED4, verifier=None, want_deleg=False,
+                # Setting the following should induce server errors
+                seqid=0, clientid=0):
+
+    current_stateid = stateid4(1 , "\0" * 12)
+    # Set defaults
+    if path is None:
+        dir = sess.c.homedir
+        name = owner
+    else:
+        dir = path[:-1]
+        name = path[-1]
+    if ((mode==EXCLUSIVE4) or (mode==EXCLUSIVE4_1)) and (verifier==None):
+        verifier = sess.c.verifier
+    if not want_deleg and access & OPEN4_SHARE_ACCESS_WANT_DELEG_MASK == 0:
+        access |= OPEN4_SHARE_ACCESS_WANT_NO_DELEG
+    # Create the file
+    open_op = op.open(seqid, access, deny, open_owner4(clientid, owner),
+                      openflag4(OPEN4_CREATE, createhow4(mode, attrs, verifier,
+                                               creatverfattr(verifier, attrs))),
+                      open_claim4(CLAIM_NULL, name))
+    return sess.compound(use_obj(dir) + [open_op, op.getfh(), op.close(seqid, current_stateid)])
+
 def open_file(sess, owner, path=None,
               access=OPEN4_SHARE_ACCESS_READ,
               deny=OPEN4_SHARE_DENY_NONE,
diff --git a/nfs4.1/server41tests/st_open.py b/nfs4.1/server41tests/st_open.py
index bd995a5..92034a3 100644
--- a/nfs4.1/server41tests/st_open.py
+++ b/nfs4.1/server41tests/st_open.py
@@ -1,6 +1,7 @@
 from st_create_session import create_session
 from nfs4_const import *
 from environment import check, checklist, fail, create_file, open_file
+from environment import create_and_close_file
 from nfs4_type import open_owner4, openflag4, createhow4, open_claim4
 from nfs4_type import creatverfattr, fattr4
 import nfs4_ops as op
@@ -200,3 +201,15 @@ def testEXCLUSIVE4AtNameAttribute(t, env):
     res = create_file(sess1, env.testname(t), mode=EXCLUSIVE4_1,
                         verifier = "Justtest")
     check(res, NFS4ERR_EXIST)
+
+
+def testCurretStateid(t, env):
+    """Test OPEN and CLOSE within same compound
+
+    FLAGS: open all
+    CODE: OPEN7
+    """
+    sess1 = env.c1.new_client_session(env.testname(t))
+
+    res = create_and_close_file(sess1, env.testname(t), mode=EXCLUSIVE4_1)
+    check(res, NFS4_OK)
-- 
1.7.7.3

