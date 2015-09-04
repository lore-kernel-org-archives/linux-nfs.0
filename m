Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:6800 "EHLO mx144.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932596AbbIDR34 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Sep 2015 13:29:56 -0400
From: <andros@netapp.com>
To: <trond.myklebust@primarydata.com>
CC: <anna.schumaker@netapp.com>, <bfields@fieldses.org>,
        <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 2 02/16] BTRFS: Use VFS copy offload helper
Date: Fri, 4 Sep 2015 13:29:24 -0400
Message-ID: <1441387778-16465-3-git-send-email-andros@netapp.com>
In-Reply-To: <1441387778-16465-1-git-send-email-andros@netapp.com>
References: <1441387778-16465-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/btrfs/ioctl.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/btrfs/ioctl.c b/fs/btrfs/ioctl.c
index 62ae286..f8fa11f 100644
--- a/fs/btrfs/ioctl.c
+++ b/fs/btrfs/ioctl.c
@@ -3856,6 +3856,9 @@ ssize_t btrfs_copy_file_range(struct file *file_in, loff_t pos_in,
 {
 	ssize_t ret;
 
+	ret = copy_offload_same_fs(file_in, file_out);
+	if (ret != 0)
+		return ret;
 	ret = btrfs_clone_files(file_out, file_in, pos_in, len, pos_out);
 	if (ret == 0)
 		ret = len;
-- 
1.8.3.1

