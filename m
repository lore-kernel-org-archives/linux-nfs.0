Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:18951 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752198Ab3IQJV2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Sep 2013 05:21:28 -0400
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r8H9LRX5011792
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 17 Sep 2013 05:21:27 -0400
From: Bohuslav Kabrda <bkabrda@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Bohuslav Kabrda <bkabrda@redhat.com>
Subject: [PATCH] Make mountstats and nfs-iostat Python 3 compatible
Date: Tue, 17 Sep 2013 11:21:18 +0200
Message-Id: <1379409678-15730-1-git-send-email-bkabrda@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This will make mountstat and nfs-iostat run on Python 2.6, 2.7
and >= 3.0

Signed-off-by: Bohuslav Kabrda <bkabrda@redhat.com>
---
 tools/mountstats/mountstats.py | 310 ++++++++++++++++++++---------------------
 tools/nfs-iostat/nfs-iostat.py |  22 +--
 2 files changed, 166 insertions(+), 166 deletions(-)

diff --git a/tools/mountstats/mountstats.py b/tools/mountstats/mountstats.py
index b95b71d..3f5fea5 100644
--- a/tools/mountstats/mountstats.py
+++ b/tools/mountstats/mountstats.py
@@ -53,7 +53,7 @@ class DeviceData:
             if words[6].find('nfs') != -1:
                 self.__nfs_data['statvers'] = words[7]
         elif words[0] == 'age:':
-            self.__nfs_data['age'] = long(words[1])
+            self.__nfs_data['age'] = int(words[1])
         elif words[0] == 'opts:':
             self.__nfs_data['mountoptions'] = ''.join(words[1:]).split(',')
         elif words[0] == 'caps:':
@@ -91,12 +91,12 @@ class DeviceData:
             self.__nfs_data['shortwrites'] = int(words[22])
             self.__nfs_data['delay'] = int(words[23])
         elif words[0] == 'bytes:':
-            self.__nfs_data['normalreadbytes'] = long(words[1])
-            self.__nfs_data['normalwritebytes'] = long(words[2])
-            self.__nfs_data['directreadbytes'] = long(words[3])
-            self.__nfs_data['directwritebytes'] = long(words[4])
-            self.__nfs_data['serverreadbytes'] = long(words[5])
-            self.__nfs_data['serverwritebytes'] = long(words[6])
+            self.__nfs_data['normalreadbytes'] = int(words[1])
+            self.__nfs_data['normalwritebytes'] = int(words[2])
+            self.__nfs_data['directreadbytes'] = int(words[3])
+            self.__nfs_data['directwritebytes'] = int(words[4])
+            self.__nfs_data['serverreadbytes'] = int(words[5])
+            self.__nfs_data['serverwritebytes'] = int(words[6])
 
     def __parse_rpc_line(self, words):
         if words[0] == 'RPC':
@@ -110,8 +110,8 @@ class DeviceData:
                 self.__rpc_data['rpcsends'] = int(words[4])
                 self.__rpc_data['rpcreceives'] = int(words[5])
                 self.__rpc_data['badxids'] = int(words[6])
-                self.__rpc_data['inflightsends'] = long(words[7])
-                self.__rpc_data['backlogutil'] = long(words[8])
+                self.__rpc_data['inflightsends'] = int(words[7])
+                self.__rpc_data['backlogutil'] = int(words[8])
             elif words[1] == 'tcp':
                 self.__rpc_data['port'] = words[2]
                 self.__rpc_data['bind_count'] = int(words[3])
@@ -121,7 +121,7 @@ class DeviceData:
                 self.__rpc_data['rpcsends'] = int(words[7])
                 self.__rpc_data['rpcreceives'] = int(words[8])
                 self.__rpc_data['badxids'] = int(words[9])
-                self.__rpc_data['inflightsends'] = long(words[10])
+                self.__rpc_data['inflightsends'] = int(words[10])
                 self.__rpc_data['backlogutil'] = int(words[11])
             elif words[1] == 'rdma':
                 self.__rpc_data['port'] = words[2]
@@ -148,7 +148,7 @@ class DeviceData:
         else:
             op = words[0][:-1]
             self.__rpc_data['ops'] += [op]
