From: Kevin Constantine <Kevin.Constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>
Subject: [PATCH] nfs-iostat.py: Print Data Cache Statistics
Date: Tue, 21 Apr 2009 18:42:11 -0700
Message-ID: <1240364531-11499-1-git-send-email-kevin.constantine@disneyanimation.com>
References: <8EF2000D-C4D6-4AC2-B37C-221594A515B4@oracle.com>
Cc: linux-nfs@vger.kernel.org,
	Kevin Constantine <Kevin.Constantine-P5ys19MLBK/QT0dZR+AlfA@public.gmane.org>
To: chuck.lever@oracle.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mailgate2.disneyanimation.com ([12.188.26.102]:10365 "EHLO
	mailgate2.disneyanimation.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751644AbZDVBmM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Apr 2009 21:42:12 -0400
In-Reply-To: <8EF2000D-C4D6-4AC2-B37C-221594A515B4@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I rolled the read cache, and write patches into a single patch below.

add --data flag to print data cache statistics
print read cache stats from __print_data_cache_stats
print stats about bytes written by NFS

Signed-off-by: Kevin Constantine <kevin.constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>
---
 tools/nfs-iostat/nfs-iostat.py |   28 ++++++++++++++++++++++------
 1 files changed, 22 insertions(+), 6 deletions(-)

diff --git a/tools/nfs-iostat/nfs-iostat.py b/tools/nfs-iostat/nfs-iostat.py
index 9626d42..cb3da59 100644
--- a/tools/nfs-iostat/nfs-iostat.py
+++ b/tools/nfs-iostat/nfs-iostat.py
@@ -220,14 +220,22 @@ class DeviceData:
         """Print the data cache hit rate
         """
         nfs_stats = self.__nfs_data
-        app_bytes_read = float(nfs_stats['normalreadbytes'])
+        app_bytes_read = float(nfs_stats['normalreadbytes'] + nfs_stats['directreadbytes'])
         if app_bytes_read != 0:
-            client_bytes_read = float(nfs_stats['serverreadbytes'] - nfs_stats['directreadbytes'])
-            ratio = ((app_bytes_read - client_bytes_read) * 100) / app_bytes_read
-
+            cached_read_bytes = float(app_bytes_read - float(nfs_stats['serverreadbytes']))
+            ratio = (cached_read_bytes * 100) / app_bytes_read
             print
-            print 'app bytes: %f  client bytes %f' % (app_bytes_read, client_bytes_read)
-            print 'Data cache hit ratio: %4.2f%%' % ratio
+            print '%10s %15s %15s %15s %7s' % ("Data Read:", "From Server", "From Cache", "Total", "Hit %")
+            print '%10s %13.4fMB %13.4fMB %13.4fMB %6.2f%%' % ("", \
+	    					float(nfs_stats['serverreadbytes']) / 1024.0 / 1024.0, \
+						cached_read_bytes / 1024.0 / 1024.0, \
+						app_bytes_read / 1024.0 / 1024.0, \
+						ratio)
+        bytes_written_by_nfs = float(nfs_stats['serverwritebytes'])
+	if bytes_written_by_nfs != 0:
+	    print
+            print '%13s %12s' % ("Data Written:", "To Server")
+	    print '%10s %13.4fMB' % ("", bytes_written_by_nfs / 1024.0 / 1024.0)
 
     def __print_attr_cache_stats(self, sample_time):
         """Print attribute cache efficiency stats
@@ -390,6 +398,10 @@ class DeviceData:
             self.__print_rpc_op_stats('READ', sample_time)
             self.__print_rpc_op_stats('WRITE', sample_time)
             self.__print_page_stats(sample_time)
+        elif which == 4:
+            self.__print_rpc_op_stats('READ', sample_time)
+            self.__print_rpc_op_stats('WRITE', sample_time)
+            self.__print_data_cache_stats()
 
 #
 # Functions
@@ -487,6 +499,10 @@ def iostat_command(name):
         if arg in ['-p', '--page']:
             which = 3
             continue
+	
+	if arg in ['--data']:
+	    which = 4
+	    continue
 
         if arg == sys.argv[0]:
             continue
-- 
1.6.2.1

