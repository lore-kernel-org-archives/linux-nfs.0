Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:45450 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750797Ab2BXFBE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 24 Feb 2012 00:01:04 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/5] 4.1 server tests: maketree should not leave files open
Date: Fri, 24 Feb 2012 00:00:57 -0500
Message-Id: <1330059660-2053-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1330059660-2053-1-git-send-email-bfields@redhat.com>
References: <1330059660-2053-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

In particular this causes spurious failures against any server that does
not allow renames of open files.

There are probably many more places where we should really be doing
closes.

Note: it might also be interesting to do a purely informational test to
determine whether a server allows renames of open files.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 nfs4.1/server41tests/environment.py |   14 +++++++++++++-
 1 files changed, 13 insertions(+), 1 deletions(-)

diff --git a/nfs4.1/server41tests/environment.py b/nfs4.1/server41tests/environment.py
index e9d2237..2566274 100644
--- a/nfs4.1/server41tests/environment.py
+++ b/nfs4.1/server41tests/environment.py
@@ -550,6 +550,18 @@ def create_confirm(sess, owner, path=None, attrs={FATTR4_MODE: 0644},
     return fh, res.resarray[-2].stateid
     return fh, openstateid
 
+def create_close(sess, owner, path=None, attrs={FATTR4_MODE: 0644},
+                   access=OPEN4_SHARE_ACCESS_BOTH,
+                   deny=OPEN4_SHARE_DENY_NONE,
+                   mode=GUARDED4):
+    """Create (using open) a regular file, confirm the open, and close
+
+    Returns the fhandle
+    """
+    fh, stateid = create_confirm(sess, owner, path, attrs, access, deny, mode)
+    close_file(sess, fh, stateid=stateid)
+    return fh;
+
 def _getname(owner, path):
     if path is None:
         return owner
@@ -580,7 +592,7 @@ def maketree(sess, tree, root=None, owner=None):
             check(res)
             maketree(sess, obj[1:], root + [obj[0]], owner)
         else:
-            create_confirm(sess, owner, root + [obj])
+            create_close(sess, owner, root + [obj])
 
 def lookup_obj(sess, path):
     compound = [op.putrootfh()]
-- 
1.7.7.6