-            self.__rpc_data[op] = [long(word) for word in words[1:]]
+            self.__rpc_data[op] = [int(word) for word in words[1:]]
 
     def parse_stats(self, lines):
         """Turn a list of lines from a mount stat file into a 
@@ -179,81 +179,81 @@ class DeviceData:
     def display_nfs_options(self):
         """Pretty-print the NFS options
         """
-        print 'Stats for %s mounted on %s:' % \
-            (self.__nfs_data['export'], self.__nfs_data['mountpoint'])
-
-        print '  NFS mount options: %s' % ','.join(self.__nfs_data['mountoptions'])
-        print '  NFS server capabilities: %s' % ','.join(self.__nfs_data['servercapabilities'])
-        if self.__nfs_data.has_key('nfsv4flags'):
-            print '  NFSv4 capability flags: %s' % ','.join(self.__nfs_data['nfsv4flags'])
-        if self.__nfs_data.has_key('pseudoflavor'):
-            print '  NFS security flavor: %d  pseudoflavor: %d' % \
-                (self.__nfs_data['flavor'], self.__nfs_data['pseudoflavor'])
+        print('Stats for %s mounted on %s:' % \
+            (self.__nfs_data['export'], self.__nfs_data['mountpoint']))
+
+        print('  NFS mount options: %s' % ','.join(self.__nfs_data['mountoptions']))
+        print('  NFS server capabilities: %s' % ','.join(self.__nfs_data['servercapabilities']))
+        if 'nfsv4flags' in self.__nfs_data:
+            print('  NFSv4 capability flags: %s' % ','.join(self.__nfs_data['nfsv4flags']))
+        if 'pseudoflavor' in self.__nfs_data:
+            print('  NFS security flavor: %d  pseudoflavor: %d' % \
+                (self.__nfs_data['flavor'], self.__nfs_data['pseudoflavor']))
         else:
-            print '  NFS security flavor: %d' % self.__nfs_data['flavor']
+            print('  NFS security flavor: %d' % self.__nfs_data['flavor'])
 
     def display_nfs_events(self):
         """Pretty-print the NFS event counters
         """
-        print
-        print 'Cache events:'
-        print '  data cache invalidated %d times' % self.__nfs_data['datainvalidates']
-        print '  attribute cache invalidated %d times' % self.__nfs_data['attrinvalidates']
-        print '  inodes synced %d times' % self.__nfs_data['syncinodes']
-        print
-        print 'VFS calls:'
-        print '  VFS requested %d inode revalidations' % self.__nfs_data['inoderevalidates']
-        print '  VFS requested %d dentry revalidations' % self.__nfs_data['dentryrevalidates']
-        print
-        print '  VFS called nfs_readdir() %d times' % self.__nfs_data['vfsreaddir']
-        print '  VFS called nfs_lookup() %d times' % self.__nfs_data['vfslookup']
-        print '  VFS called nfs_permission() %d times' % self.__nfs_data['vfspermission']
-        print '  VFS called nfs_file_open() %d times' % self.__nfs_data['vfsopen']
-        print '  VFS called nfs_file_flush() %d times' % self.__nfs_data['vfsflush']
-        print '  VFS called nfs_lock() %d times' % self.__nfs_data['vfslock']
-        print '  VFS called nfs_fsync() %d times' % self.__nfs_data['vfsfsync']
-        print '  VFS called nfs_file_release() %d times' % self.__nfs_data['vfsrelease']
-        print
-        print 'VM calls:'
-        print '  VFS called nfs_readpage() %d times' % self.__nfs_data['vfsreadpage']
-        print '  VFS called nfs_readpages() %d times' % self.__nfs_data['vfsreadpages']
-        print '  VFS called nfs_writepage() %d times' % self.__nfs_data['vfswritepage']
-        print '  VFS called nfs_writepages() %d times' % self.__nfs_data['vfswritepages']
-        print
-        print 'Generic NFS counters:'
-        print '  File size changing operations:'
-        print '    truncating SETATTRs: %d  extending WRITEs: %d' % \
-            (self.__nfs_data['setattrtrunc'], self.__nfs_data['extendwrite'])
-        print '  %d silly renames' % self.__nfs_data['sillyrenames']
-        print '  short reads: %d  short writes: %d' % \
-            (self.__nfs_data['shortreads'], self.__nfs_data['shortwrites'])
-        print '  NFSERR_DELAYs from server: %d' % self.__nfs_data['delay']
+        print()
+        print('Cache events:')
+        print('  data cache invalidated %d times' % self.__nfs_data['datainvalidates'])
+        print('  attribute cache invalidated %d times' % self.__nfs_data['attrinvalidates'])
+        print('  inodes synced %d times' % self.__nfs_data['syncinodes'])
+        print()
+        print('VFS calls:')
+        print('  VFS requested %d inode revalidations' % self.__nfs_data['inoderevalidates'])
+        print('  VFS requested %d dentry revalidations' % self.__nfs_data['dentryrevalidates'])
+        print()
+        print('  VFS called nfs_readdir() %d times' % self.__nfs_data['vfsreaddir'])
+        print('  VFS called nfs_lookup() %d times' % self.__nfs_data['vfslookup'])
+        print('  VFS called nfs_permission() %d times' % self.__nfs_data['vfspermission'])
+        print('  VFS called nfs_file_open() %d times' % self.__nfs_data['vfsopen'])
+        print('  VFS called nfs_file_flush() %d times' % self.__nfs_data['vfsflush'])
+        print('  VFS called nfs_lock() %d times' % self.__nfs_data['vfslock'])
+        print('  VFS called nfs_fsync() %d times' % self.__nfs_data['vfsfsync'])
+        print('  VFS called nfs_file_release() %d times' % self.__nfs_data['vfsrelease'])
+        print()
+        print('VM calls:')
+        print('  VFS called nfs_readpage() %d times' % self.__nfs_data['vfsreadpage'])
+        print('  VFS called nfs_readpages() %d times' % self.__nfs_data['vfsreadpages'])
+        print('  VFS called nfs_writepage() %d times' % self.__nfs_data['vfswritepage'])
+        print('  VFS called nfs_writepages() %d times' % self.__nfs_data['vfswritepages'])
+        print()
+        print('Generic NFS counters:')
+        print('  File size changing operations:')
+        print('    truncating SETATTRs: %d  extending WRITEs: %d' % \
+            (self.__nfs_data['setattrtrunc'], self.__nfs_data['extendwrite']))
+        print('  %d silly renames' % self.__nfs_data['sillyrenames'])
+        print('  short reads: %d  short writes: %d' % \
+            (self.__nfs_data['shortreads'], self.__nfs_data['shortwrites']))
+        print('  NFSERR_DELAYs from server: %d' % self.__nfs_data['delay'])
 
     def display_nfs_bytes(self):
         """Pretty-print the NFS event counters
         """
-        print
-        print 'NFS byte counts:'
-        print '  applications read %d bytes via read(2)' % self.__nfs_data['normalreadbytes']
-        print '  applications wrote %d bytes via write(2)' % self.__nfs_data['normalwritebytes']
-        print '  applications read %d bytes via O_DIRECT read(2)' % self.__nfs_data['directreadbytes']
-        print '  applications wrote %d bytes via O_DIRECT write(2)' % self.__nfs_data['directwritebytes']
-        print '  client read %d bytes via NFS READ' % self.__nfs_data['serverreadbytes']
-        print '  client wrote %d bytes via NFS WRITE' % self.__nfs_data['serverwritebytes']
+        print()
+        print('NFS byte counts:')
+        print('  applications read %d bytes via read(2)' % self.__nfs_data['normalreadbytes'])
+        print('  applications wrote %d bytes via write(2)' % self.__nfs_data['normalwritebytes'])
+        print('  applications read %d bytes via O_DIRECT read(2)' % self.__nfs_data['directreadbytes'])
+        print('  applications wrote %d bytes via O_DIRECT write(2)' % self.__nfs_data['directwritebytes'])
+        print('  client read %d bytes via NFS READ' % self.__nfs_data['serverreadbytes'])
+        print('  client wrote %d bytes via NFS WRITE' % self.__nfs_data['serverwritebytes'])
 
     def display_rpc_generic_stats(self):
         """Pretty-print the generic RPC stats
         """
         sends = self.__rpc_data['rpcsends']
 
-        print
-        print 'RPC statistics:'
+        print()
+        print('RPC statistics:')
 
-        print '  %d RPC requests sent, %d RPC replies received (%d XIDs not found)' % \
-            (sends, self.__rpc_data['rpcreceives'], self.__rpc_data['badxids'])
+        print('  %d RPC requests sent, %d RPC replies received (%d XIDs not found)' % \
+            (sends, self.__rpc_data['rpcreceives'], self.__rpc_data['badxids']))
         if sends != 0:
-            print '  average backlog queue length: %d' % \
-                (float(self.__rpc_data['backlogutil']) / sends)
+            print('  average backlog queue length: %d' % \
+                (float(self.__rpc_data['backlogutil']) / sends))
 
     def display_rpc_op_stats(self):
         """Pretty-print the per-op stats
