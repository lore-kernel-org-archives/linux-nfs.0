Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:39895 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932688Ab1ERQoR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 May 2011 12:44:17 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 1/2] Generalize reboot helper script
Date: Wed, 18 May 2011 12:44:12 -0400
Message-Id: <1305737053-17096-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1305737053-17096-1-git-send-email-bfields@redhat.com>
References: <1305737053-17096-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

We allow the user to pass a script on the testserver commandline that
reboots the server.

There will be more cases like this where we want to do something special
on the server that can't be done through the protocol and may depend on
local configuration details.

So instead of adding a new helper script for each one, use a single
"serverhelper" script that can be passed different commands.  Fall back
on requesting manual intervention in the absence of the script.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 lib/nfs4/servertests/environment.py |   16 ++++++++++++
 lib/nfs4/servertests/st_reboot.py   |   46 +++++++++++++---------------------
 sample_files/send_reboot.py         |   17 -------------
 sample_files/server_helper.sh       |   17 +++++++++++++
 testserver.py                       |   13 +++++----
 5 files changed, 58 insertions(+), 51 deletions(-)
 delete mode 100755 sample_files/send_reboot.py
 create mode 100644 sample_files/server_helper.sh

diff --git a/lib/nfs4/servertests/environment.py b/lib/nfs4/servertests/environment.py
index 6a318f7..8b23e66 100644
--- a/lib/nfs4/servertests/environment.py
+++ b/lib/nfs4/servertests/environment.py
@@ -15,6 +15,7 @@ from nfs4.nfs4_const import *
 from nfs4.nfs4_type import fsid4, nfsace4, fs_locations4, fs_location4, \
      specdata4, nfstime4, settime4, stateid4
 import rpc
+import sys
 import os
 
 class AttrInfo(object):
@@ -210,6 +211,21 @@ class Environment(testmod.Environment):
         time.sleep(sec)
         print "Woke up"
 
+    def serverhelper(self, args):
+        """Perform a special operation on the server side (such as
+        rebooting the server)"""
+        if self.opts.serverhelper is None:
+            print "Manual operation required on server:"
+            print args + " and hit ENTER when done"
+            sys.stdin.readline()
+            print "Continuing with test"
+        else:
+            cmd = self.opts.serverhelper
+            if self.opts.serverhelperarg:
+                cmd += ' ' + self.opts.serverhelperarg
+            cmd += ' ' + args
+            os.system(cmd);
+
 #########################################
 debug_fail = False
 
diff --git a/lib/nfs4/servertests/st_reboot.py b/lib/nfs4/servertests/st_reboot.py
index 758c54c..067cda6 100644
--- a/lib/nfs4/servertests/st_reboot.py
+++ b/lib/nfs4/servertests/st_reboot.py
@@ -1,30 +1,20 @@
 from nfs4.nfs4_const import *
 from environment import check, checklist
-import sys
 import os
 
 # NOTE - reboot tests are NOT part of the standard test suite
 
-def _waitForReboot(c):
+def _waitForReboot(c, env):
     """Wait for server to reboot.
 
     Returns an estimate of how long grace period will last.
     """
     oldleasetime = c.getLeaseTime()
-    if c.opts.rebootscript is None:
-        print "Hit ENTER to continue after server is reset"
-        sys.stdin.readline()
-        print "Continuing with test"
-    else:
-        args = c.opts.rebootscript
-        if c.opts.rebootargs:
-            c.opts.rebootscript += ' ' + c.opts.rebootargs
-        os.system(args)
-
-        # Wait until the server is back up.
-        # c.null() blocks until it gets a response,
-        # which happens when the server comes back up.
-        c.null()
+    env.serverhelper("reboot")
+    # Wait until the server is back up.
+    # c.null() blocks until it gets a response,
+    # which happens when the server comes back up.
+    c.null()
     newleasetime = c.getLeaseTime()
     return 5 + max(oldleasetime, newleasetime)
 
