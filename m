Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f172.google.com ([209.85.213.172]:37556 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754390AbaDQDKH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Apr 2014 23:10:07 -0400
Received: by mail-ig0-f172.google.com with SMTP id hn18so1818411igb.5
        for <linux-nfs@vger.kernel.org>; Wed, 16 Apr 2014 20:10:06 -0700 (PDT)
From: Weston Andros Adamson <dros@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH] nfs4.1 server: fs_layout_types in supported_attrs
Date: Wed, 16 Apr 2014 23:10:03 -0400
Message-Id: <1397704203-5421-1-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since the new .x it's "fattr4_fs_layout_types", not "fattr4_fs_layout_type"

Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
---
 nfs4.1/fs.py | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/nfs4.1/fs.py b/nfs4.1/fs.py
index 16e9e7c..a63c5bf 100644
--- a/nfs4.1/fs.py
+++ b/nfs4.1/fs.py
@@ -356,7 +356,7 @@ class FSObject(object):
         if not fs.fattr4_supported_attrs & (1 << FATTR4_FS_LAYOUT_TYPES):
             raise NFS4Error(NFS4ERR_LAYOUTUNAVAILABLE)
         try:
-            types = fs.fattr4_fs_layout_type
+            types = fs.fattr4_fs_layout_types
         except:
             raise NFS4Error(NFS4ERR_LAYOUTUNAVAILABLE)
         if arg.loga_layout_type not in types:
@@ -1279,7 +1279,7 @@ class BlockLayoutFS(FileSystem):
         self._nextid = 0
         FileSystem.__init__(self, objclass=LayoutFSObj)
         self.fsid = (3, fsid)
-        self.fattr4_fs_layout_type = [LAYOUT4_BLOCK_VOLUME]
+        self.fattr4_fs_layout_types = [LAYOUT4_BLOCK_VOLUME]
         self.fattr4_supported_attrs |= 1 << FATTR4_FS_LAYOUT_TYPES
         self.fattr4_layout_blksize = 4096
         self.fattr4_supported_attrs |= 1 << FATTR4_LAYOUT_BLKSIZE
@@ -1427,7 +1427,7 @@ class FileLayoutFS(FileSystem):
         self.dsdevice = dsdevice
         FileSystem.__init__(self, objclass=FSLayoutFSObj)
         self.fsid = (2, fsid)
-        self.fattr4_fs_layout_type = [LAYOUT4_NFSV4_1_FILES]
+        self.fattr4_fs_layout_types = [LAYOUT4_NFSV4_1_FILES]
         self.fattr4_supported_attrs |= 1 << FATTR4_FS_LAYOUT_TYPES
         self.fattr4_maxwrite = 8192
         self.fattr4_maxread = 8192
-- 
1.8.5.2 (Apple Git-48)