@@ -261,23 +261,23 @@ class DeviceData:
         sends = self.__rpc_data['rpcsends']
 
         # XXX: these should be sorted by 'count'
-        print
+        print()
         for op in self.__rpc_data['ops']:
             stats = self.__rpc_data[op]
             count = stats[0]
             retrans = stats[1] - count
             if count != 0:
-                print '%s:' % op
-                print '\t%d ops (%d%%)' % \
-                    (count, ((count * 100) / sends)),
-                print '\t%d retrans (%d%%)' % (retrans, ((retrans * 100) / count)),
-                print '\t%d major timeouts' % stats[2]
-                print '\tavg bytes sent per op: %d\tavg bytes received per op: %d' % \
-                    (stats[3] / count, stats[4] / count)
-                print '\tbacklog wait: %f' % (float(stats[5]) / count),
-                print '\tRTT: %f' % (float(stats[6]) / count),
-                print '\ttotal execute time: %f (milliseconds)' % \
-                    (float(stats[7]) / count)
+                print('%s:' % op)
+                print('\t%d ops (%d%%)' % \
+                    (count, ((count * 100) / sends)), end=' ')
+                print('\t%d retrans (%d%%)' % (retrans, ((retrans * 100) / count)), end=' ')
+                print('\t%d major timeouts' % stats[2])
+                print('\tavg bytes sent per op: %d\tavg bytes received per op: %d' % \
+                    (stats[3] / count, stats[4] / count))
+                print('\tbacklog wait: %f' % (float(stats[5]) / count), end=' ')
+                print('\tRTT: %f' % (float(stats[6]) / count), end=' ')
+                print('\ttotal execute time: %f (milliseconds)' % \
+                    (float(stats[7]) / count))
 
     def compare_iostats(self, old_stats):
         """Return the difference between two sets of stats
@@ -285,9 +285,9 @@ class DeviceData:
         result = DeviceData()
 
         # copy self into result
-        for key, value in self.__nfs_data.iteritems():
+        for key, value in self.__nfs_data.items():
             result.__nfs_data[key] = value
-        for key, value in self.__rpc_data.iteritems():
+        for key, value in self.__rpc_data.items():
             result.__rpc_data[key] = value
 
         # compute the difference of each item in the list
@@ -295,7 +295,7 @@ class DeviceData:
         # the reference to them.  so we build new lists here
         # for the result object.
         for op in result.__rpc_data['ops']:
-            result.__rpc_data[op] = map(difference, self.__rpc_data[op], old_stats.__rpc_data[op])
+            result.__rpc_data[op] = list(map(difference, self.__rpc_data[op], old_stats.__rpc_data[op]))
 
         # update the remaining keys we care about
         result.__rpc_data['rpcsends'] -= old_stats.__rpc_data['rpcsends']
@@ -312,17 +312,17 @@ class DeviceData:
         if sample_time == 0:
             sample_time = float(self.__nfs_data['age'])
 
-        print
-        print '%s mounted on %s:' % \
-            (self.__nfs_data['export'], self.__nfs_data['mountpoint'])
+        print()
+        print('%s mounted on %s:' % \
+            (self.__nfs_data['export'], self.__nfs_data['mountpoint']))
 
-        print '\top/s\trpc bklog'
-        print '\t%.2f' % (sends / sample_time), 
+        print('\top/s\trpc bklog')
+        print('\t%.2f' % (sends / sample_time), end=' ')
         if sends != 0:
-            print '\t%.2f' % \
-                ((float(self.__rpc_data['backlogutil']) / sends) / sample_time)
+            print('\t%.2f' % \
+                ((float(self.__rpc_data['backlogutil']) / sends) / sample_time))
         else:
-            print '\t0.00'
+            print('\t0.00')
 
         # reads:  ops/s, kB/s, avg rtt, and avg exe
         # XXX: include avg xfer size and retransmits?
@@ -332,15 +332,15 @@ class DeviceData:
         rtt = float(read_rpc_stats[6])
         exe = float(read_rpc_stats[7])
 
-        print '\treads:\tops/s\t\tkB/s\t\tavg RTT (ms)\tavg exe (ms)'
-        print '\t\t%.2f' % (ops / sample_time),
-        print '\t\t%.2f' % (kilobytes / sample_time),
+        print('\treads:\tops/s\t\tkB/s\t\tavg RTT (ms)\tavg exe (ms)')
+        print('\t\t%.2f' % (ops / sample_time), end=' ')
+        print('\t\t%.2f' % (kilobytes / sample_time), end=' ')
         if ops != 0:
-            print '\t\t%.2f' % (rtt / ops),
-            print '\t\t%.2f' % (exe / ops)
+            print('\t\t%.2f' % (rtt / ops), end=' ')
+            print('\t\t%.2f' % (exe / ops))
         else:
-            print '\t\t0.00',
-            print '\t\t0.00'
+            print('\t\t0.00', end=' ')
+            print('\t\t0.00')
 
         # writes:  ops/s, kB/s, avg rtt, and avg exe
         # XXX: include avg xfer size and retransmits?
@@ -350,15 +350,15 @@ class DeviceData:
         rtt = float(write_rpc_stats[6])
         exe = float(write_rpc_stats[7])
 
-        print '\twrites:\tops/s\t\tkB/s\t\tavg RTT (ms)\tavg exe (ms)'
-        print '\t\t%.2f' % (ops / sample_time),
-        print '\t\t%.2f' % (kilobytes / sample_time),
+        print('\twrites:\tops/s\t\tkB/s\t\tavg RTT (ms)\tavg exe (ms)')
+        print('\t\t%.2f' % (ops / sample_time), end=' ')
+        print('\t\t%.2f' % (kilobytes / sample_time), end=' ')
         if ops != 0:
-            print '\t\t%.2f' % (rtt / ops),
-            print '\t\t%.2f' % (exe / ops)
+            print('\t\t%.2f' % (rtt / ops), end=' ')
+            print('\t\t%.2f' % (exe / ops))
         else:
-            print '\t\t0.00',
-            print '\t\t0.00'
+            print('\t\t0.00', end=' ')
+            print('\t\t0.00')
 
 def parse_stats_file(filename):
     """pop the contents of a mountstats file into a dictionary,
