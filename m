Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:52934 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754154Ab0IUQM0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Sep 2010 12:12:26 -0400
Date: Tue, 21 Sep 2010 12:11:00 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: iisaman@umich.edu
Cc: linux-nfs@vger.kernel.org, groshans@umich.edu
Subject: [PATCH] CLNT: preliminary reboot test
Message-ID: <20100921161100.GF26473@fieldses.org>
References: <20100920033621.GB18325@fieldses.org>
 <20100920150317.GE4580@fieldses.org>
 <20100920150532.GH4580@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100920150532.GH4580@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Mike Groshans <mike@Moscow.citi.umich.edu>

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 nfs4.1/server41tests/__init__.py    |    1 +
 nfs4.1/server41tests/environment.py |   13 +++++-
 nfs4.1/server41tests/st_reboot.py   |   76 +++++++++++++++++++++++++++++++++++
 nfs4.1/testserver.py                |    7 +++
 4 files changed, 95 insertions(+), 2 deletions(-)
 create mode 100644 nfs4.1/server41tests/st_reboot.py

Also, the linux 4.1 server now passes the test added by this patch, also
available from

	git://linux-nfs.org/~bfields/pynfs41.git

I've updated my test scripts at

	git://linux-nfs.org/~bfields/testd.git

to turn on this test, and also to turn on some of the 4.0 "timed" tests.

Note there's a bug in the 4.1 pynfs tests: they should be routinely
doing a reclaim_complete after each exchange_id/create_session.

--b.