@@ -40,7 +30,7 @@ def testRebootValid(t, env):
     c = env.c1
     c.init_connection()
     fh, stateid = c.create_confirm(t.code)
-    sleeptime = _waitForReboot(c)
+    sleeptime = _waitForReboot(c, env)
     try:
         res = c.open_file(t.code, fh, claim_type=CLAIM_PREVIOUS,
                        deleg_type=OPEN_DELEGATE_NONE)
@@ -73,7 +63,7 @@ def testManyClaims(t, env):
         c.init_connection(id)
         fh, stateid = c.create_confirm(t.code, basedir + [id])
         fhdict[id] = fh
-    sleeptime = _waitForReboot(c)
+    sleeptime = _waitForReboot(c, env)
     try: 
         # Lots of reclaims
         badfh = fhdict[idlist[-1]]
@@ -101,7 +91,7 @@ def testRebootWait(t, env):
     c = env.c1
     c.init_connection()
     fh, stateid = c.create_confirm(t.code)
-    sleeptime = _waitForReboot(c)
+    sleeptime = _waitForReboot(c, env)
     try:
         res = c.open_file(t.code, fh, claim_type=CLAIM_PREVIOUS,
                        deleg_type=OPEN_DELEGATE_NONE)
@@ -123,7 +113,7 @@ def testRebootInvalid(t, env):
     c = env.c1
     c.init_connection()
     fh, stateid = c.create_confirm(t.code, access=OPEN4_SHARE_ACCESS_READ)