@@ -388,18 +388,18 @@ def parse_stats_file(filename):
     return ms_dict
 
 def print_mountstats_help(name):
-    print 'usage: %s [ options ] <mount point>' % name
-    print
-    print ' Version %s' % Mountstats_version
-    print
-    print ' Display NFS client per-mount statistics.'
-    print
-    print '  --version    display the version of this command'
-    print '  --nfs        display only the NFS statistics'
-    print '  --rpc        display only the RPC statistics'
-    print '  --start      sample and save statistics'
-    print '  --end        resample statistics and compare them with saved'
-    print
+    print('usage: %s [ options ] <mount point>' % name)
+    print()
+    print(' Version %s' % Mountstats_version)
+    print()
+    print(' Display NFS client per-mount statistics.')
+    print()
+    print('  --version    display the version of this command')
+    print('  --nfs        display only the NFS statistics')
+    print('  --rpc        display only the RPC statistics')
+    print('  --start      sample and save statistics')
+    print('  --end        resample statistics and compare them with saved')
+    print()
 
 def mountstats_command():
     """Mountstats command
@@ -414,7 +414,7 @@ def mountstats_command():
             return
 
         if arg in ['-v', '--version', 'version']:
-            print '%s version %s' % (sys.argv[0], Mountstats_version)
+            print('%s version %s' % (sys.argv[0], Mountstats_version))
             sys.exit(0)
 
         if arg in ['-n', '--nfs']:
@@ -426,10 +426,10 @@ def mountstats_command():
             continue
 
         if arg in ['-s', '--start']:
-            raise Exception, 'Sampling is not yet implemented'
+            raise Exception('Sampling is not yet implemented')
 
         if arg in ['-e', '--end']:
-            raise Exception, 'Sampling is not yet implemented'
+            raise Exception('Sampling is not yet implemented')
 
         if arg == sys.argv[0]:
             continue
@@ -448,14 +448,14 @@ def mountstats_command():
 
     for mp in mountpoints:
         if mp not in mountstats:
-            print 'Statistics for mount point %s not found' % mp
+            print('Statistics for mount point %s not found' % mp)
             continue
 
         stats = DeviceData()
         stats.parse_stats(mountstats[mp])
 
         if not stats.is_nfs_mountpoint():
-            print 'Mount point %s exists but is not an NFS mount' % mp
+            print('Mount point %s exists but is not an NFS mount' % mp)
             continue
 
         if nfs_only:
@@ -472,37 +472,37 @@ def mountstats_command():
            stats.display_rpc_op_stats()
 
 def print_nfsstat_help(name):
-    print 'usage: %s [ options ]' % name
-    print
-    print ' Version %s' % Mountstats_version
-    print
-    print ' nfsstat-like program that uses NFS client per-mount statistics.'
-    print
+    print('usage: %s [ options ]' % name)
+    print()
+    print(' Version %s' % Mountstats_version)
+    print()
+    print(' nfsstat-like program that uses NFS client per-mount statistics.')
+    print()
 
 def nfsstat_command():
     print_nfsstat_help(prog)
 
 def print_iostat_help(name):
-    print 'usage: %s [ <interval> [ <count> ] ] [ <mount point> ] ' % name
-    print
-    print ' Version %s' % Mountstats_version
-    print
-    print ' iostat-like program to display NFS client per-mount statistics.'
-    print
-    print ' The <interval> parameter specifies the amount of time in seconds between'
-    print ' each report.  The first report contains statistics for the time since each'
-    print ' file system was mounted.  Each subsequent report contains statistics'
-    print ' collected during the interval since the previous report.'
-    print
-    print ' If the <count> parameter is specified, the value of <count> determines the'
-    print ' number of reports generated at <interval> seconds apart.  If the interval'
-    print ' parameter is specified without the <count> parameter, the command generates'
-    print ' reports continuously.'
-    print
-    print ' If one or more <mount point> names are specified, statistics for only these'
-    print ' mount points will be displayed.  Otherwise, all NFS mount points on the'
-    print ' client are listed.'
-    print
+    print('usage: %s [ <interval> [ <count> ] ] [ <mount point> ] ' % name)
+    print()
+    print(' Version %s' % Mountstats_version)
+    print()
+    print(' iostat-like program to display NFS client per-mount statistics.')
+    print()
+    print(' The <interval> parameter specifies the amount of time in seconds between')
+    print(' each report.  The first report contains statistics for the time since each')
+    print(' file system was mounted.  Each subsequent report contains statistics')
+    print(' collected during the interval since the previous report.')
+    print()
+    print(' If the <count> parameter is specified, the value of <count> determines the')
+    print(' number of reports generated at <interval> seconds apart.  If the interval')
+    print(' parameter is specified without the <count> parameter, the command generates')
+    print(' reports continuously.')
+    print()
+    print(' If one or more <mount point> names are specified, statistics for only these')
+    print(' mount points will be displayed.  Otherwise, all NFS mount points on the')
+    print(' client are listed.')
+    print()
 
 def print_iostat_summary(old, new, devices, time):
     for device in devices:
@@ -530,7 +530,7 @@ def iostat_command():
             return
 
         if arg in ['-v', '--version', 'version']:
-            print '%s version %s' % (sys.argv[0], Mountstats_version)
+            print('%s version %s' % (sys.argv[0], Mountstats_version))
             return
 
         if arg == sys.argv[0]:
@@ -543,14 +543,14 @@ def iostat_command():
             if interval > 0:
                 interval_seen = True
             else:
-                print 'Illegal <interval> value'
+                print('Illegal <interval> value')
                 return
         elif not count_seen:
             count = int(arg)
             if count > 0:
                 count_seen = True
             else:
-                print 'Illegal <count> value'
+                print('Illegal <count> value')
                 return
 
     # make certain devices contains only NFS mount points
@@ -563,13 +563,13 @@ def iostat_command():
                 check += [device]
         devices = check
     else:
-        for device, descr in mountstats.iteritems():
+        for device, descr in mountstats.items():
             stats = DeviceData()
             stats.parse_stats(descr)
             if stats.is_nfs_mountpoint():
                 devices += [device]
     if len(devices) == 0:
-        print 'No NFS mount points were found'
+        print('No NFS mount points were found')
         return
 
     old_mountstats = None
@@ -608,7 +608,7 @@ try:
     elif prog == 'ms-iostat':
         iostat_command()
 except KeyboardInterrupt:
-    print 'Caught ^C... exiting'
+    print('Caught ^C... exiting')
     sys.exit(1)
 
 sys.exit(0)
diff --git a/tools/nfs-iostat/nfs-iostat.py b/tools/nfs-iostat/nfs-iostat.py
index c035537..1c523f9 100644
--- a/tools/nfs-iostat/nfs-iostat.py
+++ b/tools/nfs-iostat/nfs-iostat.py
@@ -95,7 +95,7 @@ class DeviceData:
             if words[6] == 'nfs':
                 self.__nfs_data['statvers'] = words[7]
         elif words[0] == 'age:':
-            self.__nfs_data['age'] = long(words[1])
+            self.__nfs_data['age'] = int(words[1])
         elif words[0] == 'opts:':
             self.__nfs_data['mountoptions'] = ''.join(words[1:]).split(',')
         elif words[0] == 'caps:':
@@ -116,7 +116,7 @@ class DeviceData:
         elif words[0] == 'bytes:':
             i = 1
             for key in NfsByteCounters:
-                self.__nfs_data[key] = long(words[i])
+                self.__nfs_data[key] = int(words[i])
                 i += 1
 
     def __parse_rpc_line(self, words):
@@ -131,8 +131,8 @@ class DeviceData:
                 self.__rpc_data['rpcsends'] = int(words[4])
                 self.__rpc_data['rpcreceives'] = int(words[5])
                 self.__rpc_data['badxids'] = int(words[6])
-                self.__rpc_data['inflightsends'] = long(words[7])
-                self.__rpc_data['backlogutil'] = long(words[8])
+                self.__rpc_data['inflightsends'] = int(words[7])
+                self.__rpc_data['backlogutil'] = int(words[8])
             elif words[1] == 'tcp':
                 self.__rpc_data['port'] = words[2]
                 self.__rpc_data['bind_count'] = int(words[3])
@@ -142,8 +142,8 @@ class DeviceData:
                 self.__rpc_data['rpcsends'] = int(words[7])
                 self.__rpc_data['rpcreceives'] = int(words[8])
                 self.__rpc_data['badxids'] = int(words[9])
-                self.__rpc_data['inflightsends'] = long(words[10])
-                self.__rpc_data['backlogutil'] = long(words[11])
+                self.__rpc_data['inflightsends'] = int(words[10])
+                self.__rpc_data['backlogutil'] = int(words[11])
             elif words[1] == 'rdma':
                 self.__rpc_data['port'] = words[2]
                 self.__rpc_data['bind_count'] = int(words[3])
@@ -169,7 +169,7 @@ class DeviceData:
         else:
             op = words[0][:-1]
             self.__rpc_data['ops'] += [op]
-            self.__rpc_data[op] = [long(word) for word in words[1:]]
+            self.__rpc_data[op] = [int(word) for word in words[1:]]
 
     def parse_stats(self, lines):
         """Turn a list of lines from a mount stat file into a 
