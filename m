Return-Path: <SRS0=spLM=RR=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A953AC10F0C
	for <linux-nfs@archiver.kernel.org>; Thu, 14 Mar 2019 21:12:13 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 7E61B21019
	for <linux-nfs@archiver.kernel.org>; Thu, 14 Mar 2019 21:12:13 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727715AbfCNVMM (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 14 Mar 2019 17:12:12 -0400
Received: from mx1.redhat.com ([209.132.183.28]:59278 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727513AbfCNVML (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 14 Mar 2019 17:12:11 -0400
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 6F225821F3;
        Thu, 14 Mar 2019 21:12:11 +0000 (UTC)
Received: from coeurl.usersys.redhat.com (ovpn-122-19.rdu2.redhat.com [10.10.122.19])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 2E8D75D6A6;
        Thu, 14 Mar 2019 21:12:10 +0000 (UTC)
Received: by coeurl.usersys.redhat.com (Postfix, from userid 1000)
        id 88872213FD; Thu, 14 Mar 2019 17:12:10 -0400 (EDT)
From:   Scott Mayhew <smayhew@redhat.com>
To:     bfields@fieldses.org
Cc:     jlayton@kernel.org, linux-nfs@vger.kernel.org
Subject: [pynfs PATCH 3/4] nfs4.1: still more reboot tests
Date:   Thu, 14 Mar 2019 17:12:09 -0400
Message-Id: <20190314211210.7454-4-smayhew@redhat.com>
In-Reply-To: <20190314211210.7454-1-smayhew@redhat.com>
References: <20190314211210.7454-1-smayhew@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Thu, 14 Mar 2019 21:12:11 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

REBT4a, REBT4b, and REBT4c test recovery with multiple clients following
a server reboot, where half of the clients attempt to reclaim twice.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 nfs4.1/server41tests/st_reboot.py | 78 ++++++++++++++++++++++++-------
 1 file changed, 61 insertions(+), 17 deletions(-)

diff --git a/nfs4.1/server41tests/st_reboot.py b/nfs4.1/server41tests/st_reboot.py
index 8bce9ec..06913f8 100644
--- a/nfs4.1/server41tests/st_reboot.py
+++ b/nfs4.1/server41tests/st_reboot.py
@@ -38,10 +38,13 @@ def create_session(c, cred=None, flags=0):
                                         123, sec)], cred)
     return res
 
-def reclaim_complete(sess):
+def reclaim_complete(sess, dup=False):
     rc_op = op.reclaim_complete(FALSE)
     res = sess.compound([rc_op])
-    check(res, msg="reclaim_complete")
+    if not dup:
+        check(res, msg="reclaim_complete")
+    else:
+        check(res, NFS4ERR_COMPLETE_ALREADY, msg="Duplicate reclaim_complete")
 
 #####################################################
 
@@ -84,11 +87,12 @@ class State(object):
         self.sess = sess
         self.fh = fh
 
-def doTestOneClientGrace(t, env, state):
-    res = state.sess.compound([])
-    check(res, NFS4ERR_BADSESSION, "Bare sequence after reboot")
-    res = create_session(state.c)
-    check(res, NFS4ERR_STALE_CLIENTID, "Reclaim using old clientid")
+def doTestOneClientGrace(t, env, state, dup=False):
+    if not dup:
+        res = state.sess.compound([])
+        check(res, NFS4ERR_BADSESSION, "Bare sequence after reboot")
+        res = create_session(state.c)
+        check(res, NFS4ERR_STALE_CLIENTID, "Reclaim using old clientid")
     c = env.c1.new_client(state.name)
     state.c = c
     sess = c.create_session()
@@ -99,11 +103,15 @@ def doTestOneClientGrace(t, env, state):
                    access=OPEN4_SHARE_ACCESS_BOTH,
                    deny=OPEN4_SHARE_DENY_NONE,
                    deleg_type=OPEN_DELEGATE_NONE)
-    check(res, msg="Reclaim using newly created clientid")
-    fh = res.resarray[-1].object
-    stateid = res.resarray[-2].stateid
-    reclaim_complete(sess)
-    close_file(sess, fh, stateid=stateid)
+    if not dup:
+        check(res, msg="Reclaim using newly created clientid")
+        fh = res.resarray[-1].object
+        stateid = res.resarray[-2].stateid
+    else:
+        check(res, NFS4ERR_NO_GRACE, msg="Duplicate reclaim")
+    reclaim_complete(sess, dup)
+    if not dup:
+        close_file(sess, fh, stateid=stateid)
     res = open_file(sess, state.owner, claim_type=CLAIM_NULL,
                    access=OPEN4_SHARE_ACCESS_BOTH,
                    deny=OPEN4_SHARE_DENY_NONE,
@@ -149,7 +157,11 @@ def doTestAllClientsNoGrace(t, env, states):
             log.warn("server took approximately %d seconds to lift grace "
                         "after all clients reclaimed" % lift_time)
 
-def doTestRebootWithNClients(t, env, n=10, double_reboot=False):
+def doTestRebootWithNClients(t, env, n=10, double_reboot=False,
+                             double_reclaim=False):
+    if double_reboot and double_reclaim:
+        raise RuntimeError("double_reboot and double_reclaim cannot both be true")
+
     boot_time = int(time.time())
     lease_time = 90
     states = []
@@ -166,13 +178,21 @@ def doTestRebootWithNClients(t, env, n=10, double_reboot=False):
     boot_time = _waitForReboot(env)
 
     try:
-        if double_reboot:
+        if double_reboot or double_reclaim:
             for i in range(n/2):
                 lease_time = doTestOneClientGrace(t, env, states[i])
-            boot_time = _waitForReboot(env)
 
-        for i in range(n):
-            lease_time = doTestOneClientGrace(t, env, states[i])
+        if double_reboot:
+           boot_time = _waitForReboot(env)
+
+        if double_reclaim:
+            for i in range(n/2):
+                lease_time = doTestOneClientGrace(t, env, states[i], True)
+            for i in range(n/2, n):
+                lease_time = doTestOneClientGrace(t, env, states[i])
+        else:
+            for i in range(n):
+                lease_time = doTestOneClientGrace(t, env, states[i])
 
         # At this point, all clients should have recovered except for 'block'.
         # Recover that one now.
@@ -239,3 +259,27 @@ def testDoubleRebootWithManyManyManyClients(t, env):
     CODE: REBT3c
     """
     return doTestRebootWithNClients(t, env, 1000, True)
+
+def testRebootWithManyClientsDoubleReclaim(t, env):
+    """Reboot with many clients where half try to reclaim twice
+
+    FLAGS: reboot
+    CODE: REBT4a
+    """
+    return doTestRebootWithNClients(t, env, double_reclaim=True)
+
+def testRebootWithManyManyClientsDoubleReclaim(t, env):
+    """Reboot with many many clients where half try to reclaim twice
+
+    FLAGS: reboot
+    CODE: REBT4b
+    """
+    return doTestRebootWithNClients(t, env, 100, double_reclaim=True)
+
+def testRebootWithManyManyManyClientsDoubleReclaim(t, env):
+    """Reboot with many many many clients where half try to reclaim twice
+
+    FLAGS: reboot
+    CODE: REBT4c
+    """
+    return doTestRebootWithNClients(t, env, 1000, double_reclaim=True)
-- 
2.17.2

