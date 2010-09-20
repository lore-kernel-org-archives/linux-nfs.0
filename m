Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:46323 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752473Ab0ITPGE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Sep 2010 11:06:04 -0400
Date: Mon, 20 Sep 2010 11:04:41 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: iisaman@umich.edu
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] TESTS: make reboot tests run non-interactively
Message-ID: <20100920150441.GG4580@fieldses.org>
References: <20100920033621.GB18325@fieldses.org>
 <20100920150317.GE4580@fieldses.org>
 <20100920150413.GF4580@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100920150413.GF4580@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: J. Bruce Fields <bfields@redhat.com>

If I asked for reboot tests on the commandline, then I shouldn't need to
be asked again.

And if I want something different from the default I'll modify the
script, or add a commandline option.  It's more important that the tests
be easy to run unattended.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 lib/nfs4/servertests/st_reboot.py |   49 +++++++++----------------------------
 1 files changed, 12 insertions(+), 37 deletions(-)

diff --git a/lib/nfs4/servertests/st_reboot.py b/lib/nfs4/servertests/st_reboot.py
index 4828cb8..758c54c 100644
--- a/lib/nfs4/servertests/st_reboot.py
+++ b/lib/nfs4/servertests/st_reboot.py
@@ -5,29 +5,6 @@ import os
 
 # NOTE - reboot tests are NOT part of the standard test suite
 
-__asked = None
-
-def _ask(t, env):
-    global __asked
-    if __asked is None:
-        print "Reboot tests are not part of the standard test suite."
-        if not env.opts.verbose:
-            print "Also, it is probably better to use the -v option"
-        print "Are you *sure* you want to run them?"
-        answer = sys.stdin.readline()
-        c = answer.lower()[0]
-        __asked = (c=='y')
-    return __asked
-
-def _getcount(t, env):
-    print "For test %s, how many clientids to use?" % t.code
-    answer = sys.stdin.readline()
-    try:
-         t.__clientcount = int(answer)
-         return True
-    except:
-        return False
-
 def _waitForReboot(c):
     """Wait for server to reboot.
 
@@ -57,7 +34,7 @@ def testRebootValid(t, env):
     """REBOOT with valid CLAIM_PREVIOUS
 
     FLAGS: reboot
-    DEPEND: _ask MKFILE
+    DEPEND: MKFILE
     CODE: REBT1
     """
     c = env.c1
@@ -79,21 +56,19 @@ def testManyClaims(t, env):
     """REBOOT test
 
     FLAGS: reboot
-    DEPEND: _ask _getcount MKDIR MKFILE
+    DEPEND: MKDIR MKFILE
     CODE: REBT2
     """
     c = env.c1
-    if not hasattr(t, '__clientcount'):
-        # default if use --force
-        t.__clientcount = 5
+    clientcount = 5
     pid = str(os.getpid())
     basedir = c.homedir + [t.code]
     res = c.create_obj(basedir)
     check(res, msg="Creating test directory %s" % t.code)
     # Make lots of client ids
     fhdict = {}
-    idlist = ['pynfs%s%06i' % (pid, x) for x in range(t.__clientcount)]
-    badids = ['badpynfs%s%06i' % (pid, x) for x in range(t.__clientcount)]
+    idlist = ['pynfs%s%06i' % (pid, x) for x in range(clientcount)]
+    badids = ['badpynfs%s%06i' % (pid, x) for x in range(clientcount)]
     for id in idlist:
         c.init_connection(id)
         fh, stateid = c.create_confirm(t.code, basedir + [id])
@@ -120,7 +95,7 @@ def testRebootWait(t, env):
     """REBOOT with late CLAIM_PREVIOUS should return NFS4ERR_NO_GRACE
 
     FLAGS: reboot
-    DEPEND: _ask MKFILE
+    DEPEND: MKFILE
     CODE: REBT3
     """
     c = env.c1
@@ -142,7 +117,7 @@ def testRebootInvalid(t, env):
     """REBOOT with invalid CLAIM_PREVIOUS
 
     FLAGS: reboot
-    DEPEND: _ask MKFILE
+    DEPEND: MKFILE
     CODE: REBT4
     """
     c = env.c1
@@ -164,7 +139,7 @@ def testEdge1(t, env):
     """REBOOT with first edge condition from RFC 3530
 
     FLAGS: reboot
-    DEPEND: _ask MKFILE
+    DEPEND: MKFILE
     CODE: REBT5
     """
     c1 = env.c1
@@ -210,7 +185,7 @@ def testEdge2(t, env):
     """REBOOT with second edge condition from RFC 3530
 
     FLAGS: reboot
-    DEPEND: _ask MKFILE
+    DEPEND: MKFILE
     CODE: REBT6
     """
     c1 = env.c1
@@ -257,7 +232,7 @@ def testRootSquash(t, env):
     """REBOOT root squash does not work after grace ends?
 
     FLAGS: reboot
-    DEPEND: _ask MKFILE MKDIR
+    DEPEND: MKFILE MKDIR
     CODE: REBT7
     """
     # Note this assumes we can legally use uid 0...either we are using
@@ -295,7 +270,7 @@ def testValidDeleg(t, env):
     """REBOOT with read delegation and reclaim it
 
     FLAGS: reboot delegations
-    DEPEND: _ask MKFILE
+    DEPEND: MKFILE
     CODE: REBT8
     """
     from st_delegation import _get_deleg
@@ -325,7 +300,7 @@ def testRebootMultiple(t, env):
     """REBOOT multiple times with valid CLAIM_PREVIOUS
 
     FLAGS: reboot
-    DEPEND: _ask MKFILE
+    DEPEND: MKFILE
     CODE: REBT10
     """
     c = env.c1
-- 
1.7.0.4

