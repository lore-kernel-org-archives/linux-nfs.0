Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f51.google.com ([209.85.160.51]:61554 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753094AbaDXK6E (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Apr 2014 06:58:04 -0400
Received: by mail-pb0-f51.google.com with SMTP id uo5so1831297pbc.10
        for <linux-nfs@vger.kernel.org>; Thu, 24 Apr 2014 03:58:04 -0700 (PDT)
Message-ID: <5358EE2F.9070301@gmail.com>
Date: Thu, 24 Apr 2014 18:57:51 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org
Subject: [PATCH 1/3] NFS4.0: Case for linking to bad source patch with zero-length
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 nfs4.0/servertests/st_create.py | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/nfs4.0/servertests/st_create.py b/nfs4.0/servertests/st_create.py
index d2d6701..09c80cc 100644
--- a/nfs4.0/servertests/st_create.py
+++ b/nfs4.0/servertests/st_create.py
@@ -161,6 +161,19 @@ def testZeroLength(t, env):
     res = c.create_obj(c.homedir + [''])
     check(res, NFS4ERR_INVAL, "CREATE with zero-length name")
 
+def testZeroLengthForLNK(t, env):
+    """CREATE with zero length name should return NFS4ERR_INVAL
+
+    FLAGS: create symlink all
+    CODE: CR9a
+    """
+    c = env.c1
+    ops = c.go_home()
+    objtype = createtype4(NF4LNK, **{'linkdata':''})
+    ops += [c.create_op(objtype, t.code, getDefaultAttr(c))]
+    res = c.compound(ops)
+    check(res, NFS4ERR_INVAL, "CREATE with zero-length name for SYMLINK")
+
 def testRegularFile(t, env):
     """CREATE should fail with NFS4ERR_BADTYPE for regular files
 
-- 
1.9.0