diff --git a/nfs4.1/server41tests/__init__.py b/nfs4.1/server41tests/__init__.py
index 8d8212b..d631b74 100644
--- a/nfs4.1/server41tests/__init__.py
+++ b/nfs4.1/server41tests/__init__.py
@@ -8,6 +8,7 @@ __all__ = ["st_exchange_id.py", # draft 21
            "st_lookupp.py",
            "st_rename.py",
            "st_putfh.py",
+           "st_reboot.py",
 ##            "st_lookup.py",
            ##################
            "st_block.py",
diff --git a/nfs4.1/server41tests/environment.py b/nfs4.1/server41tests/environment.py
index 983ab92..e961082 100644
--- a/nfs4.1/server41tests/environment.py
+++ b/nfs4.1/server41tests/environment.py
@@ -471,7 +471,9 @@ def create_file(sess, owner, path=None, attrs={FATTR4_MODE: 0644},
 def open_file(sess, owner, path=None,
               access=OPEN4_SHARE_ACCESS_READ,
               deny=OPEN4_SHARE_DENY_NONE,
+              claim_type=CLAIM_NULL,
               want_deleg=False,
+              deleg_type=None,
               # Setting the following should induce server errors
               seqid=0, clientid=0):
     # Set defaults
@@ -484,10 +486,17 @@ def open_file(sess, owner, path=None,
     if not want_deleg and access & OPEN4_SHARE_ACCESS_WANT_DELEG_MASK == 0:
         access |= OPEN4_SHARE_ACCESS_WANT_NO_DELEG
     # Open the file
+    if claim_type==CLAIM_NULL:
+        fh_op = use_obj(dir)
+    elif claim_type==CLAIM_PREVIOUS:
+        fh_op = [op.putfh(path)]
+        name = None
+    if not want_deleg and access & OPEN4_SHARE_ACCESS_WANT_DELEG_MASK == 0:
+        access |= OPEN4_SHARE_ACCESS_WANT_NO_DELEG
     open_op = op.open(seqid, access, deny, open_owner4(clientid, owner),
                       openflag4(OPEN4_NOCREATE),
-                      open_claim4(CLAIM_NULL, name))
-    return sess.compound(use_obj(dir) + [open_op, op.getfh()])
+                      open_claim4(claim_type, name, deleg_type))
+    return sess.compound(fh_op + [open_op, op.getfh()])
 
 def create_confirm(sess, owner, path=None, attrs={FATTR4_MODE: 0644},
                    access=OPEN4_SHARE_ACCESS_BOTH,
diff --git a/nfs4.1/server41tests/st_reboot.py b/nfs4.1/server41tests/st_reboot.py
new file mode 100644
index 0000000..9eee19d
--- /dev/null
+++ b/nfs4.1/server41tests/st_reboot.py
@@ -0,0 +1,76 @@
+from nfs4_const import *
+from nfs4_type import channel_attrs4
+from environment import check, checklist, fail, create_file, open_file, create_confirm
+import sys
+import os
+import nfs4lib
+import nfs4_ops as op
+from rpc import RPCTimeout
+
+# NOTE - reboot tests are NOT part of the standard test suite
+
+def _getleasetime(sess):
+    res = sess.compound([op.putrootfh(), op.getattr(1 << FATTR4_LEASE_TIME)])
+    return res.resarray[-1].obj_attributes[FATTR4_LEASE_TIME]
+
+def _waitForReboot(c, sess, env):
+    """Wait for server to reboot.
+
+    Returns an estimate of how long grace period will last.
+    """
+    oldleasetime = _getleasetime(sess)
+    if env.opts.rebootscript is None:
+        print "Hit ENTER to continue after server is reset"
+        sys.stdin.readline()
+        print "Continuing with test"
+    else:
+        if env.opts.rebootargs is not None:
+            # Invoke the reboot script, passing it rebootargs as an argument.
+            os.system(env.opts.rebootscript + ' ' + env.opts.rebootargs)
+        else:
+            os.system(env.opts.rebootscript)
+    env.c1.c1 = env.c1.connect(env.c1.server_address)
+    return 5 + oldleasetime
+
+def create_session(c, cred=None, flags=0):
+    """Send a simple CREATE_SESSION"""
+    chan_attrs = channel_attrs4(0,8192,8192,8192,128,8,[])
+    res = c.c.compound([op.create_session(c.clientid, c.seqid, flags,
+                                        chan_attrs, chan_attrs,
+                                        123, [])], cred)
+    return res
+
+def reclaim_complete(sess):
+    rc_op = op.reclaim_complete(rca_one_fs=False)
+    res = sess.compound([rc_op])
+    check(res, msg="reclaim_complete")
+
+#####################################################
+
+def testRebootValid(t, env):
+    """REBOOT with valid CLAIM_PREVIOUS
+
+    FLAGS: reboot
+    DEPEND:
+    CODE: REBT1
+    """
+    name = env.testname(t)
+    owner = "owner_%s" % name
+    c = env.c1.new_client(env.testname(t))
+    sess = c.create_session()
+    reclaim_complete(sess)
+    fh, stateid = create_confirm(sess, owner)
+    sleeptime = _waitForReboot(c, sess, env)
+    try:
+        res = create_session(c)
+        check(res, NFS4ERR_STALE_CLIENTID, "Reclaim using old clientid")
+        c = env.c1.new_client(env.testname(t))
+        sess = c.create_session()
+        res = open_file(sess, owner, path=fh, claim_type=CLAIM_PREVIOUS,
+                       access=OPEN4_SHARE_ACCESS_BOTH,
+                       deny=OPEN4_SHARE_DENY_NONE,
+                       deleg_type=OPEN_DELEGATE_NONE)
+        check(res, msg="Reclaim using newly created clientid")
+        reclaim_complete(sess)
+    finally:
+        env.sleep(sleeptime, "Waiting for grace period to end")
diff --git a/nfs4.1/testserver.py b/nfs4.1/testserver.py
index 073291f..450d6c3 100755
--- a/nfs4.1/testserver.py
+++ b/nfs4.1/testserver.py
@@ -193,6 +193,13 @@ def scan_options(p):
 ##     g.add_option("--secure", action="store_true", default=False,
 ##                  help="Try to use 'secure' port number <1024 for client [False]")
 ##     p.add_option_group(g)
+
+    g.add_option("--rebootscript", default=None, metavar="FILE",
+                 help="Use FILE as the script to reboot SERVER.")
+
+    g.add_option("--rebootargs", default=None, metavar="ARGS",
+                 help="Pass ARGS as a string to the reboot script.")
+
     return p.parse_args()
 
 class Argtype(object):
-- 
1.7.0.4

