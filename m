Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:23881 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932538Ab2FAVPN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Jun 2012 17:15:13 -0400
From: andros@netapp.com
To: iisaman@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [[PATCH resend] 5/6] PYNFS: add mdsthreshold to file layout server
Date: Tue, 29 May 2012 18:11:28 -0400
Message-Id: <1338329489-29178-6-git-send-email-andros@netapp.com>
In-Reply-To: <1338329489-29178-1-git-send-email-andros@netapp.com>
References: <1338329489-29178-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

NOTE: values are hard coded and apply to all files. Edit nfs4server.py to
change the values.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 nfs4.1/fs.py      |    9 ++++++++-
 nfs4.1/nfs4lib.py |    2 +-
 2 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/nfs4.1/fs.py b/nfs4.1/fs.py
index 2d92d77..c0f18fa 100644
--- a/nfs4.1/fs.py
+++ b/nfs4.1/fs.py
@@ -1,6 +1,6 @@
 from nfs4state import FileState
 from nfs4_const import *
-from nfs4_type import fsid4, layout4, layout_content4, nfsv4_1_file_layout4
+from nfs4_type import fsid4, layout4, layout_content4, nfsv4_1_file_layout4, mdsthreshold4, threshold_item4
 import nfs4lib
 from nfs4lib import NFS4Error
 import struct
@@ -1429,6 +1429,13 @@ class FileLayoutFS(FileSystem):
         self.fattr4_maxread = 8192
         self.fattr4_supported_attrs |= 1 << FATTR4_MAXWRITE
         self.fattr4_supported_attrs |= 1 << FATTR4_MAXREAD
+        threshold_item4.thi_layout_type = LAYOUT4_NFSV4_1_FILES
+        # set mdsthreashold read_size, read_iosize and write_iosize
+        threshold_item4.thi_hintset = nfs4lib.list2bitmap([0, 2, 3])
+        threshold_item4.thi_hintlist = struct.pack('!QQQ',512,512,512)
+        mdsthreshold4.mth_hints = [threshold_item4]
+        self.fattr4_mdsthreshold = mdsthreshold4
+        self.fattr4_supported_attrs |= 1 << FATTR4_MDSTHRESHOLD
         self.sync(self.root, FILE_SYNC4)
 
     def attach_to_server(self, server):
diff --git a/nfs4.1/nfs4lib.py b/nfs4.1/nfs4lib.py
index 82045a7..a380cce 100644
--- a/nfs4.1/nfs4lib.py
+++ b/nfs4.1/nfs4lib.py
@@ -676,7 +676,7 @@ attr_info = { FATTR4_SUPPORTED_ATTRS : A("r", "fs"),
               FATTR4_LAYOUT_BLKSIZE : A("r", "fs"),
               FATTR4_LAYOUT_ALIGNMENT : A("r", "obj"),
               FATTR4_FS_LOCATIONS_INFO : A("r", "fs"),
-              FATTR4_MDSTHRESHOLD : A("r", "obj"),
+              FATTR4_MDSTHRESHOLD : A("r", "fs"),
               FATTR4_RETENTION_GET : A("r", "obj"),
               FATTR4_RETENTION_SET : A("w", "obj"),
               FATTR4_RETENTEVT_GET : A("r", "obj"),
-- 
1.7.7.6

