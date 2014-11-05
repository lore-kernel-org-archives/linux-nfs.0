Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:35605 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932277AbaKERBS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Nov 2014 12:01:18 -0500
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id sA5H1IOB022499
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Wed, 5 Nov 2014 12:01:18 -0500
Received: from tonberry.usersys.redhat.com (dhcp145-188.rdu.redhat.com [10.13.145.188])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id sA5H1HRA000741
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Wed, 5 Nov 2014 12:01:18 -0500
Received: from tonberry.usersys.redhat.com (localhost [127.0.0.1])
	by tonberry.usersys.redhat.com (8.14.8/8.14.5) with ESMTP id sA5H1HgA000959
	for <linux-nfs@vger.kernel.org>; Wed, 5 Nov 2014 12:01:17 -0500
Received: (from smayhew@localhost)
	by tonberry.usersys.redhat.com (8.14.8/8.14.8/Submit) id sA5H1HaX000958
	for linux-nfs@vger.kernel.org; Wed, 5 Nov 2014 12:01:17 -0500
From: Scott Mayhew <smayhew@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [nfs-utils RFC PATCH 15/15] mountstats: Update the help output
Date: Wed,  5 Nov 2014 12:01:12 -0500
Message-Id: <1415206872-864-16-git-send-email-smayhew@redhat.com>
In-Reply-To: <1415206872-864-1-git-send-email-smayhew@redhat.com>
References: <1415206872-864-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Updated the help output for mounstats, ms-iostat, and ms-nfsstat to make
them constistent.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 tools/mountstats/mountstats.py | 43 ++++++++++++++++++++++++++++++++++++------
 1 file changed, 37 insertions(+), 6 deletions(-)

diff --git a/tools/mountstats/mountstats.py b/tools/mountstats/mountstats.py
index f9f5eac..50dcc10 100755
--- a/tools/mountstats/mountstats.py
+++ b/tools/mountstats/mountstats.py
@@ -627,11 +627,25 @@ def print_mountstats_help(name):
     print()
     print(' Display NFS client per-mount statistics.')
     print()
-    print('  --version    display the version of this command')
-    print('  --file <file> read stats from \'file\' instead of /proc/self/mountstats')
-    print('  --nfs        display only the NFS statistics')
-    print('  --rpc        display only the RPC statistics')
-    print('  --since <file> shows difference between current stats and those in \'file\'')
+    print('Options:')
+    print()
+    print('  -n, --nfs')
+    print('                Display only the NFS statistics')
+    print()
+    print('  -r, --rpc')
+    print('                Display only the RPC statistics')
+    print()
+    print('  -f <file>, --file <file>')
+    print('                Read stats from \'file\' instead of /proc/self/mountstats')
+    print()
+    print('  -S <file>, --since <file>')
+    print('                Shows difference between current stats and those in \'file\'')
+    print()
+    print('  -h, --help')
+    print('                Show the help message')
+    print()
+    print('  -v, --version')
+    print('                Display the version of this command')
     print()
 
 def print_mountstats(stats, nfs_only, rpc_only, raw):
@@ -748,7 +762,8 @@ def print_nfsstat_help(name):
     print('                Shows difference between current stats and those in \'file\'')
     print()
     print('  -h, --help')
-    print('                What you just did')
+    print('                Show the help message')
+    print()
 
 def nfsstat_command():
     """nfsstat-like command for NFS mount points
@@ -810,6 +825,22 @@ def print_iostat_help(name):
     print(' mount points will be displayed.  Otherwise, all NFS mount points on the')
     print(' client are listed.')
     print()
+    print('Options:')
+    print()
+    print('  -f <file>, --file <file>')
+    print('                Read stats from \'file\' instead of /proc/self/mountstats.')
+    print('                This may not be combined with the <interval> and <count> parameters.')
+    print()
+    print('  -S <file>, --since <file>')
+    print('                Shows difference between current stats and those in \'file\'')
+    print('                This may not be combined with the <interval> and <count> parameters.')
+    print()
+    print('  -h, --help')
+    print('                Show the help message')
+    print()
+    print('  -v, --version')
+    print('                Display the version of this command')
+    print()
 
 def print_iostat_summary(old, new, devices, time):
     for device in devices:
-- 
1.9.3

