From: Kevin Constantine <Kevin.Constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>
Subject: [PATCH 1/2] nfs-iostat.py: Print Data Cache Statistics
Date: Mon, 20 Apr 2009 19:03:33 -0700
Message-ID: <1240279414-30528-2-git-send-email-kevin.constantine@disneyanimation.com>
References: <1240279414-30528-1-git-send-email-kevin.constantine@disneyanimation.com>
Cc: chuck.lever@oracle.com,
	Kevin Constantine <Kevin.Constantine-P5ys19MLBK/QT0dZR+AlfA@public.gmane.org>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mailgate1.disneyanimation.com ([12.188.26.101]:44588 "EHLO
	mailgate1.disneyanimation.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752389AbZDUCDg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Apr 2009 22:03:36 -0400
In-Reply-To: <1240279414-30528-1-git-send-email-kevin.constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

add --data flag to print data cache statistics
print read cache stats from __print_data_cache_stats

Signed-off-by: Kevin Constantine <kevin.constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>
---
 tools/nfs-iostat/nfs-iostat.py |   26 ++++++++++++++++++++------
 1 files changed, 20 insertions(+), 6 deletions(-)

diff --git a/tools/nfs-iostat/nfs-iostat.py b/tools/nfs-iostat/nfs-iostat.py
index 9626d42..d331a72 100644
--- a/tools/nfs-iostat/nfs-iostat.py
+++ b/tools/nfs-iostat/nfs-iostat.py
@@ -220,14 +220,20 @@ class DeviceData:
         """Print the data cache hit rate
         """
         nfs_stats = self.__nfs_data
-        app_bytes_read = float(nfs_stats['normalreadbytes'])
+        app_bytes_read = float(nfs_stats['normalreadbytes'] + nfs_stats['directreadbytes'])
         if app_bytes_read != 0:
-            client_bytes_read = float(nfs_stats['serverreadbytes'] - nfs_stats['directreadbytes'])
-            ratio = ((app_bytes_read - client_bytes_read) * 100) / app_bytes_read
-
+            read_bytes_from_server = float(nfs_stats['serverreadbytes'])
+            directio_bytes_from_server = float(nfs_stats['directreadbytes'])
+            standard_read_bytes_from_server = read_bytes_from_server - directio_bytes_from_server
+            cached_read_bytes = float(app_bytes_read - read_bytes_from_server)
+            ratio = (cached_read_bytes / app_bytes_read) * 100
             print
-            print 'app bytes: %f  client bytes %f' % (app_bytes_read, client_bytes_read)
-            print 'Data cache hit ratio: %4.2f%%' % ratio
+            print '%10s %15s %15s %15s %7s' % ("Data Read:", "From Server", "From Cache", "Total", "Hit %")
+            print '%10s %13.4fMB %13.4fMB %13.4fMB %6.2f%%' % ("", \
+	    					read_bytes_from_server / 1024.0 / 1024.0, \
+						cached_read_bytes / 1024.0 / 1024.0, \
+						app_bytes_read / 1024.0 / 1024.0, \
+						ratio)
 
     def __print_attr_cache_stats(self, sample_time):
         """Print attribute cache efficiency stats
@@ -390,6 +396,10 @@ class DeviceData:
             self.__print_rpc_op_stats('READ', sample_time)
             self.__print_rpc_op_stats('WRITE', sample_time)
             self.__print_page_stats(sample_time)
+        elif which == 4:
+            self.__print_rpc_op_stats('READ', sample_time)
+            self.__print_rpc_op_stats('WRITE', sample_time)
+            self.__print_data_cache_stats()
 
 #
 # Functions
@@ -487,6 +497,10 @@ def iostat_command(name):
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

