Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp-out-3.desy.de ([131.169.56.86]:43962 "EHLO
	smtp-out-3.desy.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752243Ab1LHQ4a (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Dec 2011 11:56:30 -0500
Received: from smtp-map-3.desy.de (smtp-map-3.desy.de [131.169.56.68])
	by smtp-out-3.desy.de (DESY_OUT_3) with ESMTP id DF5CA129B
	for <linux-nfs@vger.kernel.org>; Thu,  8 Dec 2011 17:56:28 +0100 (MET)
Received: from ZITSWEEP3.win.desy.de (zitsweep3.win.desy.de [131.169.97.97])
	by smtp-map-3.desy.de (DESY_MAP_3) with ESMTP id D09511295
	for <linux-nfs@vger.kernel.org>; Thu,  8 Dec 2011 17:56:26 +0100 (MET)
Received: from smtp-intra-3.desy.de (lb-40-26.desy.de) by ZITSWEEP3.win.desy.de
 (Clearswift SMTPRS 5.4.1) with ESMTP id <Ta12b3a785283a96161fa0@ZITSWEEP3.win.desy.de> for <linux-nfs@vger.kernel.org>;
 Thu, 8 Dec 2011 17:56:26 +0100
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: linux-nfs@vger.kernel.org
Cc: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Subject: [PATCH 1/2] create open requests without executing
Date: Thu,  8 Dec 2011 17:51:51 +0100
Message-Id: <1323363112-13256-1-git-send-email-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
---
 nfs4.1/server41tests/environment.py |   13 ++++++++++++-
 1 files changed, 12 insertions(+), 1 deletions(-)

diff --git a/nfs4.1/server41tests/environment.py b/nfs4.1/server41tests/environment.py
index 6e68e83..6f3bd0a 100644
--- a/nfs4.1/server41tests/environment.py
+++ b/nfs4.1/server41tests/environment.py
@@ -453,6 +453,17 @@ def open_create_file(sess, owner, path=None, attrs={FATTR4_MODE: 0644},
 		     deleg_type=None,
 		     open_create=OPEN4_NOCREATE,
 		     seqid=0, clientid=0):
+    return sess.compound(open_create_file_op())
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
@@ -485,7 +496,7 @@ def open_create_file(sess, owner, path=None, attrs={FATTR4_MODE: 0644},
     open_op = op.open(seqid, access, deny, open_owner4(clientid, owner),
                       openflag, openclaim)
 
-    return sess.compound(fh_op + [open_op, op.getfh()])
+    return fh_op + [open_op, op.getfh()]
 
 def create_file(sess, owner, path=None, attrs={FATTR4_MODE: 0644},
                 access=OPEN4_SHARE_ACCESS_BOTH,
-- 
1.7.7

