Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-oa0-f45.google.com ([209.85.219.45]:38811 "EHLO
	mail-oa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751455AbaEQCSp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 16 May 2014 22:18:45 -0400
Received: by mail-oa0-f45.google.com with SMTP id l6so3927164oag.18
        for <linux-nfs@vger.kernel.org>; Fri, 16 May 2014 19:18:45 -0700 (PDT)
Message-ID: <5376C6F8.4090904@gmail.com>
Date: Sat, 17 May 2014 10:18:32 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org, kinglongmee@gmail.com
Subject: [PATCH 1/3 v2] NFS4.0: Case for linking to bad source path with zero-length
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Same as v1.

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

