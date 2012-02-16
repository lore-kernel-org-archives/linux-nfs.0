Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ey0-f174.google.com ([209.85.215.174]:42443 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753062Ab2BPSR0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Feb 2012 13:17:26 -0500
Received: by mail-ey0-f174.google.com with SMTP id h12so968126eaa.19
        for <linux-nfs@vger.kernel.org>; Thu, 16 Feb 2012 10:17:25 -0800 (PST)
From: Benny Halevy <benny@tonian.com>
To: bfields@redhat.com
Cc: linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@tonian.com>
Subject: [PATCH 3/5] 4.1 server tests: testWriteDeleg
Date: Thu, 16 Feb 2012 20:17:22 +0200
Message-Id: <1329416242-21186-1-git-send-email-bhalevy@tonian.com>
In-Reply-To: <4F3D47B3.1090708@tonian.com>
References: <4F3D47B3.1090708@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 nfs4.1/server41tests/st_delegation.py |   45 +++++++++++++++++++++++++++++++++
 1 files changed, 45 insertions(+), 0 deletions(-)

diff --git a/nfs4.1/server41tests/st_delegation.py b/nfs4.1/server41tests/st_delegation.py
index b9f866f..1011cbc 100644
--- a/nfs4.1/server41tests/st_delegation.py
+++ b/nfs4.1/server41tests/st_delegation.py
@@ -52,3 +52,48 @@ def testReadDeleg(t, env):
     # Now get OPEN reply
     res = sess2.listen(slot)
     checklist(res, [NFS4_OK, NFS4ERR_DELAY])
+
+def testWriteDeleg(t, env):
+    """Test write delgation handout and return
+
+    FLAGS: open deleg all
+    CODE: DELEG2
+    """
+    recall = threading.Event()
+    def pre_hook(arg, env):
+        recall.stateid = arg.stateid # NOTE this must be done before set()
+        env.notify = recall.set # This is called after compound sent to queue
+    def post_hook(arg, env, res):
+        return res
+    # c1 - OPEN - WRITE
+    c1 = env.c1.new_client("%s_1" % env.testname(t))
+    c1.cb_pre_hook(OP_CB_RECALL, pre_hook)
+    c1.cb_post_hook(OP_CB_RECALL, post_hook)
+    sess1 = c1.create_session()
+    sess1.compound([op.reclaim_complete(FALSE)])
+    res = create_file(sess1, env.testname(t),
+                      access=OPEN4_SHARE_ACCESS_BOTH |
+                      OPEN4_SHARE_ACCESS_WANT_WRITE_DELEG)
+    check(res)
+    fh = res.resarray[-1].object
+    deleg = res.resarray[-2].delegation
+    if deleg.delegation_type == OPEN_DELEGATE_NONE or deleg.delegation_type == OPEN_DELEGATE_NONE_EXT:
+        fail("Could not get delegation")
+    # c2 - OPEN - READ
+    sess2 = env.c1.new_client_session("%s_2" % env.testname(t))
+    claim = open_claim4(CLAIM_NULL, env.testname(t))
+    owner = open_owner4(0, "My Open Owner 2")
+    how = openflag4(OPEN4_NOCREATE)
+    open_op = op.open(0, OPEN4_SHARE_ACCESS_READ, OPEN4_SHARE_DENY_NONE,
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
-- 
1.7.6.5

