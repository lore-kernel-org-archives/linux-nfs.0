Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:35711 "EHLO mx142.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933322AbbIYUs3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Sep 2015 16:48:29 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <linux-nfs@vger.kernel.org>, <linux-btrfs@vger.kernel.org>,
        <linux-fsdevel@vger.kernel.org>, <linux-api@vger.kernel.org>,
        <zab@zabbo.net>, <viro@zeniv.linux.org.uk>, <clm@fb.com>,
        <darrick.wong@oracle.com>, <mtk.manpages@gmail.com>,
        <andros@netapp.com>, <hch@infradead.org>
Subject: [PATCH v3 4/9] vfs: Copy should check len after file open mode
Date: Fri, 25 Sep 2015 16:48:10 -0400
Message-ID: <1443214096-12769-5-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1443214096-12769-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1443214096-12769-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I don't think it makes sense to report that a copy succeeded if the
files aren't open properly.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
Reviewed-by: David Sterba <dsterba@suse.com>
---
 fs/read_write.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/read_write.c b/fs/read_write.c
index dd10750..f3d6c48 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -1345,9 +1345,6 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
 	if (flags)
 		return -EINVAL;
 
-	if (len == 0)
-		return 0;
-
 	/* copy_file_range allows full ssize_t len, ignoring MAX_RW_COUNT  */
 	ret = rw_verify_area(READ, file_in, &pos_in, len);
 	if (ret >= 0)
@@ -1378,6 +1375,9 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
 	if (inode_in == inode_out)
 		return -EINVAL;
 
+	if (len == 0)
+		return 0;
+
 	ret = mnt_want_write_file(file_out);
 	if (ret)
 		return ret;
-- 
2.5.3

