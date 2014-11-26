Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:41867 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751778AbaKZTN7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 26 Nov 2014 14:13:59 -0500
Received: from int-mx13.intmail.prod.int.phx2.redhat.com (int-mx13.intmail.prod.int.phx2.redhat.com [10.5.11.26])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id sAQJDwGs016770
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Wed, 26 Nov 2014 14:13:59 -0500
Received: from tonberry.usersys.redhat.com (dhcp145-188.rdu.redhat.com [10.13.145.188])
	by int-mx13.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id sAQJDwKK002364
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Wed, 26 Nov 2014 14:13:58 -0500
Received: from tonberry.usersys.redhat.com (localhost [127.0.0.1])
	by tonberry.usersys.redhat.com (8.14.8/8.14.5) with ESMTP id sAQJDwvE037734
	for <linux-nfs@vger.kernel.org>; Wed, 26 Nov 2014 14:13:58 -0500
Received: (from smayhew@localhost)
	by tonberry.usersys.redhat.com (8.14.8/8.14.8/Submit) id sAQJDvHS037733
	for linux-nfs@vger.kernel.org; Wed, 26 Nov 2014 14:13:57 -0500
From: Scott Mayhew <smayhew@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH v2 05/17] mountstats: Convert existing option parsing to use the argparse module
Date: Wed, 26 Nov 2014 14:13:43 -0500
Message-Id: <1417029235-37675-6-git-send-email-smayhew@redhat.com>
In-Reply-To: <1417029235-37675-1-git-send-email-smayhew@redhat.com>
References: <1417029235-37675-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Also removed the --start and --end options since all they do is throw
exceptions.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 tools/mountstats/mountstats.py | 235 ++++++++++++++++-------------------------
 1 file changed, 93 insertions(+), 142 deletions(-)

