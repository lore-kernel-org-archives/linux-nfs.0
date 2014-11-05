Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:35593 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932255AbaKERBR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Nov 2014 12:01:17 -0500
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id sA5H1G4l022483
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Wed, 5 Nov 2014 12:01:16 -0500
Received: from tonberry.usersys.redhat.com (dhcp145-188.rdu.redhat.com [10.13.145.188])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id sA5H1FKl000703
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Wed, 5 Nov 2014 12:01:15 -0500
Received: from tonberry.usersys.redhat.com (localhost [127.0.0.1])
	by tonberry.usersys.redhat.com (8.14.8/8.14.5) with ESMTP id sA5H1Fl7000931
	for <linux-nfs@vger.kernel.org>; Wed, 5 Nov 2014 12:01:15 -0500
Received: (from smayhew@localhost)
	by tonberry.usersys.redhat.com (8.14.8/8.14.8/Submit) id sA5H1Fb6000930
	for linux-nfs@vger.kernel.org; Wed, 5 Nov 2014 12:01:15 -0500
From: Scott Mayhew <smayhew@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [nfs-utils RFC PATCH 08/15] mountstats: Add support for -f/--file to the mountstats and ms-iostat commands
Date: Wed,  5 Nov 2014 12:01:05 -0500
Message-Id: <1415206872-864-9-git-send-email-smayhew@redhat.com>
In-Reply-To: <1415206872-864-1-git-send-email-smayhew@redhat.com>
References: <1415206872-864-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add support for the -f/--file option to allow parsing of data from an
arbitrary file instead of /proc/self/mountstats.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 tools/mountstats/mountstats.py | 35 ++++++++++++++++++++++++++++-------
 1 file changed, 28 insertions(+), 7 deletions(-)

diff --git a/tools/mountstats/mountstats.py b/tools/mountstats/mountstats.py
index 67bca51..23def92 100755
--- a/tools/mountstats/mountstats.py
+++ b/tools/mountstats/mountstats.py
@@ -557,6 +557,7 @@ def print_mountstats_help(name):
     print(' Display NFS client per-mount statistics.')
     print()
     print('  --version    display the version of this command')
+    print('  --file <file> read stats from \'file\' instead of /proc/self/mountstats')
     print('  --nfs        display only the NFS statistics')
     print('  --rpc        display only the RPC statistics')
     print('  --start      sample and save statistics')
@@ -567,17 +568,20 @@ def mountstats_command():
     """Mountstats command
     """
     try:
-        opts, args = getopt.getopt(sys.argv[1:], "ehnrsv", ["end", "help", "nfs", "rpc", "start", "version"])
+        opts, args = getopt.getopt(sys.argv[1:], "ef:hnrsv", ["end", "file=", "help", "nfs", "rpc", "start", "version"])
     except getopt.GetoptError as err:
         print_mountstats_help(prog)
 
     mountpoints = []
     nfs_only = False
     rpc_only = False
+    infile = None
 
     for o, a in opts:
         if o in ("-e", "--end"):
             raise Exception('Sampling is not yet implemented')
+        elif o in ("-f", "--file"):
+            infile = a
         elif o in ("-h", "--help"):
             print_mountstats_help(prog)
             sys.exit(0)
@@ -602,7 +606,9 @@ def mountstats_command():
         print_mountstats_help(prog)
         return
 
-    mountstats = parse_stats_file('/proc/self/mountstats')
+    if not infile:
+        infile = '/proc/self/mountstats'
+    mountstats = parse_stats_file(infile)
 
     for mp in mountpoints:
         if mp not in mountstats:
@@ -678,16 +684,20 @@ def iostat_command():
     """iostat-like command for NFS mount points
     """
     try:
-        opts, args = getopt.getopt(sys.argv[1:], "hv", ["help", "version"])
+        opts, args = getopt.getopt(sys.argv[1:], "f:hv", ["file=", "help", "version"])
     except getopt.GetoptError as err:
         print_iostat_help(prog)
-    mountstats = parse_stats_file('/proc/self/mountstats')
     devices = []
     interval_seen = False
     count_seen = False
+    infile_seen = False
+    infile = None
 
     for o, a in opts:
-        if o in ("-h", "--help"):
+        if o in ("-f", "--file"):
+            infile = a
+            infile_seen = True
+        elif o in ("-h", "--help"):
             print_iostat_help(prog)
             sys.exit(0)
         elif o in ("-v", "--version"):
@@ -695,6 +705,9 @@ def iostat_command():
             sys.exit(0)
         else:
             assert False, "unhandled option"
+    if not infile:
+        infile = '/proc/self/mountstats'
+    mountstats = parse_stats_file(infile)
 
     for arg in args:
         if arg in mountstats:
@@ -702,14 +715,22 @@ def iostat_command():
         elif not interval_seen:
             interval = int(arg)
             if interval > 0:
-                interval_seen = True
+                if infile_seen:
+                    print('interval may not be used with the -f option')
+                    return
+                else:
+                    interval_seen = True
             else:
                 print('Illegal <interval> value')
                 return
         elif not count_seen:
             count = int(arg)
             if count > 0:
-                count_seen = True
+                if infile_seen:
+                    print('count may not be used with the -f option')
+                    return
+                else:
+                    count_seen = True
             else:
                 print('Illegal <count> value')
                 return
-- 
1.9.3

