Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:52316 "EHLO mx142.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760608AbbIDUR0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Sep 2015 16:17:26 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <linux-nfs@vger.kernel.org>, <linux-btrfs@vger.kernel.org>,
        <linux-fsdevel@vger.kernel.org>, <linux-api@vger.kernel.org>,
        <zab@zabbo.net>, <viro@zeniv.linux.org.uk>, <clm@fb.com>,
        <darrick.wong@oracle.com>, <mtk.manpages@gmail.com>,
        <andros@netapp.com>, <hch@infradead.org>
Subject: [PATCH v1 4/8] btrfs: Add mountpoint checking during btrfs_copy_file_range
Date: Fri, 4 Sep 2015 16:16:58 -0400
Message-ID: <1441397823-1203-5-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1441397823-1203-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1441397823-1203-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We need to verify that both the source and the destination files are
part of the same filesystem, otherwise we can't create a reflink.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/btrfs/ioctl.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/fs/btrfs/ioctl.c b/fs/btrfs/ioctl.c
index 62ae286..9c0c955 100644
--- a/fs/btrfs/ioctl.c
+++ b/fs/btrfs/ioctl.c
@@ -3856,6 +3856,10 @@ ssize_t btrfs_copy_file_range(struct file *file_in, loff_t pos_in,
 {
 	ssize_t ret;
 
+	if (inode_in->i_sb != inode_out->i_sb ||
+	    file_in->f_path.mnt != file_out->f_path.mnt)
+		return -EXDEV;
+
 	ret = btrfs_clone_files(file_out, file_in, pos_in, len, pos_out);
 	if (ret == 0)
 		ret = len;
-- 
2.5.1