diff --git a/tools/mountstats/mountstats.py b/tools/mountstats/mountstats.py
index f633bbc..cc5c6e5 100644
--- a/tools/mountstats/mountstats.py
+++ b/tools/mountstats/mountstats.py
@@ -24,6 +24,7 @@ MA 02110-1301 USA
 """
 
 import sys, os, time
+import argparse
 
 Mountstats_version = '0.2'
 
@@ -530,66 +531,12 @@ def parse_stats_file(filename):
 
     return ms_dict
 
-def print_mountstats_help(name):
-    print('usage: %s [ options ] <mount point>' % name)
-    print()
-    print(' Version %s' % Mountstats_version)
-    print()
-    print(' Display NFS client per-mount statistics.')
-    print()
-    print('  --version    display the version of this command')
-    print('  --nfs        display only the NFS statistics')
-    print('  --rpc        display only the RPC statistics')
-    print('  --start      sample and save statistics')
-    print('  --end        resample statistics and compare them with saved')
-    print()
-
-def mountstats_command():
+def mountstats_command(args):
     """Mountstats command
     """
-    mountpoints = []
-    nfs_only = False
-    rpc_only = False
-
-    for arg in sys.argv:
-        if arg in ['-h', '--help', 'help', 'usage']:
-            print_mountstats_help(prog)
-            return
-
-        if arg in ['-v', '--version', 'version']:
-            print('%s version %s' % (sys.argv[0], Mountstats_version))
-            sys.exit(0)
-
-        if arg in ['-n', '--nfs']:
-            nfs_only = True
-            continue
-
-        if arg in ['-r', '--rpc']:
-            rpc_only = True
-            continue
-
-        if arg in ['-s', '--start']:
-            raise Exception('Sampling is not yet implemented')
-
-        if arg in ['-e', '--end']:
-            raise Exception('Sampling is not yet implemented')
-
-        if arg == sys.argv[0]:
-            continue
-
-        mountpoints += [arg]
-
-    if mountpoints == []:
-        print_mountstats_help(prog)
-        return
-
-    if rpc_only == True and nfs_only == True:
-        print_mountstats_help(prog)
-        return
-
     mountstats = parse_stats_file('/proc/self/mountstats')
 
-    for mp in mountpoints:
+    for mp in args.mountpoints:
         if mp not in mountstats:
             print('Statistics for mount point %s not found' % mp)
             continue
@@ -601,11 +548,11 @@ def mountstats_command():
             print('Mount point %s exists but is not an NFS mount' % mp)
             continue
 
-        if nfs_only:
+        if args.nfs_only:
            stats.display_nfs_options()
            stats.display_nfs_events()
            stats.display_nfs_bytes()
-        elif rpc_only:
+        elif args.rpc_only:
            stats.display_rpc_generic_stats()
            stats.display_rpc_op_stats()
         else:
@@ -614,38 +561,8 @@ def mountstats_command():
            stats.display_rpc_generic_stats()
            stats.display_rpc_op_stats()
 
-def print_nfsstat_help(name):
-    print('usage: %s [ options ]' % name)
-    print()
-    print(' Version %s' % Mountstats_version)
-    print()
-    print(' nfsstat-like program that uses NFS client per-mount statistics.')
-    print()
-
-def nfsstat_command():
-    print_nfsstat_help(prog)
-
-def print_iostat_help(name):
-    print('usage: %s [ <interval> [ <count> ] ] [ <mount point> ] ' % name)
-    print()
-    print(' Version %s' % Mountstats_version)
-    print()
-    print(' iostat-like program to display NFS client per-mount statistics.')
-    print()
-    print(' The <interval> parameter specifies the amount of time in seconds between')
-    print(' each report.  The first report contains statistics for the time since each')
-    print(' file system was mounted.  Each subsequent report contains statistics')
-    print(' collected during the interval since the previous report.')
-    print()
-    print(' If the <count> parameter is specified, the value of <count> determines the')
-    print(' number of reports generated at <interval> seconds apart.  If the interval')
-    print(' parameter is specified without the <count> parameter, the command generates')
-    print(' reports continuously.')
-    print()
-    print(' If one or more <mount point> names are specified, statistics for only these')
-    print(' mount points will be displayed.  Otherwise, all NFS mount points on the')
-    print(' client are listed.')
-    print()
+def nfsstat_command(args):
+    return
 
 def print_iostat_summary(old, new, devices, time):
     for device in devices:
@@ -659,42 +576,11 @@ def print_iostat_summary(old, new, devices, time):
             diff_stats = stats.compare_iostats(old_stats)
             diff_stats.display_iostats(time)
 
-def iostat_command():
+def iostat_command(args):
     """iostat-like command for NFS mount points
     """
     mountstats = parse_stats_file('/proc/self/mountstats')
-    devices = []
-    interval_seen = False
-    count_seen = False
-
-    for arg in sys.argv:
-        if arg in ['-h', '--help', 'help', 'usage']:
-            print_iostat_help(prog)
-            return
-
-        if arg in ['-v', '--version', 'version']:
-            print('%s version %s' % (sys.argv[0], Mountstats_version))
-            return
-
-        if arg == sys.argv[0]:
-            continue
-
-        if arg in mountstats:
-            devices += [arg]
-        elif not interval_seen:
-            interval = int(arg)
-            if interval > 0:
-                interval_seen = True
-            else:
-                print('Illegal <interval> value')
-                return
-        elif not count_seen:
-            count = int(arg)
-            if count > 0:
-                count_seen = True
-            else:
-                print('Illegal <count> value')
-                return
+    devices = args.mountpoints
 
     # make certain devices contains only NFS mount points
     if len(devices) > 0:
@@ -718,44 +604,109 @@ def iostat_command():
     old_mountstats = None
     sample_time = 0
 
-    if not interval_seen:
+    if args.interval is None:
         print_iostat_summary(old_mountstats, mountstats, devices, sample_time)
         return
 
-    if count_seen:
+    if args.count is not None:
+        count = args.count
         while count != 0:
             print_iostat_summary(old_mountstats, mountstats, devices, sample_time)
             old_mountstats = mountstats
-            time.sleep(interval)
-            sample_time = interval
+            time.sleep(args.interval)
+            sample_time = args.interval
             mountstats = parse_stats_file('/proc/self/mountstats')
             count -= 1
     else: 
         while True:
             print_iostat_summary(old_mountstats, mountstats, devices, sample_time)
             old_mountstats = mountstats
-            time.sleep(interval)
-            sample_time = interval
+            time.sleep(args.interval)
+            sample_time = args.interval
             mountstats = parse_stats_file('/proc/self/mountstats')
 
-#
-# Main
-#
-prog = os.path.basename(sys.argv[0])
+class ICMAction(argparse.Action):
+    """Custom action to deal with interval, count, and mountpoints.
+    """
+    def __call__(self, parser, namespace, values, option_string=None):
+        if namespace.mountpoints is None:
+            namespace.mountpoints = []
+        if values is None:
+            return
+        elif (type(values) == type([])):
+            for value in values:
+                self._handle_one(namespace, value)
+        else:
+            self._handle_one(namespace, values)
+
+    def _handle_one(self, namespace, value):
+        try:
+            intval = int(value)
+            self._handle_int(namespace, intval)
+        except ValueError:
+            namespace.mountpoints.append(value)
+
+    def _handle_int(self, namespace, value):
+        if namespace.interval is None:
+            namespace.interval = value
+        elif namespace.count is None:
+            namespace.count = value
+        else:
+            raise argparse.ArgumentError(self, "too many ints")
+
+def main():
+    parser = argparse.ArgumentParser(add_help=False)
+    parser.add_argument('-v', '--version', action='version', version='%(prog)s ' + Mountstats_version)
+
+    prog = os.path.basename(sys.argv[0])
 
-try:
     if prog == 'mountstats':
-        mountstats_command()
+        mountstats_parser = argparse.ArgumentParser(
+            description='Display NFS client per-mount statistics.',
+            parents=[parser])
+        group = mountstats_parser.add_mutually_exclusive_group()
+        group.add_argument('-n', '--nfs', action='store_true', dest='nfs_only',
+            help='Display only the NFS statistics')
+        group.add_argument('-r', '--rpc', action='store_true', dest='rpc_only',
+            help='Display only the RPC statistics')
+        mountstats_parser.add_argument('mountpoints', nargs='+', metavar='mountpoint',
+            help='Display statistics for this mountpoint. More than one may be specified.')
+        mountstats_parser.set_defaults(func=mountstats_command)
+        args = mountstats_parser.parse_args()
+
     elif prog == 'ms-nfsstat':
-        nfsstat_command()
+        nfsstat_parser = argparse.ArgumentParser(
+            description='nfsstat-like program that uses NFS client per-mount statistics.',
+            parents=[parser])
+        nfsstat_parser.set_defaults(func=nfsstat_command)
+        args = nfsstat_parser.parse_args()
+        nfsstat_parser.print_help()
+
     elif prog == 'ms-iostat':
-        iostat_command()
-    sys.stdout.close()
-    sys.stderr.close()
-except KeyboardInterrupt:
-    print('Caught ^C... exiting')
+        iostat_parser = argparse.ArgumentParser(
+            description='iostat-like program to display NFS client per-mount statistics.',
+            parents=[parser])
+        iostat_parser.add_argument('interval', nargs='?', action=ICMAction,
+            help='Number of seconds between reports. If absent, only one report will '
+                'be generated.')
+        iostat_parser.add_argument('count', nargs='?', action=ICMAction,
+            help='Number of reports generated at <interval> seconds apart. If absent, '
+                'reports will be generated continuously.')
+        iostat_parser.add_argument('mountpoints', nargs='*', action=ICMAction, metavar='mountpoint',
+            help='Display statsistics for this mountpoint. More than one may be specified. '
+                'If absent, statistics for all NFS mountpoints will be generated.')
+        iostat_parser.set_defaults(func=iostat_command)
+        args = iostat_parser.parse_args()
+    return args.func(args)
+
+try:
+    if __name__ == '__main__':
+        res = main()
+        sys.stdout.close()
+        sys.stderr.close()
+        sys.exit(res)
+except (SystemExit, KeyboardInterrupt, RuntimeError):
     sys.exit(1)
 except IOError:
     pass
 
-sys.exit(0)
-- 
1.9.3

