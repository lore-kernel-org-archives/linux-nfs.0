From: Kevin Constantine <Kevin.Constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>
Subject: [PATCH 2/2] nfs-iostat.py: Added bytes written output
Date: Mon, 20 Apr 2009 19:03:34 -0700
Message-ID: <1240279414-30528-3-git-send-email-kevin.constantine@disneyanimation.com>
References: <1240279414-30528-1-git-send-email-kevin.constantine@disneyanimation.com>
 <1240279414-30528-2-git-send-email-kevin.constantine@disneyanimation.com>
Cc: chuck.lever@oracle.com,
	Kevin Constantine <Kevin.Constantine-P5ys19MLBK/QT0dZR+AlfA@public.gmane.org>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mailgate1.disneyanimation.com ([12.188.26.101]:44588 "EHLO
	mailgate1.disneyanimation.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752789AbZDUCDg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Apr 2009 22:03:36 -0400
In-Reply-To: <1240279414-30528-2-git-send-email-kevin.constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Print statistics about bytes written by NFS

Signed-off-by: Kevin Constantine <kevin.constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>
---
 tools/nfs-iostat/nfs-iostat.py |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/tools/nfs-iostat/nfs-iostat.py b/tools/nfs-iostat/nfs-iostat.py
index d331a72..5f2e232 100644
--- a/tools/nfs-iostat/nfs-iostat.py
+++ b/tools/nfs-iostat/nfs-iostat.py
@@ -221,6 +221,7 @@ class DeviceData:
         """
         nfs_stats = self.__nfs_data
         app_bytes_read = float(nfs_stats['normalreadbytes'] + nfs_stats['directreadbytes'])
+        bytes_written_by_app = float(nfs_stats['normalwritebytes'] + nfs_stats['directwritebytes'])
         if app_bytes_read != 0:
             read_bytes_from_server = float(nfs_stats['serverreadbytes'])
             directio_bytes_from_server = float(nfs_stats['directreadbytes'])
@@ -234,6 +235,15 @@ class DeviceData:
 						cached_read_bytes / 1024.0 / 1024.0, \
 						app_bytes_read / 1024.0 / 1024.0, \
 						ratio)
+	if bytes_written_by_app != 0:
+	    bytes_written_by_nfs = float(nfs_stats['serverwritebytes'])
+	    cached_write_bytes = float(bytes_written_by_app - bytes_written_by_nfs);
+	    print
+            print '%13s %12s %15s %15s' % ("Data Written:", "To Server", "To Cache", "Total")
+	    print '%10s %13.4fMB %13.4fMB %13.4fMB' % ("", \
+	    					bytes_written_by_nfs / 1024.0 / 1024.0, \
+						cached_write_bytes / 1024.0 / 1024.0, \
+						bytes_written_by_app / 1024.0 / 1024.0)
 
     def __print_attr_cache_stats(self, sample_time):
         """Print attribute cache efficiency stats
-- 
1.6.2.1

