Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:40881 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932250AbaKERBT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Nov 2014 12:01:19 -0500
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id sA5H1Hlq009277
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Wed, 5 Nov 2014 12:01:18 -0500
Received: from tonberry.usersys.redhat.com (dhcp145-188.rdu.redhat.com [10.13.145.188])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id sA5H1H3Z000733
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Wed, 5 Nov 2014 12:01:17 -0500
Received: from tonberry.usersys.redhat.com (localhost [127.0.0.1])
	by tonberry.usersys.redhat.com (8.14.8/8.14.5) with ESMTP id sA5H1Gn7000951
	for <linux-nfs@vger.kernel.org>; Wed, 5 Nov 2014 12:01:16 -0500
Received: (from smayhew@localhost)
	by tonberry.usersys.redhat.com (8.14.8/8.14.8/Submit) id sA5H1G5i000950
	for linux-nfs@vger.kernel.org; Wed, 5 Nov 2014 12:01:16 -0500
From: Scott Mayhew <smayhew@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [nfs-utils RFC PATCH 13/15] mountstats: Implement nfsstat_command
Date: Wed,  5 Nov 2014 12:01:10 -0500
Message-Id: <1415206872-864-14-git-send-email-smayhew@redhat.com>
In-Reply-To: <1415206872-864-1-git-send-email-smayhew@redhat.com>
References: <1415206872-864-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Displays nfssstat-like statistics for a single mountpoint (client
statistics only).

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 tools/mountstats/mountstats.py | 87 +++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 86 insertions(+), 1 deletion(-)

diff --git a/tools/mountstats/mountstats.py b/tools/mountstats/mountstats.py
index 2d6ca95..389f241 100755
--- a/tools/mountstats/mountstats.py
+++ b/tools/mountstats/mountstats.py
@@ -445,6 +445,42 @@ class DeviceData:
                 print('\ttotal execute time: %f (milliseconds)' % \
                     (float(stats[7]) / count))
 
+    def display_nfsstat_stats(self):
+        """Pretty-print nfsstat-style stats
+        """
+        sends = 0
+        trans = 0
+        for op in self.__rpc_data['ops']:
+            sends += self.__rpc_data[op][0]
+            trans += self.__rpc_data[op][1]
+        retrans = trans - sends
+        print('Client rpc stats:')
+        print('calls      retrans    authrefrsh')
+        # authrefresh stats don't actually get captured in
+        # /proc/self/mountstats, so we fudge it here
+        print('%-11u%-11u%-11u' % (sends, retrans, sends))
+        if not sends:
+            return
+        print()
+        prog, vers = self.__rpc_data['programversion'].split('/')
+        print('Client nfs v%d' % int(vers))
+        info = []
+        for op in self.__rpc_data['ops']:
+            print('%-13s' % str.lower(op), end='')
+            count = self.__rpc_data[op][0]
+            pct = (count * 100) / sends
+            info.append((count, pct))
+            if (self.__rpc_data['ops'].index(op) + 1) % 6 == 0:
+                print()
+                for (count, pct) in info:
+                    print('%-8u%3u%% ' % (count, pct), end='')
+                print()
+                info = []
+        print()
+        for (count, pct) in info:
+            print('%-8u%3u%% ' % (count, pct), end='')
+        print()
+
     def compare_iostats(self, old_stats):
         """Return the difference between two sets of stats
         """
@@ -706,9 +742,58 @@ def print_nfsstat_help(name):
     print()
     print(' nfsstat-like program that uses NFS client per-mount statistics.')
     print()
+    print('Options:')
+    print()
+    print('  -m <mountpoint>, --mountpount <mountpoint>')
+    print('                Show stats for \'mountpoint\'')
+    print()
+    print('  -f <file>, --file <file>')
+    print('                Read stats from \'file\' instead of /proc/self/mountstats')
+    print()
+    print('  -S <file>, --since <file>')
+    print('                Shows difference between current stats and those in \'file\'')
+    print()
+    print('  -h, --help')
+    print('                What you just did')
 
 def nfsstat_command():
-    print_nfsstat_help(prog)
+    """nfsstat-like command for NFS mount points
+    """
+    try:
+        opts, args = getopt.getopt(sys.argv[1:], "f:hm:S:", ["file=", "help", "mountpoint=", "since="])
+    except getopt.GetoptError as err:
+        print_nfsstat_help(prog)
+    infile = None
+    mp = None
+    since = None
+    for o, a in opts:
+        if o in ("-f", "--file"):
+            infile = a
+        elif o in ("-h", "--help"):
+            print_nfsstat_help(prog)
+            sys.exit()
+        elif o in ("-m", "--mountpoint"):
+            mp = a
+        elif o in ("-S", "--since"):
+            since = a
+        else:
+            assert False, "unhandled option"
+    if not mp:
+        print_nfsstat_help(prog)
+        sys.exit()
+    if not infile:
+        infile = '/proc/self/mountstats'
+    mountstats = parse_stats_file(infile)
+    stats = DeviceData()
+    stats.parse_stats(mountstats[mp])
+    if not since:
+        stats.display_nfsstat_stats()
+    else:
+        old_mountstats = parse_stats_file(since)
+        oldstats = DeviceData()
+        oldstats.parse_stats(old_mountstats[mp])
+        diff_stats = stats.compare_iostats(oldstats)
+        diff_stats.display_nfsstat_stats()
 
 def print_iostat_help(name):
     print('usage: %s [ <interval> [ <count> ] ] [ <mount point> ] ' % name)
-- 
1.9.3

