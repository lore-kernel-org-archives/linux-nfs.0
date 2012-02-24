Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:45442 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750721Ab2BXFBE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 24 Feb 2012 00:01:04 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 1/5] 4.1 server tests: rename tests incorrectly using root dir
Date: Fri, 24 Feb 2012 00:00:56 -0500
Message-Id: <1330059660-2053-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1330059660-2053-1-git-send-email-bfields@redhat.com>
References: <1330059660-2053-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Several of the rename tests were incorrectly creating objects in the
export root.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 nfs4.1/server41tests/st_rename.py |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/nfs4.1/server41tests/st_rename.py b/nfs4.1/server41tests/st_rename.py
index ed5dbb5..f706a1c 100644
--- a/nfs4.1/server41tests/st_rename.py
+++ b/nfs4.1/server41tests/st_rename.py
@@ -185,7 +185,7 @@ def testCfhFile(t, env):
     """
     name = env.testname(t)
     sess = env.c1.new_client_session(name)
-    res = create_obj(sess, [name])
+    res = create_obj(sess, env.c1.homedir + [name])
     check(res)
     res = rename_obj(sess, env.c1.homedir + [name], env.opts.usefile + [name])
     check(res, NFS4ERR_NOTDIR, "RENAME with non-dir <cfh>")
@@ -198,7 +198,7 @@ def testCfhLink(t, env):
     """
     name = env.testname(t)
     sess = env.c1.new_client_session(name)
-    res = create_obj(sess, [name])
+    res = create_obj(sess, env.c1.homedir + [name])
     check(res)
     res = rename_obj(sess, env.c1.homedir + [name], env.opts.uselink + [name])
     check(res, NFS4ERR_NOTDIR, "RENAME with non-dir <cfh>")
@@ -211,7 +211,7 @@ def testCfhBlock(t, env):
     """
     name = env.testname(t)
     sess = env.c1.new_client_session(name)
-    res = create_obj(sess, [name])
+    res = create_obj(sess, env.c1.homedir + [name])
     check(res)
     res = rename_obj(sess, env.c1.homedir + [name], env.opts.useblock + [name])
     check(res, NFS4ERR_NOTDIR, "RENAME with non-dir <cfh>")
@@ -224,7 +224,7 @@ def testCfhChar(t, env):
     """
     name = env.testname(t)
     sess = env.c1.new_client_session(name)
-    res = create_obj(sess, [name])
+    res = create_obj(sess, env.c1.homedir + [name])
     check(res)
     res = rename_obj(sess, env.c1.homedir + [name], env.opts.usechar + [name])
     check(res, NFS4ERR_NOTDIR, "RENAME with non-dir <cfh>")
@@ -237,7 +237,7 @@ def testCfhFifo(t, env):
     """
     name = env.testname(t)
     sess = env.c1.new_client_session(name)
-    res = create_obj(sess, [name])
+    res = create_obj(sess, env.c1.homedir + [name])
     check(res)
     res = rename_obj(sess, env.c1.homedir + [name], env.opts.usefifo + [name])
     check(res, NFS4ERR_NOTDIR, "RENAME with non-dir <cfh>")
@@ -250,7 +250,7 @@ def testCfhSocket(t, env):
     """
     name = env.testname(t)
     sess = env.c1.new_client_session(name)
-    res = create_obj(sess, [name])
+    res = create_obj(sess, env.c1.homedir + [name])
     check(res)
     res = rename_obj(sess, env.c1.homedir + [name], env.opts.usesocket + [name])
     check(res, NFS4ERR_NOTDIR, "RENAME with non-dir <cfh>")
-- 
1.7.7.6

