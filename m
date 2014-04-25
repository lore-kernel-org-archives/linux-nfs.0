Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f175.google.com ([209.85.213.175]:50316 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751679AbaDYQw1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Apr 2014 12:52:27 -0400
Received: by mail-ig0-f175.google.com with SMTP id h3so2422212igd.14
        for <linux-nfs@vger.kernel.org>; Fri, 25 Apr 2014 09:52:26 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/2] nfs-iostat: Fix attribute cache statistics
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Fri, 25 Apr 2014 12:52:20 -0400
Message-ID: <20140425165220.30699.79542.stgit@manet.1015granger.net>
In-Reply-To: <20140425165211.30699.73059.stgit@manet.1015granger.net>
References: <20140425165211.30699.73059.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

"nfs-iostat.py --attr" was displaying nonsense (like negative
counts and percentages).

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 tools/nfs-iostat/nfs-iostat.py |   28 ++++++++--------------------
 1 files changed, 8 insertions(+), 20 deletions(-)

diff --git a/tools/nfs-iostat/nfs-iostat.py b/tools/nfs-iostat/nfs-iostat.py
index 6831c12..b324cd8 100644
--- a/tools/nfs-iostat/nfs-iostat.py
+++ b/tools/nfs-iostat/nfs-iostat.py
@@ -243,27 +243,15 @@ class DeviceData:
         """Print attribute cache efficiency stats
         """
         nfs_stats = self.__nfs_data
-        getattr_stats = self.__rpc_data['GETATTR']
-
-        if nfs_stats['inoderevalidates'] != 0:
-            getattr_ops = float(getattr_stats[1])
-            opens = float(nfs_stats['vfsopen'])
-            revalidates = float(nfs_stats['inoderevalidates']) - opens
-            if revalidates != 0:
-                ratio = ((revalidates - getattr_ops) * 100) / revalidates
-            else:
-                ratio = 0.0
-
-            data_invalidates = float(nfs_stats['datainvalidates'])
-            attr_invalidates = float(nfs_stats['attrinvalidates'])
 
-            print()
-            print('%d inode revalidations, hitting in cache %4.2f%% of the time' % \
-                (revalidates, ratio))
-            print('%d open operations (mandatory GETATTR requests)' % opens)
-            if getattr_ops != 0:
-                print('%4.2f%% of GETATTRs resulted in data cache invalidations' % \
-                   ((data_invalidates * 100) / getattr_ops))
+        print()
+        print('%d VFS opens' % (nfs_stats['vfsopen']))
+        print('%d inoderevalidates (forced GETATTRs)' % \
+            (nfs_stats['inoderevalidates']))
+        print('%d page cache invalidations' % \
+            (nfs_stats['datainvalidates']))
+        print('%d attribute cache invalidations' % \
+            (nfs_stats['attrinvalidates']))
 
     def __print_dir_cache_stats(self, sample_time):
         """Print directory stats

