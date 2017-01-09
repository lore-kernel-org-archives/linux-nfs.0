Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-o-3.desy.de ([131.169.56.156]:32820 "EHLO smtp-o-3.desy.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S970035AbdAIPZy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 9 Jan 2017 10:25:54 -0500
Received: from smtp-map-3.desy.de (smtp-map-3.desy.de [131.169.56.68])
        by smtp-o-3.desy.de (DESY-O-3) with ESMTP id 98D3D280352
        for <linux-nfs@vger.kernel.org>; Mon,  9 Jan 2017 16:16:17 +0100 (CET)
Received: from ZITSWEEP2.win.desy.de (zitsweep2.win.desy.de [131.169.97.96])
        by smtp-map-3.desy.de (DESY_MAP_3) with ESMTP id 8A8A911C9
        for <linux-nfs@vger.kernel.org>; Mon,  9 Jan 2017 16:16:17 +0100 (MET)
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Subject: [PATCH] setattr: test how v4.0 server handles setting of zero length principals
Date: Mon,  9 Jan 2017 16:15:56 +0100
Message-Id: <20170109151556.7522-1-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

my interpretation of rfc3530 expects NFS4ERR_INVAL is owner and
owner_group are empty strings.

Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
---
 nfs4.0/servertests/st_setattr.py | 31 +++++++++++++++++++++++++++++++
 1 file changed, 31 insertions(+)

diff --git a/nfs4.0/servertests/st_setattr.py b/nfs4.0/servertests/st_setattr.py
index b6a398b..b192ece 100644
--- a/nfs4.0/servertests/st_setattr.py
+++ b/nfs4.0/servertests/st_setattr.py
@@ -701,3 +701,34 @@ def testChangeGranularity(t, env):
     chattr4 = res.resarray[7].obj_attributes
     if chattr1 == chattr2 or chattr2 == chattr3 or chattr3 == chattr4:
         t.fail("consecutive SETATTR(mode)'s don't all change change attribute")
+
+def testEmptyPrincipal(t, env):
+    """Setting owner with zero length principal must fail
+
+    FLAGS: setattr all
+    DEPEND: MKFILE
+    CODE: SATT16
+    """
+    c = env.c1
+    path = c.homedir + [t.code]
+    res = c.create_obj(path, NF4SOCK)
+    check(res)
+    ops = c.use_obj(path) + [c.setattr({FATTR4_OWNER: ''})]
+    res = c.compound(ops)
+    check(res, NFS4ERR_INVAL, "Setting empty owner")
+
+
+def testEmptyGroupPrincipal(t, env):
+    """Setting owner group with zero length principal must fail
+
+    FLAGS: setattr all
+    DEPEND: MKFILE
+    CODE: SATT17
+    """
+    c = env.c1
+    path = c.homedir + [t.code]
+    res = c.create_obj(path, NF4SOCK)
+    check(res)
+    ops = c.use_obj(path) + [c.setattr({FATTR4_OWNER_GROUP: ''})]
+    res = c.compound(ops)
+    check(res, NFS4ERR_INVAL, "Setting empty owner_group")
-- 
2.9.3

