Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:54046 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932268AbaKERBS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Nov 2014 12:01:18 -0500
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id sA5H1HTS004094
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Wed, 5 Nov 2014 12:01:18 -0500
Received: from tonberry.usersys.redhat.com (dhcp145-188.rdu.redhat.com [10.13.145.188])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id sA5H1HRY000735
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Wed, 5 Nov 2014 12:01:17 -0500
Received: from tonberry.usersys.redhat.com (localhost [127.0.0.1])
	by tonberry.usersys.redhat.com (8.14.8/8.14.5) with ESMTP id sA5H1Hrf000955
	for <linux-nfs@vger.kernel.org>; Wed, 5 Nov 2014 12:01:17 -0500
Received: (from smayhew@localhost)
	by tonberry.usersys.redhat.com (8.14.8/8.14.8/Submit) id sA5H1HmK000954
	for linux-nfs@vger.kernel.org; Wed, 5 Nov 2014 12:01:17 -0500
From: Scott Mayhew <smayhew@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [nfs-utils RFC PATCH 14/15] mountstats: Remove the --start and --end options
Date: Wed,  5 Nov 2014 12:01:11 -0500
Message-Id: <1415206872-864-15-git-send-email-smayhew@redhat.com>
In-Reply-To: <1415206872-864-1-git-send-email-smayhew@redhat.com>
References: <1415206872-864-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

All they do is throw 'not implemented' exceptions anyway.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 tools/mountstats/mountstats.py | 10 ++--------
 1 file changed, 2 insertions(+), 8 deletions(-)

diff --git a/tools/mountstats/mountstats.py b/tools/mountstats/mountstats.py
index 389f241..f9f5eac 100755
--- a/tools/mountstats/mountstats.py
+++ b/tools/mountstats/mountstats.py
@@ -631,8 +631,6 @@ def print_mountstats_help(name):
     print('  --file <file> read stats from \'file\' instead of /proc/self/mountstats')
     print('  --nfs        display only the NFS statistics')
     print('  --rpc        display only the RPC statistics')
-    print('  --start      sample and save statistics')
-    print('  --end        resample statistics and compare them with saved')
     print('  --since <file> shows difference between current stats and those in \'file\'')
     print()
 
@@ -656,7 +654,7 @@ def mountstats_command():
     """Mountstats command
     """
     try:
-        opts, args = getopt.getopt(sys.argv[1:], "ef:hnrsvS:R", ["end", "file=", "help", "nfs", "rpc", "start", "version", "since=", "raw"])
+        opts, args = getopt.getopt(sys.argv[1:], "f:hnrvS:R", ["file=", "help", "nfs", "rpc", "version", "since=", "raw"])
     except getopt.GetoptError as err:
         print_mountstats_help(prog)
 
@@ -668,9 +666,7 @@ def mountstats_command():
     since = None
 
     for o, a in opts:
-        if o in ("-e", "--end"):
-            raise Exception('Sampling is not yet implemented')
-        elif o in ("-f", "--file"):
+        if o in ("-f", "--file"):
             infile = a
         elif o in ("-h", "--help"):
             print_mountstats_help(prog)
@@ -679,8 +675,6 @@ def mountstats_command():
             nfs_only = True
         elif o in ("-r", "--rpc"):
             rpc_only = True
-        elif o in ("-s", "--start"):
-            raise Exception('Sampling is not yet implemented')
         elif o in ("-v", "--version"):
             print('%s version %s' % (sys.argv[0], Mountstats_version))
             sys.exit(0)
-- 
1.9.3

