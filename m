Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:49691 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752343Ab1CBGgc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Mar 2011 01:36:32 -0500
Message-ID: <4D6DE599.3080600@cn.fujitsu.com>
Date: Wed, 02 Mar 2011 14:37:13 +0800
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: NFS <linux-nfs@vger.kernel.org>
Subject: [PATCH 17/17] CLNT: test EXCLUSIVE4_1 for different verifier
References: <4D6DE26C.3010103@cn.fujitsu.com>
In-Reply-To: <4D6DE26C.3010103@cn.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
---
 nfs4.1/server41tests/environment.py |    5 +++--
 nfs4.1/server41tests/st_open.py     |   18 ++++++++++++++++++
 2 files changed, 21 insertions(+), 2 deletions(-)

diff --git a/nfs4.1/server41tests/environment.py b/nfs4.1/server41tests/environment.py
index e961082..b8e2508 100644
--- a/nfs4.1/server41tests/environment.py
+++ b/nfs4.1/server41tests/environment.py
@@ -458,13 +458,14 @@ def create_file(sess, owner, path=None, attrs={FATTR4_MODE: 0644},
     else:
         dir = path[:-1]
         name = path[-1]
-    if (mode==EXCLUSIVE4) and (verifier==None):
+    if ((mode==EXCLUSIVE4) or (mode==EXCLUSIVE4_1)) and (verifier==None):
         verifier = sess.c.verifier
     if not want_deleg and access & OPEN4_SHARE_ACCESS_WANT_DELEG_MASK == 0:
         access |= OPEN4_SHARE_ACCESS_WANT_NO_DELEG
     # Create the file
     open_op = op.open(seqid, access, deny, open_owner4(clientid, owner),
-                      openflag4(OPEN4_CREATE, createhow4(mode, attrs, verifier)),
+                      openflag4(OPEN4_CREATE, createhow4(mode, attrs, verifier,
+                                               creatverfattr(verifier, attrs))),
                       open_claim4(CLAIM_NULL, name))
     return sess.compound(use_obj(dir) + [open_op, op.getfh()])
 
diff --git a/nfs4.1/server41tests/st_open.py b/nfs4.1/server41tests/st_open.py
index d5900db..5d8b6b2 100644
--- a/nfs4.1/server41tests/st_open.py
+++ b/nfs4.1/server41tests/st_open.py
@@ -2,6 +2,7 @@ from st_create_session import create_session
 from nfs4_const import *
 from environment import check, checklist, fail, create_file, open_file
 from nfs4_type import open_owner4, openflag4, createhow4, open_claim4
+from nfs4_type import creatverfattr, fattr4
 import nfs4_ops as op
 import threading
 
@@ -201,3 +202,20 @@ def testReadWrite(t, env):
     if res.resarray[-1].data != desired:
         fail("Expected %r, got %r" % (desired, res.resarray[-1].data))
 
+def testEXCLUSIVE4AtNameAttribute(t, env):
+    """If the file does exist,but the stored verifier does not match,
+       then an error of NFS4ERR_EXIST is returned from server. 
+       rfc5661 18.16.3
+
+    FLAGS: open all
+    CODE: OPEN6
+    """
+    c1 = env.c1.new_client(env.testname(t))
+    sess1 = c1.create_session()
+
+    res = create_file(sess1, env.testname(t), mode=EXCLUSIVE4_1)
+    check(res)
+
+    res = create_file(sess1, env.testname(t), mode=EXCLUSIVE4_1,
+                        verifier = "Justtest")
+    check(res, NFS4ERR_EXIST)
-- 
1.7.4.1



