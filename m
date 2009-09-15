From: Lans Carstensen <Lans.Carstensen-hCDZnVt6e3JSwrhanM7KvQ@public.gmane.org>
Subject: [PATCH 3/4] nfs-utils: nfs-iostat.py autofs cleanup and option to
 sort by ops/s
Date: Mon, 14 Sep 2009 21:57:44 -0700
Message-ID: <4AAF1EC8.7060001@dreamworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mta1.dreamworks.com ([208.71.56.12]:11160 "EHLO
	michael.anim.dreamworks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751496AbZIOFAE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Sep 2009 01:00:04 -0400
Received: from pinkboy.anim.dreamworks.com ([192.168.249.78])
	by michael.anim.dreamworks.com (8.13.1/8.13.1) with ESMTP id n8F5074T015403
	for <linux-nfs@vger.kernel.org>; Mon, 14 Sep 2009 22:00:07 -0700
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Introduce optparse for managing command usage/help and the statistics 
options. This change helps more cleanly add new options such as --sort 
while preserving the iostat-like interval, count, and mount point 
positional arguments.

Signed-off-by: Lans Carstensen <Lans.Carstensen-hCDZnVt6e3JSwrhanM7KvQ@public.gmane.org>
---
  tools/nfs-iostat/nfs-iostat.py |  112 
++++++++++++++++++++-------------------
  1 files changed, 57 insertions(+), 55 deletions(-)

diff --git a/tools/nfs-iostat/nfs-iostat.py b/tools/nfs-iostat/nfs-iostat.py
index b3f335a..fc2cac8 100755
--- a/tools/nfs-iostat/nfs-iostat.py
+++ b/tools/nfs-iostat/nfs-iostat.py
@@ -21,6 +21,7 @@ Foundation, Inc., 59 Temple Place, Suite 330, Boston, 
MA 02111-1307 USA
  """

  import sys, os, time
+from optparse import OptionParser, OptionGroup

  Iostats_version = '0.2'

@@ -395,33 +396,6 @@ class DeviceData:
  # Functions
  #

-def print_iostat_help(name):
-    print 'usage: %s [ <interval> [ <count> ] ] [ <options> ] [ <mount 
point> ] ' % name
-    print
-    print ' Version %s' % Iostats_version
-    print
-    print ' Sample iostat-like program to display NFS client per-mount 
statistics.'
-    print
-    print ' The <interval> parameter specifies the amount of time in 
seconds between'
-    print ' each report.  The first report contains statistics for the 
time since each'
-    print ' file system was mounted.  Each subsequent report contains 
statistics'
-    print ' collected during the interval since the previous report.'
-    print
-    print ' If the <count> parameter is specified, the value of <count> 
determines the'
-    print ' number of reports generated at <interval> seconds apart. 
If the interval'
-    print ' parameter is specified without the <count> parameter, the 
command generates'
-    print ' reports continuously.'
-    print
-    print ' Options include "--attr", which displays statistics related 
to the attribute'
-    print ' cache, "--dir", which displays statistics related to 
directory operations,'
-    print ' and "--page", which displays statistics related to the page 
cache.'
-    print ' By default, if no option is specified, statistics related 
to file I/O are'
-    print ' displayed.'
-    print
-    print ' If one or more <mount point> names are specified, 
statistics for only these'
-    print ' mount points will be displayed.  Otherwise, all NFS mount 
points on the'
-    print ' client are listed.'
-
  def parse_stats_file(filename):
      """pop the contents of a mountstats file into a dictionary,
      keyed by mount point.  each value object is a list of the
@@ -491,30 +465,50 @@ def iostat_command(name):
      mountstats = parse_stats_file('/proc/self/mountstats')
      devices = []
      origdevices = []
-    which = 0
      interval_seen = False
      count_seen = False

-    for arg in sys.argv:
-        if arg in ['-h', '--help', 'help', 'usage']:
-            print_iostat_help(name)
-            return
-
-        if arg in ['-v', '--version', 'version']:
-            print '%s version %s' % (name, Iostats_version)
-            return
-
-        if arg in ['-a', '--attr']:
-            which = 1
-            continue
-
-        if arg in ['-d', '--dir']:
-            which = 2
-            continue
-
-        if arg in ['-p', '--page']:
-            which = 3
-            continue
+    mydescription= """
+Sample iostat-like program to display NFS client per-mount'
+statistics.  The <interval> parameter specifies the amount of time in 
seconds
+between each report.  The first report contains statistics for the time 
since
+each file system was mounted.  Each subsequent report contains statistics
+collected during the interval since the previous report.  If the <count>
+parameter is specified, the value of <count> determines the number of 
reports
+generated at <interval> seconds apart.  If the interval parameter is 
specified
+without the <count> parameter, the command generates reports continuously.
+If one or more <mount point> names are specified, statistics for only these
+mount points will be displayed.  Otherwise, all NFS mount points on the
+client are listed.
+"""
+    parser = OptionParser(
+        usage="usage: %prog [ <interval> [ <count> ] ] [ <options> ] [ 
<mount point> ]",
+        description=mydescription,
+        version='version %s' % Iostats_version)
+    parser.set_defaults(which=0)
+
+    statgroup = OptionGroup(parser, "Statistics Options",
+                               'File I/O is displayed unless one of the 
following is specified:')
+    statgroup.add_option('-a', '--attr',
+                            action="store_const",
+                            dest="which",
+                            const=1,
+                            help='displays statistics related to the 
attribute cache')
+    statgroup.add_option('-d', '--dir',
+                            action="store_const",
+                            dest="which",
+                            const=2,
+                            help='displays statistics related to 
directory operations')
+    statgroup.add_option('-p', '--page',
+                            action="store_const",
+                            dest="which",
+                            const=3,
+                            help='displays statistics related to the 
page cache')
+    parser.add_option_group(statgroup)
+
+    (options, args) = parser.parse_args(sys.argv)
+
+    for arg in args:

          if arg == sys.argv[0]:
              continue
@@ -522,18 +516,26 @@ def iostat_command(name):
          if arg in mountstats:
              origdevices += [arg]
          elif not interval_seen:
-            interval = int(arg)
+            try:
+                interval = int(arg)
+            except:
+                print 'Illegal <interval> value %s' % arg
+                return
              if interval > 0:
                  interval_seen = True
              else:
-                print 'Illegal <interval> value'
+                print 'Illegal <interval> value %s' % arg
                  return
          elif not count_seen:
-            count = int(arg)
+            try:
+                count = int(arg)
+            except:
+                print 'Ilegal <count> value %s' % arg
+                return
              if count > 0:
                  count_seen = True
              else:
-                print 'Illegal <count> value'
+                print 'Illegal <count> value %s' % arg
                  return

      # make certain devices contains only NFS mount points
@@ -547,12 +549,12 @@ def iostat_command(name):
      sample_time = 0.0

      if not interval_seen:
-        print_iostat_summary(old_mountstats, mountstats, devices, 
sample_time, which)
+        print_iostat_summary(old_mountstats, mountstats, devices, 
sample_time, options.which)
          return

      if count_seen:
          while count != 0:
-            print_iostat_summary(old_mountstats, mountstats, devices, 
sample_time, which)
+            print_iostat_summary(old_mountstats, mountstats, devices, 
sample_time, options.which)
              old_mountstats = mountstats
              time.sleep(interval)
              sample_time = interval
@@ -566,7 +568,7 @@ def iostat_command(name):
              count -= 1
      else:
          while True:
-            print_iostat_summary(old_mountstats, mountstats, devices, 
sample_time, which)
+            print_iostat_summary(old_mountstats, mountstats, devices, 
sample_time, options.which)
              old_mountstats = mountstats
              time.sleep(interval)
              sample_time = interval
-- 
1.5.5.6


