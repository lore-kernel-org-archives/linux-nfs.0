Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f46.google.com ([74.125.83.46]:54811 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754116Ab2BPSRo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Feb 2012 13:17:44 -0500
Received: by eekc14 with SMTP id c14so993057eek.19
        for <linux-nfs@vger.kernel.org>; Thu, 16 Feb 2012 10:17:42 -0800 (PST)
From: Benny Halevy <benny@tonian.com>
To: bfields@redhat.com
Cc: linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@tonian.com>
Subject: [PATCH 5/5] 4.1 server tests: test NFS4_SHARE_WANT_NO_DELEG
Date: Thu, 16 Feb 2012 20:17:39 +0200
Message-Id: <1329416259-21263-1-git-send-email-bhalevy@tonian.com>
In-Reply-To: <4F3D47B3.1090708@tonian.com>
References: <4F3D47B3.1090708@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 nfs4.1/server41tests/st_delegation.py |   22 ++++++++++++++++++++++
 1 files changed, 22 insertions(+), 0 deletions(-)

diff --git a/nfs4.1/server41tests/st_delegation.py b/nfs4.1/server41tests/st_delegation.py
index 3b32c74..ac425dc 100644
--- a/nfs4.1/server41tests/st_delegation.py
+++ b/nfs4.1/server41tests/st_delegation.py
@@ -142,3 +142,25 @@ def testAnyDeleg(t, env):
     # Now get OPEN reply
     res = sess2.listen(slot)
     checklist(res, [NFS4_OK, NFS4ERR_DELAY])
+
+def testNoDeleg(t, env):
+    """Test no delgation handout
+
+    FLAGS: open deleg all
+    CODE: DELEG4
+    """
+    c1 = env.c1.new_client("%s_1" % env.testname(t))
+    sess1 = c1.create_session()
+    sess1.compound([op.reclaim_complete(FALSE)])
+    res = create_file(sess1, env.testname(t),
+                      access=OPEN4_SHARE_ACCESS_READ |
+                      OPEN4_SHARE_ACCESS_WANT_NO_DELEG)
+    check(res)
+    fh = res.resarray[-1].object
+    deleg = res.resarray[-2].delegation
+    if deleg.delegation_type == OPEN_DELEGATE_NONE:
+        fail("Got no delegation, expected OPEN_DELEGATE_NONE_EXT")
+    if deleg.delegation_type != OPEN_DELEGATE_NONE_EXT:
+        fail("Got a delegation (type "+str(deleg.delegation_type)+") despite asking for none")
+    if deleg.ond_why != WND4_NOT_WANTED:
+        fail("Wrong reason ("+str(deleg.ond_why)+") for giving no delegation")
-- 
1.7.6.5

