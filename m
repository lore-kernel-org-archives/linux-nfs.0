Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp-o-3.desy.de ([131.169.56.156]:36379 "EHLO smtp-o-3.desy.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750983Ab3JDUiO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Oct 2013 16:38:14 -0400
Received: from smtp-map-3.desy.de (smtp-map-3.desy.de [131.169.56.68])
	by smtp-o-3.desy.de (DESY-O-3) with ESMTP id 955E02809BF
	for <linux-nfs@vger.kernel.org>; Fri,  4 Oct 2013 22:28:32 +0200 (CEST)
Received: from ZITSWEEP1.win.desy.de (zitsweep1.win.desy.de [131.169.97.95])
	by smtp-map-3.desy.de (DESY_MAP_3) with ESMTP id 89C4F10D2
	for <linux-nfs@vger.kernel.org>; Fri,  4 Oct 2013 22:28:32 +0200 (MEST)
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Subject: [PATCH] st_destroy_session: remove invalid testcase
Date: Fri,  4 Oct 2013 22:28:12 +0200
Message-Id: <1380918492-8413-1-git-send-email-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

we cant expect NFS4ERR_NOT_ONLY_OP if spec
enforces NFS4ERR_OP_NOT_IN_SESSION

Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
---
 nfs4.1/server41tests/st_destroy_session.py | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/nfs4.1/server41tests/st_destroy_session.py b/nfs4.1/server41tests/st_destroy_session.py
index 1feb671..f4f0762 100644
--- a/nfs4.1/server41tests/st_destroy_session.py
+++ b/nfs4.1/server41tests/st_destroy_session.py
@@ -164,6 +164,3 @@ def testDestoryNotSoleOps(t, env):
     sid = sess1.sessionid
     res = c.c.compound([op.destroy_session(sess1.sessionid), op.putrootfh()])
     check(res, NFS4ERR_NOT_ONLY_OP)
-
-    res = c.c.compound([op.putrootfh(), op.destroy_session(sess1.sessionid)])
-    check(res, NFS4ERR_NOT_ONLY_OP)
-- 
1.8.3.1

