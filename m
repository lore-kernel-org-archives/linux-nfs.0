Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:59032 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755080Ab1G1UDR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 Jul 2011 16:03:17 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Fred Isaman <iisaman@netapp.com>
Cc: linux-nfs@vger.kernel.org, Mi Jinlong <mijinlong@cn.fujitsu.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/6] CLNT: send RECLAIM_COMPLETE when required
Date: Thu, 28 Jul 2011 16:03:00 -0400
Message-Id: <1311883384-20260-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1311883384-20260-1-git-send-email-bfields@redhat.com>
References: <1311883384-20260-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

All tests fail against any server which (correctly) enforces the
requirement that a RECLAIM_COMPLETE precede any client's first
non-reclaim OPEN.

Mi Jinlong suggested putting the RECLAIM_COMPLETE in create_file, which
works well since create_file almost always generates the first such
open.

But that seems like an odd place to put what is really a sort of
initialization.  Whether many exist now, there will eventually be tests
that don't start with create_file, or that create multiple files.

So, instead, use the just-added new_client_session method.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 nfs4.1/nfs4client.py                |    1 +
 nfs4.1/server41tests/st_open.py     |    2 ++
 nfs4.1/server41tests/st_sequence.py |    1 +
 3 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/nfs4.1/nfs4client.py b/nfs4.1/nfs4client.py
index e162e70..5b9c14f 100644
--- a/nfs4.1/nfs4client.py
+++ b/nfs4.1/nfs4client.py
@@ -292,6 +292,7 @@ class NFS4Client(rpc.Client, rpc.Server):
     def new_client_session(self, name, flags=0):
         c = self.new_client(name, flags=flags)
         s = c.create_session()
+        s.compound([op.reclaim_complete(FALSE)])
         return s
 
 class ClientStateProtection(object):
diff --git a/nfs4.1/server41tests/st_open.py b/nfs4.1/server41tests/st_open.py
index b599b04..2aa3ec4 100644
--- a/nfs4.1/server41tests/st_open.py
+++ b/nfs4.1/server41tests/st_open.py
@@ -110,6 +110,7 @@ def xtestOpenClientid(t, env):
         # If by coincidence clientid==0, make a new client
         c1 = env.c1.new_client("%s_2" % name)
     sess1 = c1.create_session()
+    sess1.compound([op.reclaim_complete(FALSE)])
     res = create_file(sess1, env.testname(t), clientid=c1.clientid)
     check(res, NFS4ERR_INVAL, msg="Using non-zero clientid in open_owner")
 
@@ -130,6 +131,7 @@ def testReadDeleg(t, env):
     c1.cb_pre_hook(OP_CB_RECALL, pre_hook)
     c1.cb_post_hook(OP_CB_RECALL, post_hook)
     sess1 = c1.create_session()
+    sess1.compound([op.reclaim_complete(FALSE)])
     res = create_file(sess1, env.testname(t),
                       access=OPEN4_SHARE_ACCESS_READ |
                       OPEN4_SHARE_ACCESS_WANT_READ_DELEG)
diff --git a/nfs4.1/server41tests/st_sequence.py b/nfs4.1/server41tests/st_sequence.py
index f4f6772..2362fb6 100644
--- a/nfs4.1/server41tests/st_sequence.py
+++ b/nfs4.1/server41tests/st_sequence.py
@@ -373,6 +373,7 @@ def testReuseSlotID(t, env):
     c = env.c1.new_client(env.testname(t))
     sess1 = c.create_session()
     sess1 = env.c1.new_client_session(env.testname(t))
+    sess1.compound([op.reclaim_complete(FALSE)])
 
     name = "%s_1" % env.testname(t)
     res = create_file(sess1, name)
-- 
1.7.4.1

