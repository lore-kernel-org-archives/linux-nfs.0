Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:59148 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751145Ab0BIUMI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Feb 2010 15:12:08 -0500
Date: Tue, 9 Feb 2010 15:12:31 -0500
To: iisaman@citi.umich.edu
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH pynfs] Allow server to reject maximum commit offsets
Message-ID: <20100209201231.GC30951@fieldses.org>
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: J. Bruce Fields <bfields@citi.umich.edu>

These two tests insist that a server must accept commits with offset
2^64-1 and 2^64-2.  I can find no justification in the spec for this
requirement.

The linux server was recently changed to reject (with INVAL) offsets
over 2^63-1, which is the maximum that the vfs commit routine can
accept.  That behavior is consistent with the NFSv3 commit
implementation and with the NFSv4 write implementation.

The maximum offset allowed may vary depending on filesystem or server,
so I think it's simplest just to delete these tests.  (Alternatively, we
could replace the offset by whatever we consider a reasonable least
common denominator, e.g. 2^31-1.)

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 lib/nfs4/servertests/st_commit.py |   18 ------------------
 1 files changed, 0 insertions(+), 18 deletions(-)

diff --git a/lib/nfs4/servertests/st_commit.py b/lib/nfs4/servertests/st_commit.py
index 2955d79..0005e54 100644
--- a/lib/nfs4/servertests/st_commit.py
+++ b/lib/nfs4/servertests/st_commit.py
@@ -35,24 +35,6 @@ def testCommitOffset1(t, env):
     """
     _commit(t, env.c1, 1)
 
-def testCommitOffsetMax1(t, env):
-    """COMMIT
-
-    FLAGS: commit all
-    DEPEND: MKFILE
-    CODE: CMT1c
-    """
-    _commit(t, env.c1, 0xffffffffffffffffL)
-
-def testCommitOffsetMax2(t, env):
-    """COMMIT
-
-    FLAGS: commit all
-    DEPEND: MKFILE
-    CODE: CMT1d
-    """
-    _commit(t, env.c1, 0xfffffffffffffffeL)
-
 def testCommitCount1(t, env):
     """COMMIT
 
-- 
1.6.3.3

