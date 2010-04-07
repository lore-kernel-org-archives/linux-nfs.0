From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: DELEG9
Date: Wed, 7 Apr 2010 19:01:19 -0400
Message-ID: <20100407230119.GK26072@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: iisaman@umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:51189 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752003Ab0DGW6x (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Apr 2010 18:58:53 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

DELEG9 has a few problems:

A callback is never detected, even when one is sent, because
_verify_cb_occurred looks at the old callback server, not the new one.

DELEGRETURN is never sent--probably the existing client doesn't know how
to handle recalls on the new callback server?  The code attempts to make
up for this with an explicit DELEGRETURN after _cause_recall(), but by
then it's too late.

After the following patch, the test works, in the sense that it succeeds
if and only if the server makes a recall over the new callback
connection.

I don't claim this is right, though.  I'm just sending a single open to
trigger the recall, and ignoring the results.  Maybe what's needed is a
method that modifies the callback server instead of attempting to
replace it outright?  I don't know.

--b.

diff --git a/lib/nfs4/servertests/st_delegation.py b/lib/nfs4/servertests/st_delegation.py
index f5056f0..26b19d6 100644
--- a/lib/nfs4/servertests/st_delegation.py
+++ b/lib/nfs4/servertests/st_delegation.py
@@ -399,6 +399,7 @@ def testChangeDeleg(t, env, funct=_recall):
     deleg_info, fh, stateid = _get_deleg(t, c, c.homedir + [t.code], funct, NFS4_OK)
     # Create new callback server
     new_server = CBServer(c)
+    c.cb_server = new_server
     cb_thread = threading.Thread(target=new_server.run)
     cb_thread.setDaemon(1)
     cb_thread.start()
@@ -416,11 +417,16 @@ def testChangeDeleg(t, env, funct=_recall):
         res = c.compound([confirmop])
         check(res)
     count = new_server.opcounts[OP_CB_RECALL]
-    fh2, stateid2 = _cause_recall(t, env)
+    # need lock around this to prevent _recall from
+    # calling c.unpacker.reset while open is still unpacking
+    _lock.acquire()
+    res = c.open_file('newowner', c.homedir + [t.code],
+                      access=OPEN4_SHARE_ACCESS_WRITE,
+                      deny=OPEN4_SHARE_DENY_NONE)
+    _lock.release()
+    env.sleep(1, 'wait for recall')
     _verify_cb_occurred(t, c, count)
-    ops = c.use_obj(fh) + [c.delegreturn_op(deleg_info.read.stateid)]
-    res = c.compound(ops)
-    check(res)
+
 
 
    
