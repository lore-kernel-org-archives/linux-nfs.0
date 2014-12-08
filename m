Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:33698 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754589AbaLHUwc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Dec 2014 15:52:32 -0500
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id sB8KqLUR010165
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Mon, 8 Dec 2014 15:52:32 -0500
Received: from tonberry.usersys.redhat.com (dhcp145-188.rdu.redhat.com [10.13.145.188])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id sB8KF9IF018387
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Mon, 8 Dec 2014 15:17:37 -0500
Received: from tonberry.usersys.redhat.com (localhost [127.0.0.1])
	by tonberry.usersys.redhat.com (8.14.8/8.14.5) with ESMTP id sB8JvUqq010202
	for <linux-nfs@vger.kernel.org>; Mon, 8 Dec 2014 14:57:30 -0500
Received: (from smayhew@localhost)
	by tonberry.usersys.redhat.com (8.14.8/8.14.8/Submit) id sB8JvUTG010201
	for linux-nfs@vger.kernel.org; Mon, 8 Dec 2014 14:57:30 -0500
From: Scott Mayhew <smayhew@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH v3 08/17] mountstats: Add support for -f/--file to the mountstats and ms-iostat commands
Date: Mon,  8 Dec 2014 14:57:16 -0500
Message-Id: <1418068645-10134-9-git-send-email-smayhew@redhat.com>
In-Reply-To: <1418068645-10134-1-git-send-email-smayhew@redhat.com>
References: <1418068645-10134-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add support for the -f/--file option to allow parsing of data from an
arbitrary file instead of /proc/self/mountstats.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 tools/mountstats/mountstats.py | 31 +++++++++++++++++++++----------
 1 file changed, 21 insertions(+), 10 deletions(-)

diff --git a/tools/mountstats/mountstats.py b/tools/mountstats/mountstats.py
index eaf0719..a2e2253 100644
--- a/tools/mountstats/mountstats.py
+++ b/tools/mountstats/mountstats.py
@@ -530,7 +530,7 @@ class DeviceData:
         self.__print_rpc_op_stats('WRITE', sample_time)
         sys.stdout.flush()
 
-def parse_stats_file(filename):
+def parse_stats_file(f):
     """pop the contents of a mountstats file into a dictionary,
     keyed by mount point.  each value object is a list of the
     lines in the mountstats file corresponding to the mount
@@ -539,7 +539,7 @@ def parse_stats_file(filename):
     ms_dict = dict()
     key = ''
 
-    f = open(filename)
+    f.seek(0)
     for line in f.readlines():
         words = line.split()
         if len(words) == 0:
@@ -553,14 +553,13 @@ def parse_stats_file(filename):
         else:
             new += [ line.strip() ]
         ms_dict[key] = new
-    f.close
 
     return ms_dict
 
 def mountstats_command(args):
     """Mountstats command
     """
-    mountstats = parse_stats_file('/proc/self/mountstats')
+    mountstats = parse_stats_file(args.infile)
 
     for mp in args.mountpoints:
         if mp not in mountstats:
@@ -587,6 +586,8 @@ def mountstats_command(args):
            stats.display_rpc_generic_stats()
            stats.display_rpc_op_stats()
 
+    args.infile.close()
+
 def nfsstat_command(args):
     return
 
@@ -605,7 +606,7 @@ def print_iostat_summary(old, new, devices, time):
 def iostat_command(args):
     """iostat-like command for NFS mount points
     """
-    mountstats = parse_stats_file('/proc/self/mountstats')
+    mountstats = parse_stats_file(args.infile)
     devices = args.mountpoints
 
     # make certain devices contains only NFS mount points
@@ -613,9 +614,12 @@ def iostat_command(args):
         check = []
         for device in devices:
             stats = DeviceData()
-            stats.parse_stats(mountstats[device])
-            if stats.is_nfs_mountpoint():
-                check += [device]
+            try:
+                stats.parse_stats(mountstats[device])
+                if stats.is_nfs_mountpoint():
+                    check += [device]
+            except KeyError:
+                continue
         devices = check
     else:
         for device, descr in mountstats.items():
@@ -641,7 +645,7 @@ def iostat_command(args):
             old_mountstats = mountstats
             time.sleep(args.interval)
             sample_time = args.interval
-            mountstats = parse_stats_file('/proc/self/mountstats')
+            mountstats = parse_stats_file(args.infile)
             count -= 1
     else: 
         while True:
@@ -649,7 +653,9 @@ def iostat_command(args):
             old_mountstats = mountstats
             time.sleep(args.interval)
             sample_time = args.interval
-            mountstats = parse_stats_file('/proc/self/mountstats')
+            mountstats = parse_stats_file(args.infile)
+
+    args.infile.close()
 
 class ICMAction(argparse.Action):
     """Custom action to deal with interval, count, and mountpoints.
@@ -668,6 +674,8 @@ class ICMAction(argparse.Action):
     def _handle_one(self, namespace, value):
         try:
             intval = int(value)
+            if namespace.infile.name != '/proc/self/mountstats':
+                raise argparse.ArgumentError(self, "not allowed with argument -f/--file")
             self._handle_int(namespace, intval)
         except ValueError:
             namespace.mountpoints.append(value)
@@ -683,6 +691,9 @@ class ICMAction(argparse.Action):
 def main():
     parser = argparse.ArgumentParser(add_help=False)
     parser.add_argument('-v', '--version', action='version', version='%(prog)s ' + Mountstats_version)
+    parser.add_argument('-f', '--file', default=open('/proc/self/mountstats', 'r'),
+        type=argparse.FileType('r'), dest='infile',
+        help='Read stats from %(dest)s instead of /proc/self/mountstats')
 
     prog = os.path.basename(sys.argv[0])
 
-- 
1.9.3

