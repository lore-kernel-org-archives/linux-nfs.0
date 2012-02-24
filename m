Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:45448 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750792Ab2BXFBE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 24 Feb 2012 00:01:04 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 4/5] 4.1 server tests: allow SYMLINK error on rename
Date: Fri, 24 Feb 2012 00:00:59 -0500
Message-Id: <1330059660-2053-5-git-send-email-bfields@redhat.com>
In-Reply-To: <1330059660-2053-1-git-send-email-bfields@redhat.com>
References: <1330059660-2053-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Yes, 5661 does say to return NOTDIR in this case.  But I can't figure
out why.  Elsewhere it's generally preferred to return the more specific
SYMLINK error.  This is a buggy-client case (since the source and target
dirs are referred to by filehandle, the client should generally know
whether it's dealing with a directory or not), so I don't see the point
of being really picky here.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 nfs4.1/server41tests/st_rename.py |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/nfs4.1/server41tests/st_rename.py b/nfs4.1/server41tests/st_rename.py
index f706a1c..cde8ffc 100644
--- a/nfs4.1/server41tests/st_rename.py
+++ b/nfs4.1/server41tests/st_rename.py
@@ -201,7 +201,8 @@ def testCfhLink(t, env):
     res = create_obj(sess, env.c1.homedir + [name])
     check(res)
     res = rename_obj(sess, env.c1.homedir + [name], env.opts.uselink + [name])
-    check(res, NFS4ERR_NOTDIR, "RENAME with non-dir <cfh>")
+    checklist(res, [NFS4ERR_NOTDIR, NFS4ERR_SYMLINK],
+                                "RENAME with non-dir <cfh>")
 
 def testCfhBlock(t, env):
     """RENAME with non-dir (cfh) should return NFS4ERR_NOTDIR
-- 
1.7.7.6

