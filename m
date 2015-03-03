Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:56404 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752328AbbCCTPV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Mar 2015 14:15:21 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id t23JFKQG012456
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Tue, 3 Mar 2015 14:15:20 -0500
From: Scott Mayhew <smayhew@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH] mountstats: Normalize the mountpoints passed on the command line.
Date: Tue,  3 Mar 2015 14:15:19 -0500
Message-Id: <1425410119-30725-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Normalize the mountpoints passed on the command line so that commands
like 'mountstats /mnt/' succeed rather than fail.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 tools/mountstats/mountstats.py | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/tools/mountstats/mountstats.py b/tools/mountstats/mountstats.py
index 7f5dee1..38943eb 100644
--- a/tools/mountstats/mountstats.py
+++ b/tools/mountstats/mountstats.py
@@ -686,7 +686,7 @@ def mountstats_command(args):
     """Mountstats command
     """
     mountstats = parse_stats_file(args.infile)
-    mountpoints = args.mountpoints
+    mountpoints = [os.path.normpath(mp) for mp in args.mountpoints]
 
     # make certain devices contains only NFS mount points
     if len(mountpoints) > 0:
@@ -735,7 +735,7 @@ def nfsstat_command(args):
     """nfsstat-like command for NFS mount points
     """
     mountstats = parse_stats_file(args.infile)
-    mountpoints = args.mountpoints
+    mountpoints = [os.path.normpath(mp) for mp in args.mountpoints]
     v3stats = DeviceData()
     v3stats.setup_accumulator(Nfsv3ops)
     v4stats = DeviceData()
@@ -822,7 +822,7 @@ def iostat_command(args):
     """iostat-like command for NFS mount points
     """
     mountstats = parse_stats_file(args.infile)
-    devices = args.mountpoints
+    devices = [os.path.normpath(mp) for mp in args.mountpoints]
 
     if args.since:
         old_mountstats = parse_stats_file(args.since)
-- 
1.9.3

