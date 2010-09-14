Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:40913 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751696Ab0INBHh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Sep 2010 21:07:37 -0400
Date: Mon, 13 Sep 2010 21:06:30 -0400
To: iisaman@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [pynfs PATCH] TESTS: fix DELEG9
Message-ID: <20100914010630.GC27200@fieldses.org>
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: J. Bruce Fields <bfields@redhat.com>

The new server doesn't have a recall callback setup, so will never send
the delegreturn.  (Doing it by hand at the end as attempted here doesn't
work well, as the open that precedes that final delegreturn needs the
delegreturn before it can succeed.)

Also, we need to set c.cb_server for _verify_cb_occurred to get the
correct count.

After this patch, the test passes against the Linux server.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 lib/nfs4/servertests/st_delegation.py |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/lib/nfs4/servertests/st_delegation.py b/lib/nfs4/servertests/st_delegation.py
index 5fc4fad..14a1d32 100644
--- a/lib/nfs4/servertests/st_delegation.py
+++ b/lib/nfs4/servertests/st_delegation.py
@@ -396,9 +396,11 @@ def testChangeDeleg(t, env, funct=_recall):
     deleg_info, fh, stateid = _get_deleg(t, c, c.homedir + [t.code], funct, NFS4_OK)
     # Create new callback server
     new_server = CBServer(c)
+    new_server.set_cb_recall(c.cbid, funct, NFS4_OK);
     cb_thread = threading.Thread(target=new_server.run)
     cb_thread.setDaemon(1)
     cb_thread.start()
+    c.cb_server = new_server
     env.sleep(3)
     # Switch to using new server
     res = c.compound([_set_clientid(c, id, new_server)])
@@ -415,9 +417,6 @@ def testChangeDeleg(t, env, funct=_recall):
     count = new_server.opcounts[OP_CB_RECALL]
     fh2, stateid2 = _cause_recall(t, env)
     _verify_cb_occurred(t, c, count)
-    ops = c.use_obj(fh) + [c.delegreturn_op(deleg_info.read.stateid)]
-    res = c.compound(ops)
-    check(res)
 
 
    
-- 
1.7.0.4