@@ -271,7 +271,7 @@ class DeviceData:
         nfs_stats = self.__nfs_data
         lookup_ops = self.__rpc_data['LOOKUP'][0]
         readdir_ops = self.__rpc_data['READDIR'][0]
-        if self.__rpc_data.has_key('READDIRPLUS'):
+        if 'READDIRPLUS' in self.__rpc_data:
             readdir_ops += self.__rpc_data['READDIRPLUS'][0]
 
         dentry_revals = nfs_stats['dentryrevalidates']
@@ -330,7 +330,7 @@ class DeviceData:
     def __print_rpc_op_stats(self, op, sample_time):
         """Print generic stats for one RPC op
         """
-        if not self.__rpc_data.has_key(op):
+        if op not in self.__rpc_data:
             return
 
         rpc_stats = self.__rpc_data[op]
@@ -405,7 +405,7 @@ class DeviceData:
         elif which == 2:
             self.__print_rpc_op_stats('LOOKUP', sample_time)
             self.__print_rpc_op_stats('READDIR', sample_time)
-            if self.__rpc_data.has_key('READDIRPLUS'):
+            if 'READDIRPLUS' in self.__rpc_data:
                 self.__print_rpc_op_stats('READDIRPLUS', sample_time)
             self.__print_dir_cache_stats(sample_time)
         elif which == 3:
@@ -450,7 +450,7 @@ def print_iostat_summary(old, new, devices, time, options):
     if old:
         # Trim device list to only include intersection of old and new data,
         # this addresses umounts due to autofs mountpoints
-        devicelist = filter(lambda x:x in devices,old)
+        devicelist = [x for x in old if x in devices]
     else:
         devicelist = devices
 
-- 
1.8.3.1

