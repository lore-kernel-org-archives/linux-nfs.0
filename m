Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:35599 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932262AbaKERBS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Nov 2014 12:01:18 -0500
Received: from int-mx13.intmail.prod.int.phx2.redhat.com (int-mx13.intmail.prod.int.phx2.redhat.com [10.5.11.26])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id sA5H1GiJ022491
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Wed, 5 Nov 2014 12:01:17 -0500
Received: from tonberry.usersys.redhat.com (dhcp145-188.rdu.redhat.com [10.13.145.188])
	by int-mx13.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id sA5H1GXM030339
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Wed, 5 Nov 2014 12:01:16 -0500
Received: from tonberry.usersys.redhat.com (localhost [127.0.0.1])
	by tonberry.usersys.redhat.com (8.14.8/8.14.5) with ESMTP id sA5H1GJb000943
	for <linux-nfs@vger.kernel.org>; Wed, 5 Nov 2014 12:01:16 -0500
Received: (from smayhew@localhost)
	by tonberry.usersys.redhat.com (8.14.8/8.14.8/Submit) id sA5H1GAE000942
	for linux-nfs@vger.kernel.org; Wed, 5 Nov 2014 12:01:16 -0500
From: Scott Mayhew <smayhew@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [nfs-utils RFC PATCH 11/15] mountstats: Allow mountstats_command to take a variable number of mountpoints
Date: Wed,  5 Nov 2014 12:01:08 -0500
Message-Id: <1415206872-864-12-git-send-email-smayhew@redhat.com>
In-Reply-To: <1415206872-864-1-git-send-email-smayhew@redhat.com>
References: <1415206872-864-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Allow the mountstats command to take a variable number of mountpoints
(including none, in which case it will print stats for all NFS
mountpoints it finds).

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 tools/mountstats/mountstats.py | 32 +++++++++++++++++++-------------
 1 file changed, 19 insertions(+), 13 deletions(-)

diff --git a/tools/mountstats/mountstats.py b/tools/mountstats/mountstats.py
index 77975ad..281f4be 100755
--- a/tools/mountstats/mountstats.py
+++ b/tools/mountstats/mountstats.py
@@ -616,10 +616,6 @@ def mountstats_command():
             assert False, "unhandled option"
     mountpoints += args
 
-    if mountpoints == []:
-        print_mountstats_help(prog)
-        return
-
     if rpc_only == True and nfs_only == True:
         print_mountstats_help(prog)
         return
@@ -628,21 +624,31 @@ def mountstats_command():
         infile = '/proc/self/mountstats'
     mountstats = parse_stats_file(infile)
 
+    # make certain devices contains only NFS mount points
+    if len(mountpoints) > 0:
+        check = []
+        for device in mountpoints:
+            stats = DeviceData()
+            stats.parse_stats(mountstats[device])
+            if stats.is_nfs_mountpoint():
+                check += [device]
+        mountpoints = check
+    else:
+        for device, descr in mountstats.items():
+            stats = DeviceData()
+            stats.parse_stats(descr)
+            if stats.is_nfs_mountpoint():
+                mountpoints += [device]
+    if len(mountpoints) == 0:
+        print('No NFS mount points were found')
+        return
+
     if since:
         old_mountstats = parse_stats_file(since)
 
     for mp in mountpoints:
-        if mp not in mountstats:
-            print('Statistics for mount point %s not found' % mp)
-            continue
-
         stats = DeviceData()
         stats.parse_stats(mountstats[mp])
-
-        if not stats.is_nfs_mountpoint():
-            print('Mount point %s exists but is not an NFS mount' % mp)
-            continue
-
         if not since:
             print_mountstats(stats, nfs_only, rpc_only)
         elif since and mp not in old_mountstats:
-- 
1.9.3

