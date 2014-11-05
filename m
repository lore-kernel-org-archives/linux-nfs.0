Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:35892 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932255AbaKERBP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Nov 2014 12:01:15 -0500
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id sA5H1EKF022048
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Wed, 5 Nov 2014 12:01:15 -0500
Received: from tonberry.usersys.redhat.com (dhcp145-188.rdu.redhat.com [10.13.145.188])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id sA5H1E1h000688
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Wed, 5 Nov 2014 12:01:14 -0500
Received: from tonberry.usersys.redhat.com (localhost [127.0.0.1])
	by tonberry.usersys.redhat.com (8.14.8/8.14.5) with ESMTP id sA5H1ErI000918
	for <linux-nfs@vger.kernel.org>; Wed, 5 Nov 2014 12:01:14 -0500
Received: (from smayhew@localhost)
	by tonberry.usersys.redhat.com (8.14.8/8.14.8/Submit) id sA5H1EqU000917
	for linux-nfs@vger.kernel.org; Wed, 5 Nov 2014 12:01:14 -0500
From: Scott Mayhew <smayhew@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [nfs-utils RFC PATCH 05/15] mountstats: Convert existing option parsing to use the getopt module
Date: Wed,  5 Nov 2014 12:01:02 -0500
Message-Id: <1415206872-864-6-git-send-email-smayhew@redhat.com>
In-Reply-To: <1415206872-864-1-git-send-email-smayhew@redhat.com>
References: <1415206872-864-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 tools/mountstats/mountstats.py | 62 +++++++++++++++++++++---------------------
 1 file changed, 31 insertions(+), 31 deletions(-)

diff --git a/tools/mountstats/mountstats.py b/tools/mountstats/mountstats.py
index 2fe1362..272a8f9 100755
--- a/tools/mountstats/mountstats.py
+++ b/tools/mountstats/mountstats.py
@@ -24,6 +24,7 @@ MA 02110-1301 USA
 """
 
 import sys, os, time
+import getopt
 
 Mountstats_version = '0.2'
 
@@ -547,37 +548,33 @@ def print_mountstats_help(name):
 def mountstats_command():
     """Mountstats command
     """
+    try:
+        opts, args = getopt.getopt(sys.argv[1:], "ehnrsv", ["end", "help", "nfs", "rpc", "start", "version"])
+    except getopt.GetoptError as err:
+        print_mountstats_help(prog)
+
     mountpoints = []
     nfs_only = False
     rpc_only = False
 
-    for arg in sys.argv:
-        if arg in ['-h', '--help', 'help', 'usage']:
+    for o, a in opts:
+        if o in ("-e", "--end"):
+            raise Exception('Sampling is not yet implemented')
+        elif o in ("-h", "--help"):
             print_mountstats_help(prog)
-            return
-
-        if arg in ['-v', '--version', 'version']:
-            print('%s version %s' % (sys.argv[0], Mountstats_version))
             sys.exit(0)
-
-        if arg in ['-n', '--nfs']:
+        elif o in ("-n", "--nfs"):
             nfs_only = True
-            continue
-
-        if arg in ['-r', '--rpc']:
+        elif o in ("-r", "--rpc"):
             rpc_only = True
-            continue
-
-        if arg in ['-s', '--start']:
-            raise Exception('Sampling is not yet implemented')
-
-        if arg in ['-e', '--end']:
+        elif o in ("-s", "--start"):
             raise Exception('Sampling is not yet implemented')
-
-        if arg == sys.argv[0]:
-            continue
-
-        mountpoints += [arg]
+        elif o in ("-v", "--version"):
+            print('%s version %s' % (sys.argv[0], Mountstats_version))
+            sys.exit(0)
+        else:
+            assert False, "unhandled option"
+    mountpoints += args
 
     if mountpoints == []:
         print_mountstats_help(prog)
@@ -662,23 +659,26 @@ def print_iostat_summary(old, new, devices, time):
 def iostat_command():
     """iostat-like command for NFS mount points
     """
+    try:
+        opts, args = getopt.getopt(sys.argv[1:], "hv", ["help", "version"])
+    except getopt.GetoptError as err:
+        print_iostat_help(prog)
     mountstats = parse_stats_file('/proc/self/mountstats')
     devices = []
     interval_seen = False
     count_seen = False
 
-    for arg in sys.argv:
-        if arg in ['-h', '--help', 'help', 'usage']:
+    for o, a in opts:
+        if o in ("-h", "--help"):
             print_iostat_help(prog)
-            return
-
-        if arg in ['-v', '--version', 'version']:
+            sys.exit(0)
+        elif o in ("-v", "--version"):
             print('%s version %s' % (sys.argv[0], Mountstats_version))
-            return
-
-        if arg == sys.argv[0]:
-            continue
+            sys.exit(0)
+        else:
+            assert False, "unhandled option"
 
+    for arg in args:
         if arg in mountstats:
             devices += [arg]
         elif not interval_seen:
-- 
1.9.3

