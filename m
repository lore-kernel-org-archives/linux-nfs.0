Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ey0-f174.google.com ([209.85.215.174]:42443 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752284Ab2BPSRR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Feb 2012 13:17:17 -0500
Received: by mail-ey0-f174.google.com with SMTP id h12so968126eaa.19
        for <linux-nfs@vger.kernel.org>; Thu, 16 Feb 2012 10:17:16 -0800 (PST)
From: Benny Halevy <benny@tonian.com>
To: bfields@redhat.com
Cc: linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@tonian.com>
Subject: [PATCH 2/5] 4.1 server tests: move testReadDeleg from st_open to st_delegation
Date: Thu, 16 Feb 2012 20:17:13 +0200
Message-Id: <1329416233-21148-1-git-send-email-bhalevy@tonian.com>
In-Reply-To: <4F3D47B3.1090708@tonian.com>
References: <4F3D47B3.1090708@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 nfs4.1/server41tests/__init__.py      |    1 +
 nfs4.1/server41tests/st_delegation.py |   54 +++++++++++++++++++++++++++++++++
 nfs4.1/server41tests/st_open.py       |   45 ---------------------------
 3 files changed, 55 insertions(+), 45 deletions(-)
 create mode 100644 nfs4.1/server41tests/st_delegation.py

diff --git a/nfs4.1/server41tests/__init__.py b/nfs4.1/server41tests/__init__.py
index 2bedb57..9d260a4 100644
--- a/nfs4.1/server41tests/__init__.py
+++ b/nfs4.1/server41tests/__init__.py
@@ -9,6 +9,7 @@ __all__ = ["st_exchange_id.py", # draft 21
            "st_sequence.py",
 	   "st_trunking.py",
            "st_open.py",
+           "st_delegation.py",
            "st_verify.py",
            "st_getdevicelist.py",
            "st_lookupp.py",
diff --git a/nfs4.1/server41tests/st_delegation.py b/nfs4.1/server41tests/st_delegation.py
new file mode 100644
index 0000000..b9f866f
--- /dev/null
+++ b/nfs4.1/server41tests/st_delegation.py
@@ -0,0 +1,54 @@
+from st_create_session import create_session
+from st_open import open_claim4
+from nfs4_const import *
+
+from environment import check, checklist, fail, create_file, open_file, close_file
+from nfs4_type import open_owner4, openflag4, createhow4, open_claim4
+from nfs4_type import creatverfattr, fattr4, stateid4, locker4, lock_owner4
+import nfs4_ops as op
+import threading
+
+def testReadDeleg(t, env):
+    """Test read delgation handout and return
+
+    FLAGS: open deleg all
+    CODE: DELEG1
+    """
+    recall = threading.Event()
+    def pre_hook(arg, env):
+        recall.stateid = arg.stateid # NOTE this must be done before set()
+        env.notify = recall.set # This is called after compound sent to queue
+    def post_hook(arg, env, res):
+        return res
+    # c1 - OPEN - READ
+    c1 = env.c1.new_client("%s_1" % env.testname(t))
+    c1.cb_pre_hook(OP_CB_RECALL, pre_hook)
+    c1.cb_post_hook(OP_CB_RECALL, post_hook)
+    sess1 = c1.create_session()
+    sess1.compound([op.reclaim_complete(FALSE)])
+    res = create_file(sess1, env.testname(t),
+                      access=OPEN4_SHARE_ACCESS_READ |
+                      OPEN4_SHARE_ACCESS_WANT_READ_DELEG)
+    check(res)
+    fh = res.resarray[-1].object
+    deleg = res.resarray[-2].delegation
+    if deleg.delegation_type == OPEN_DELEGATE_NONE or deleg.delegation_type == OPEN_DELEGATE_NONE_EXT:
+        fail("Could not get delegation")
+    # c2 - OPEN - WRITE
+    sess2 = env.c1.new_client_session("%s_2" % env.testname(t))
+    claim = open_claim4(CLAIM_NULL, env.testname(t))
+    owner = open_owner4(0, "My Open Owner 2")
+    how = openflag4(OPEN4_NOCREATE)
+    open_op = op.open(0, OPEN4_SHARE_ACCESS_BOTH, OPEN4_SHARE_DENY_NONE,
+                      owner, how, claim)
+    slot = sess2.compound_async(env.home + [open_op])
+    # Wait for recall, and return delegation
+    recall.wait() # STUB - deal with timeout
+    # Getting here means CB_RECALL reply is in the send queue.
+    # Give it a moment to actually be sent
+    env.sleep(1)
+    res = sess1.compound([op.putfh(fh), op.delegreturn(recall.stateid)])
+    check(res)
+    # Now get OPEN reply
+    res = sess2.listen(slot)
+    checklist(res, [NFS4_OK, NFS4ERR_DELAY])
diff --git a/nfs4.1/server41tests/st_open.py b/nfs4.1/server41tests/st_open.py
index c64a7ef..862ec95 100644
--- a/nfs4.1/server41tests/st_open.py
+++ b/nfs4.1/server41tests/st_open.py
@@ -117,51 +117,6 @@ def xtestOpenClientid(t, env):
     res = create_file(sess1, env.testname(t), clientid=c1.clientid)
     check(res, NFS4ERR_INVAL, msg="Using non-zero clientid in open_owner")
 
-def testReadDeleg(t, env):
-    """Test read delgation handout and return
-
-    FLAGS: open all
-    CODE: OPEN20
-    """
-    recall = threading.Event()
-    def pre_hook(arg, env):
-        recall.stateid = arg.stateid # NOTE this must be done before set()
-        env.notify = recall.set # This is called after compound sent to queue
-    def post_hook(arg, env, res):
-        return res
-    # c1 - OPEN - READ
-    c1 = env.c1.new_client("%s_1" % env.testname(t))
-    c1.cb_pre_hook(OP_CB_RECALL, pre_hook)
-    c1.cb_post_hook(OP_CB_RECALL, post_hook)
-    sess1 = c1.create_session()
-    sess1.compound([op.reclaim_complete(FALSE)])
-    res = create_file(sess1, env.testname(t),
-                      access=OPEN4_SHARE_ACCESS_READ |
-                      OPEN4_SHARE_ACCESS_WANT_READ_DELEG)
-    check(res)
-    fh = res.resarray[-1].object
-    deleg = res.resarray[-2].delegation
-    if deleg.delegation_type == OPEN_DELEGATE_NONE or deleg.delegation_type == OPEN_DELEGATE_NONE_EXT:
-        fail("Could not get delegation")
-    # c2 - OPEN - WRITE
-    sess2 = env.c1.new_client_session("%s_2" % env.testname(t))
-    claim = open_claim4(CLAIM_NULL, env.testname(t))
-    owner = open_owner4(0, "My Open Owner 2")
-    how = openflag4(OPEN4_NOCREATE)
-    open_op = op.open(0, OPEN4_SHARE_ACCESS_BOTH, OPEN4_SHARE_DENY_NONE,
-                      owner, how, claim)
-    slot = sess2.compound_async(env.home + [open_op])
-    # Wait for recall, and return delegation
-    recall.wait() # STUB - deal with timeout
-    # Getting here means CB_RECALL reply is in the send queue.
-    # Give it a moment to actually be sent
-    env.sleep(1)
-    res = sess1.compound([op.putfh(fh), op.delegreturn(recall.stateid)])
-    check(res)
-    # Now get OPEN reply
-    res = sess2.listen(slot)
-    checklist(res, [NFS4_OK, NFS4ERR_DELAY])
-
 def testReadWrite(t, env):
     """Do a simple READ and WRITE
 
-- 
1.7.6.5