-    sleeptime = _waitForReboot(c)
+    sleeptime = _waitForReboot(c, env)
     try:
         c.init_connection()
         res = c.open_file(t.code, fh, access=OPEN4_SHARE_ACCESS_WRITE,
@@ -167,7 +157,7 @@ def testEdge1(t, env):
     res2 = c2.close_file(t.code, fh2, stateid2)
     check(res2, msg="Client 2 closing file")
     # Server reboots
-    sleeptime = _waitForReboot(c2)
+    sleeptime = _waitForReboot(c2, env)
     try:
         # Client 1: Reclaim lock (should not work, since #2 has interfered)
         res1 = c1.compound([c1.renew_op(c1.clientid)])
@@ -197,7 +187,7 @@ def testEdge2(t, env):
     res1 = c1.lock_file(t.code, fh1, stateid1)
     check(res1, msg="Client 1 locking file")
     # Server reboots
-    sleeptime = _waitForReboot(c1)
+    sleeptime = _waitForReboot(c1, env)
     # Let grace period expire
     env.sleep(sleeptime, "Waiting for grace period to end")
     # Client 2: come in and grab lock
@@ -214,7 +204,7 @@ def testEdge2(t, env):
     res2 = c2.close_file(t.code, fh2, stateid2)
     check(res2, msg="Client 2 closing file")
     # Server reboots
-    sleeptime = _waitForReboot(c2)
+    sleeptime = _waitForReboot(c2, env)
     try:
         # Client 1: Reclaim lock (should not work, since #2 has interfered)
         res1 = c1.compound([c1.renew_op(c1.clientid)])
@@ -251,7 +241,7 @@ def testRootSquash(t, env):
     print "Detected root squashing: root -> %s" % oldname
     
     # Wait for grace period to have *just* expired
-    _waitForReboot(c)
+    _waitForReboot(c, env)
     c.init_connection()
     while 1:
         res = c.create_file(t.code, c.homedir + [t.code, 'file'])
@@ -279,7 +269,7 @@ def testValidDeleg(t, env):
     c.init_connection(id, cb_ident=0)
     deleg_info, fh, stateid =_get_deleg(t, c, c.homedir + [t.code],
                                         None, NFS4_OK)
-    sleeptime = _waitForReboot(c)
+    sleeptime = _waitForReboot(c, env)
     try:
         res = c.open_file(t.code, fh, claim_type=CLAIM_PREVIOUS,
                           deleg_type=OPEN_DELEGATE_NONE)
@@ -306,13 +296,13 @@ def testRebootMultiple(t, env):
     c = env.c1
     c.init_connection()
     fh, stateid = c.create_confirm(t.code)
-    sleeptime = _waitForReboot(c)
+    sleeptime = _waitForReboot(c, env)
     try:
         c.init_connection()
         res = c.open_file(t.code, fh, claim_type=CLAIM_PREVIOUS,
                        deleg_type=OPEN_DELEGATE_NONE)
         check(res, msg="Reclaim using newly created clientid")
-        sleeptime = _waitForReboot(c)
+        sleeptime = _waitForReboot(c, env)
         c.init_connection()
         res = c.open_file(t.code, fh, claim_type=CLAIM_PREVIOUS,
                        deleg_type=OPEN_DELEGATE_NONE)
@@ -330,7 +320,7 @@ def testGraceSeqid(t, env):
     c = env.c1
     c.init_connection()
     fh, stateid = c.create_confirm(t.code)
-    sleeptime = _waitForReboot(c)
+    sleeptime = _waitForReboot(c, env)
     try:
         c.init_connection()
         res = c.open_file(t.code, fh, claim_type=CLAIM_PREVIOUS,
diff --git a/sample_files/send_reboot.py b/sample_files/send_reboot.py
deleted file mode 100755
index a66c6e8..0000000
--- a/sample_files/send_reboot.py
+++ /dev/null
@@ -1,17 +0,0 @@
-#!/usr/bin/python
-
-import sys
-import os
-
-"""
-A simple reboot script for the reboot tests that reboots a virtual guest.
-It would be used by adding
---rebootscript=sample/send_reboot.py --rebootargs=SERVERNAME
-to testserver.py's commandline arguments.
-"""
-
-def reboot(servername):
-    os.system('virsh destroy ' + servername)
-    os.system('virsh start ' + servername)
-
-reboot(sys.argv[1])
diff --git a/sample_files/server_helper.sh b/sample_files/server_helper.sh
new file mode 100644
index 0000000..291f840
--- /dev/null
+++ b/sample_files/server_helper.sh
@@ -0,0 +1,17 @@
+#!/bin/bash
+
+# A simple script for the reboot tests that reboots a virtual guest.
+# It would be used by adding
+# --serverhelper=sample/send_reboot.py --serverhelperarg=SERVERNAME
+# to testserver.py's commandline arguments.
+
+server=$1
+command=$2
+shift; shift
+
+case $command in
+reboot )
+	virsh destroy $server
+	virsh start $server
+	;;
+esac
diff --git a/testserver.py b/testserver.py
index 67ae35f..c2a7c7b 100755
--- a/testserver.py
+++ b/testserver.py
@@ -122,8 +122,9 @@ def scan_options(p):
     .usedir    = (None)
     .usespecial= (None)
 
-    .rebootscript = (None)
-    .rebootargs = (None)
+    .serverhelper = (None)
+    .serverhelperarg = (None)
+
     """
     p.add_option("--showflags", action="store_true", default=False,
                  help="Print a list of all possible flags and exit")
@@ -225,11 +226,11 @@ def scan_options(p):
                     "the scripts and arguments used to control how the "
                     "server is restarted.")
 
-    g.add_option("--rebootscript", default=None, metavar="FILE",
-                 help="Use FILE as the script to reboot SERVER.")
+    g.add_option("--serverhelper", default=None, metavar="FILE",
+                 help="Use script to perform special actions on server")
 
-    g.add_option("--rebootargs", default=None, metavar="ARGS",
-                 help="Pass ARGS as a string to the reboot script.")
+    g.add_option("--serverhelperarg", default=None, metavar="ARG",
+                 help="Pass ARG as first argument to serverhelper");
 
     p.add_option_group(g)
 
-- 
1.7.4.1

