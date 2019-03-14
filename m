Return-Path: <SRS0=spLM=RR=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2F546C10F06
	for <linux-nfs@archiver.kernel.org>; Thu, 14 Mar 2019 21:12:13 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 094C32186A
	for <linux-nfs@archiver.kernel.org>; Thu, 14 Mar 2019 21:12:13 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727412AbfCNVML (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 14 Mar 2019 17:12:11 -0400
Received: from mx1.redhat.com ([209.132.183.28]:33640 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727715AbfCNVML (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 14 Mar 2019 17:12:11 -0400
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 723A730EBB51;
        Thu, 14 Mar 2019 21:12:11 +0000 (UTC)
Received: from coeurl.usersys.redhat.com (ovpn-122-19.rdu2.redhat.com [10.10.122.19])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 2A9C05D9C4;
        Thu, 14 Mar 2019 21:12:10 +0000 (UTC)
Received: by coeurl.usersys.redhat.com (Postfix, from userid 1000)
        id 7FDD3213F7; Thu, 14 Mar 2019 17:12:10 -0400 (EDT)
From:   Scott Mayhew <smayhew@redhat.com>
To:     bfields@fieldses.org
Cc:     jlayton@kernel.org, linux-nfs@vger.kernel.org
Subject: [pynfs PATCH 1/4] nfs4.1: add some reboot tests
Date:   Thu, 14 Mar 2019 17:12:07 -0400
Message-Id: <20190314211210.7454-2-smayhew@redhat.com>
In-Reply-To: <20190314211210.7454-1-smayhew@redhat.com>
References: <20190314211210.7454-1-smayhew@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.49]); Thu, 14 Mar 2019 21:12:11 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

REBT2a, REBT2b, and REBT2c test recovery with multiple clients following
a server reboot.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 nfs4.1/server41tests/st_reboot.py | 151 +++++++++++++++++++++++++++++-
 1 file changed, 147 insertions(+), 4 deletions(-)

diff --git a/nfs4.1/server41tests/st_reboot.py b/nfs4.1/server41tests/st_reboot.py
index b852ded..0216127 100644
--- a/nfs4.1/server41tests/st_reboot.py
+++ b/nfs4.1/server41tests/st_reboot.py
@@ -1,25 +1,33 @@
 from xdrdef.nfs4_const import *
 from xdrdef.nfs4_type import *
-from .environment import check, fail, create_file, open_file, create_confirm
+from .environment import check, fail, create_file, open_file, create_confirm, close_file
 import sys
 import os
-import nfs4lib
+import time
+import logging
 import nfs_ops
 op = nfs_ops.NFS4ops()
 from rpc import RPCTimeout
 
 # NOTE - reboot tests are NOT part of the standard test suite
 
+log = logging.getLogger("test.env")
+
 def _getleasetime(sess):
     res = sess.compound([op.putrootfh(), op.getattr(1 << FATTR4_LEASE_TIME)])
     return res.resarray[-1].obj_attributes[FATTR4_LEASE_TIME]
 
-def _waitForReboot(c, sess, env):
+def _waitForReboot(env):
     env.serverhelper("reboot")
     # Wait until the server is back up.
     # The following blocks until it gets a response,
     # which happens when the server comes back up.
     env.c1.c1 = env.c1.connect(env.c1.server_address)
+    # Go ahead and whack the cached session and client ids now
+    # to avoid errors in Environment.finish().
+    env.c1.sessions = {}
+    env.c1.clients = {}
+    return int(time.time())
 
 def create_session(c, cred=None, flags=0):
     """Send a simple CREATE_SESSION"""
@@ -51,7 +59,7 @@ def testRebootValid(t, env):
     reclaim_complete(sess)
     fh, stateid = create_confirm(sess, owner)
     sleeptime = 5 + _getleasetime(sess)
-    _waitForReboot(c, sess, env)
+    _waitForReboot(env)
     try:
         res = create_session(c)
         check(res, NFS4ERR_STALE_CLIENTID, "Reclaim using old clientid")
@@ -67,3 +75,138 @@ def testRebootValid(t, env):
         reclaim_complete(sess)
     finally:
         env.sleep(sleeptime, "Waiting for grace period to end")
+
+class State(object):
+    def __init__(self, name, owner, c, sess, fh):
+        self.name = name
+        self.owner = owner
+        self.c = c
+        self.sess = sess
+        self.fh = fh
+
+def doTestOneClientGrace(t, env, state):
+    res = state.sess.compound([])
+    check(res, NFS4ERR_BADSESSION, "Bare sequence after reboot")
+    res = create_session(state.c)
+    check(res, NFS4ERR_STALE_CLIENTID, "Reclaim using old clientid")
+    c = env.c1.new_client(state.name)
+    state.c = c
+    sess = c.create_session()
+    state.sess = sess
+    lease_time = _getleasetime(sess)
+    res = open_file(sess, state.owner, path=state.fh,
+                   claim_type=CLAIM_PREVIOUS,
+                   access=OPEN4_SHARE_ACCESS_BOTH,
+                   deny=OPEN4_SHARE_DENY_NONE,
+                   deleg_type=OPEN_DELEGATE_NONE)
+    check(res, msg="Reclaim using newly created clientid")
+    fh = res.resarray[-1].object
+    stateid = res.resarray[-2].stateid
+    reclaim_complete(sess)
+    close_file(sess, fh, stateid=stateid)
+    res = open_file(sess, state.owner, claim_type=CLAIM_NULL,
+                   access=OPEN4_SHARE_ACCESS_BOTH,
+                   deny=OPEN4_SHARE_DENY_NONE,
+                   deleg_type=OPEN_DELEGATE_NONE)
+    check(res, NFS4ERR_GRACE, "New open during grace")
+    return lease_time
+
+def doTestOneClientNoGrace(t, env, state):
+    res = open_file(state.sess, state.owner, claim_type=CLAIM_NULL,
+                   access=OPEN4_SHARE_ACCESS_BOTH,
+                   deny=OPEN4_SHARE_DENY_NONE,
+                   deleg_type=OPEN_DELEGATE_NONE)
+    if (res.status == NFS4ERR_GRACE):
+        return res
+    check(res, msg="New open after all clients done reclaiming")
+    fh = res.resarray[-1].object
+    stateid = res.resarray[-2].stateid
+    close_file(state.sess, fh, stateid=stateid)
+    return res
+
+# The server may have lifted the grace period early, but it's not obligated.
+# Keep looping until all the clients have done a normal open.  If the server
+# didn't lift the grace period early we don't want to fail the test, but we
+# do want to log a message.
+def doTestAllClientsNoGrace(t, env, states):
+        all_done = False
+        warn_grace = False
+        start_time = int(time.time())
+        ok_time = 0
+        while not all_done:
+            all_done = True
+            for state in states:
+                res = doTestOneClientNoGrace(t, env, state)
+                if res.status == NFS4ERR_GRACE:
+                    warn_grace = True
+                    all_done = False
+                elif not ok_time:
+                    ok_time = int(time.time())
+            if not all_done:
+                time.sleep(1)
+        if warn_grace:
+            lift_time = ok_time - start_time
+            log.warn("server took approximately %d seconds to lift grace "
+                        "after all clients reclaimed" % lift_time)
+
+def doTestRebootWithNClients(t, env, n=10):
+    boot_time = int(time.time())
+    lease_time = 90
+    states = []
+    block = env.c1.new_client_session("%s_block" % env.testname(t))
+    for i in range(n):
+        name = "%s_client_%i" % (env.testname(t), i)
+        owner = "owner_%s" % name
+        c = env.c1.new_client(name)
+        sess = c.create_session()
+        reclaim_complete(sess)
+        fh, stateid = create_confirm(sess, owner)
+        states.append(State(name, owner, c, sess, fh))
+    lease_time = _getleasetime(sess)
+    boot_time = _waitForReboot(env)
+
+    try:
+        for i in range(n):
+            lease_time = doTestOneClientGrace(t, env, states[i])
+
+        # At this point, all clients should have recovered except for 'block'.
+        # Recover that one now.
+        block = env.c1.new_client_session("%s_block" % env.testname(t))
+
+        # The server may have lifted the grace period early.  Test it.
+        doTestAllClientsNoGrace(t, env, states)
+
+    # If the test went normally, then the grace period should have already
+    # ended.  If we got some unexpected error, then wait a bit for the server
+    # to expire the clients so cleanup can proceed more smoothly.
+    except:
+        grace_end_time = boot_time + lease_time + 5
+        now = int(time.time())
+        if now < grace_end_time:
+            sleep_time = grace_end_time - now
+            env.sleep(sleep_time, "Waiting for grace period to end")
+        raise
+
+def testRebootWithManyClients(t, env):
+    """Reboot with many clients
+
+    FLAGS: reboot
+    CODE: REBT2a
+    """
+    return doTestRebootWithNClients(t, env)
+
+def testRebootWithManyManyClients(t, env):
+    """Reboot with many many clients
+
+    FLAGS: reboot
+    CODE: REBT2b
+    """
+    return doTestRebootWithNClients(t, env, 100)
+
+def testRebootWithManyManyManyClients(t, env):
+    """Reboot with many many many clients
+
+    FLAGS: reboot
+    CODE: REBT2c
+    """
+    return doTestRebootWithNClients(t, env, 1000)
-- 
2.17.2

