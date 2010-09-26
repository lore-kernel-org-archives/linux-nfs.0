Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:40644 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754674Ab0IZRCZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 26 Sep 2010 13:02:25 -0400
Received: from bfields by fieldses.org with local (Exim 4.71)
	(envelope-from <bfields@fieldses.org>)
	id 1Ozuai-0008F8-Hb
	for linux-nfs@vger.kernel.org; Sun, 26 Sep 2010 13:00:44 -0400
Date: Sun, 26 Sep 2010 12:59:38 -0400
From: linux-nfs-owner@vger.kernel.org
To: Fred Isaman <iisaman@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] CLNT: Turn on cache_this for specific tests
Message-ID: <20100926165938.GC25106@fieldses.org>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: J. Bruce Fields <bfields@redhat.com>

A previous patch turned this off by default; but we need it back on for
anything that tests the reply cache.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 nfs4.1/server41tests/st_sequence.py |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

Also available from:

	git://linux-nfs.org/~bfields/pynfs41.git

I've also done a little more triage of the results and turned on another
36 of the pynfs41 tests in my server regression testing:

	git://linux-nfs.org/~bfields/testd.git

--b.

diff --git a/nfs4.1/server41tests/st_sequence.py b/nfs4.1/server41tests/st_sequence.py
index f939408..a5e344d 100644
--- a/nfs4.1/server41tests/st_sequence.py
+++ b/nfs4.1/server41tests/st_sequence.py
@@ -191,7 +191,7 @@ def testReplayCache001(t, env):
     """
     c1 = env.c1.new_client(env.testname(t))
     sess1 = c1.create_session()
-    res1 = sess1.compound([op.putrootfh()])
+    res1 = sess1.compound([op.putrootfh()], cache_this=True)
     check(res1)
     res2 = sess1.compound([op.putrootfh()], seq_delta=0)
     check(res2)
@@ -211,7 +211,7 @@ def testReplayCache002(t, env):
     check(res)
     ops = env.home + [op.savefh(),\
           op.rename("%s_1" % env.testname(t), "%s_2" % env.testname(t))]
-    res1 = sess1.compound(ops)
+    res1 = sess1.compound(ops, cache_this=True)
     check(res1)
     res2 = sess1.compound(ops, seq_delta=0)
     check(res2)
@@ -227,7 +227,7 @@ def testReplayCache003(t, env):
     """
     c1 = env.c1.new_client(env.testname(t))
     sess1 = c1.create_session()
-    res1 = sess1.compound([op.putrootfh(), op.lookup("")])
+    res1 = sess1.compound([op.putrootfh(), op.lookup("")], cache_this=True)
     check(res1, NFS4ERR_INVAL)
     res2 = sess1.compound([op.putrootfh(), op.lookup("")], seq_delta=0)
     check(res2, NFS4ERR_INVAL)
@@ -244,7 +244,7 @@ def testReplayCache004(t, env):
     c1 = env.c1.new_client(env.testname(t))
     sess1 = c1.create_session()
     ops = [op.putrootfh(), op.savefh(), op.rename("", "foo")]
-    res1 = sess1.compound(ops)
+    res1 = sess1.compound(ops, cache_this=True)
     check(res1, NFS4ERR_INVAL)
     res2 = sess1.compound(ops, seq_delta=0)
     check(res2, NFS4ERR_INVAL)
@@ -260,7 +260,7 @@ def testReplayCache005(t, env):
     """
     c1 = env.c1.new_client(env.testname(t))
     sess1 = c1.create_session()
-    res1 = sess1.compound([op.illegal()])
+    res1 = sess1.compound([op.illegal()], cache_this=True)
     check(res1, NFS4ERR_OP_ILLEGAL)
     res2 = sess1.compound([op.illegal()], seq_delta=0)
     check(res2, NFS4ERR_OP_ILLEGAL)
-- 
1.7.0.4

