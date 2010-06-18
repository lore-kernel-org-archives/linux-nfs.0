From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH] TESTS: Allow server to reject commits with large offsets
Date: Fri, 18 Jun 2010 08:44:54 -0400
Message-ID: <20100618124454.GC10887@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, Muneet Parhar <mparhar@umich.edu>
To: iisaman@umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:41456 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932106Ab0FRMoz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 18 Jun 2010 08:44:55 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Muneet Parhar <mparhar@umich.edu>

These two tests insist (incorrectly) that a server must accept commits
with offset 2^64-1 and 2^64-2.

The linux server was recently changed to reject (with INVAL) offsets
over 2^63-1, which is the maximum that the vfs commit routine can
accept.  That behavior is consistent with the NFSv3 commit
implementation and with the NFSv4 write implementation.

The maximum supported offset may vary depending on filesystem or server,
so we should allow either success or INVAL here.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 lib/nfs4/servertests/st_commit.py |   11 +++++------
 1 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/lib/nfs4/servertests/st_commit.py b/lib/nfs4/servertests/st_commit.py
index 2955d79..b7f536e 100644
--- a/lib/nfs4/servertests/st_commit.py
+++ b/lib/nfs4/servertests/st_commit.py
@@ -1,9 +1,9 @@
 from nfs4.nfs4_const import *
-from environment import check
+from environment import check, checklist
 
 _text = "Random data to write"
 
-def _commit(t, c, offset=0, count=0):
+def _commit(t, c, offset=0, count=0, statlist=[NFS4_OK]):
     """COMMIT
 
     FLAGS: commit all
@@ -15,7 +15,7 @@ def _commit(t, c, offset=0, count=0):
     res = c.write_file(fh, _text, 0, stateid, how=UNSTABLE4)
     check(res, msg="WRITE with how=UNSTABLE4")
     res = c.commit_file(fh, offset, count)
-    check(res, msg="COMMIT with offset=%x, count=%x" % (offset, count))
+    checklist(res, statlist, msg="COMMIT with offset=%x, count=%x" % (offset, count))
 
 def testCommitOffset0(t, env):
     """COMMIT
@@ -42,7 +42,7 @@ def testCommitOffsetMax1(t, env):
     DEPEND: MKFILE
     CODE: CMT1c
     """
-    _commit(t, env.c1, 0xffffffffffffffffL)
+    _commit(t, env.c1, 0xffffffffffffffffL, statlist=[NFS4_OK, NFS4ERR_INVAL])
 
 def testCommitOffsetMax2(t, env):
     """COMMIT
@@ -51,7 +51,7 @@ def testCommitOffsetMax2(t, env):
     DEPEND: MKFILE
     CODE: CMT1d
     """
-    _commit(t, env.c1, 0xfffffffffffffffeL)
+    _commit(t, env.c1, 0xfffffffffffffffeL, statlist=[NFS4_OK, NFS4ERR_INVAL])
 
 def testCommitCount1(t, env):
     """COMMIT
@@ -71,7 +71,6 @@ def testCommitCountMax(t, env):
     """
     _commit(t, env.c1, 0, 0xffffffffL)
 
-
 def testLink(t, env):
     """COMMIT
 
-- 
1.7.0.4

