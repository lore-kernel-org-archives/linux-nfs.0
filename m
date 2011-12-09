Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp-out-2.desy.de ([131.169.56.85]:60612 "EHLO
	smtp-out-2.desy.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751441Ab1LIND3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Dec 2011 08:03:29 -0500
Received: from smtp-map-2.desy.de (smtp-map-2.desy.de [131.169.56.67])
	by smtp-out-2.desy.de (DESY_OUT_1) with ESMTP id 011011042
	for <linux-nfs@vger.kernel.org>; Fri,  9 Dec 2011 14:03:28 +0100 (MET)
Received: from ZITSWEEP1.win.desy.de (zitsweep1.win.desy.de [131.169.97.95])
	by smtp-map-2.desy.de (DESY_MAP_2) with ESMTP id EA30B103F
	for <linux-nfs@vger.kernel.org>; Fri,  9 Dec 2011 14:03:27 +0100 (MET)
Received: from smtp-intra-1.desy.de (lb-40-26.desy.de) by ZITSWEEP1.win.desy.de
 (Clearswift SMTPRS 5.4.1) with ESMTP id <Ta12f8b84cb83a9615f1458@ZITSWEEP1.win.desy.de> for <linux-nfs@vger.kernel.org>;
 Fri, 9 Dec 2011 14:03:27 +0100
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: linux-nfs@vger.kernel.org
Cc: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Subject: [PATCH v2 1/2] create open requests without executing
Date: Fri,  9 Dec 2011 13:58:52 +0100
Message-Id: <1323435533-32571-1-git-send-email-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
---
 nfs4.1/server41tests/environment.py |   17 ++++++++++++++++-
 1 files changed, 16 insertions(+), 1 deletions(-)

diff --git a/nfs4.1/server41tests/environment.py b/nfs4.1/server41tests/environment.py
index 6e68e83..45ceef1 100644
--- a/nfs4.1/server41tests/environment.py
+++ b/nfs4.1/server41tests/environment.py
@@ -453,6 +453,21 @@ def open_create_file(sess, owner, path=None, attrs={FATTR4_MODE: 0644},
 		     deleg_type=None,
 		     open_create=OPEN4_NOCREATE,
 		     seqid=0, clientid=0):
+    open_op = open_create_file_op (sess, owner, path, attrs, access, deny, mode,
+                            verifier, claim_type, want_deleg, deleg_type,
+                            open_create, seqid, clientid)
+
+    return sess.compound(open_op)
+
+def open_create_file_op(sess, owner, path=None, attrs={FATTR4_MODE: 0644},
+                     access=OPEN4_SHARE_ACCESS_BOTH,
+                     deny=OPEN4_SHARE_DENY_NONE,
+		     mode=GUARDED4, verifier=None,
+		     claim_type=CLAIM_NULL,
+		     want_deleg=False,
+		     deleg_type=None,
+		     open_create=OPEN4_NOCREATE,
+		     seqid=0, clientid=0):
     # Set defaults
     if path is None:
         dir = sess.c.homedir
@@ -485,7 +500,7 @@ def open_create_file(sess, owner, path=None, attrs={FATTR4_MODE: 0644},
     open_op = op.open(seqid, access, deny, open_owner4(clientid, owner),
                       openflag, openclaim)
 
-    return sess.compound(fh_op + [open_op, op.getfh()])
+    return fh_op + [open_op, op.getfh()]
 
 def create_file(sess, owner, path=None, attrs={FATTR4_MODE: 0644},
                 access=OPEN4_SHARE_ACCESS_BOTH,
-- 
1.7.7

