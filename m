Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp-out-3.desy.de ([131.169.56.86]:37807 "EHLO
	smtp-out-3.desy.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753739Ab1LLUbq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Dec 2011 15:31:46 -0500
Received: from smtp-map-3.desy.de (smtp-map-3.desy.de [131.169.56.68])
	by smtp-out-3.desy.de (DESY_OUT_3) with ESMTP id E8F411507
	for <linux-nfs@vger.kernel.org>; Mon, 12 Dec 2011 21:31:44 +0100 (MET)
Received: from ZITSWEEP2.win.desy.de (zitsweep2.win.desy.de [131.169.97.96])
	by smtp-map-3.desy.de (DESY_MAP_3) with ESMTP id E023B14FF
	for <linux-nfs@vger.kernel.org>; Mon, 12 Dec 2011 21:31:44 +0100 (MET)
Received: from smtp-intra-1.desy.de (lb-40-26.desy.de) by ZITSWEEP2.win.desy.de
 (Clearswift SMTPRS 5.4.1) with ESMTP id <Ta1409905d883a96160b60@ZITSWEEP2.win.desy.de> for <linux-nfs@vger.kernel.org>;
 Mon, 12 Dec 2011 21:31:45 +0100
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: linux-nfs@vger.kernel.org
Cc: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Subject: [PATCH 3/3] client: group test with currentstateid tougheter
Date: Mon, 12 Dec 2011 21:26:28 +0100
Message-Id: <1323721588-8259-3-git-send-email-tigran.mkrtchyan@desy.de>
In-Reply-To: <1323721588-8259-1-git-send-email-tigran.mkrtchyan@desy.de>
References: <1323721588-8259-1-git-send-email-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
---
 nfs4.1/server41tests/st_open.py |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/nfs4.1/server41tests/st_open.py b/nfs4.1/server41tests/st_open.py
index 6c991c8..1c51f71 100644
--- a/nfs4.1/server41tests/st_open.py
+++ b/nfs4.1/server41tests/st_open.py
@@ -244,7 +244,7 @@ def testOpenAndClose(t, env):
     """test current state id processing by having OPEN and CLOSE
        in a single compound
 
-    FLAGS: open all
+    FLAGS: currentstateid open all
     CODE: OPEN31
     """
     current_stateid = stateid4(1, '\0' * 12)
@@ -258,7 +258,7 @@ def testLockLockU(t, env):
     """test current state id processing by having LOCK and LOCKU
        in a single compound
 
-    FLAGS: open all
+    FLAGS: currentstateid open all
     CODE: OPEN32
     """
     current_stateid = stateid4(1, '\0' * 12)
@@ -280,7 +280,7 @@ def testOpenWriteClose(t, env):
     """test current state id processing by having OPEN, WRITE and CLOSE
        in a single compound
 
-    FLAGS: open all
+    FLAGS: currentstateid open all
     CODE: OPEN33
     """
     current_stateid = stateid4(1, '\0' * 12)
@@ -296,7 +296,7 @@ def testLockWriteLocku(t, env):
     """test current state id processing by having LOCK, WRITE and LOCKU
        in a single compound
 
-    FLAGS: open all
+    FLAGS: currentstateid open all
     CODE: OPEN34
     """
     current_stateid = stateid4(1, '\0' * 12)
-- 
1.7.7

