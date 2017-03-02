Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:23369 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754631AbdCBQDU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 2 Mar 2017 11:03:20 -0500
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [RFC v1 03/19] VFS don't try clone if superblocks are different
Date: Thu, 2 Mar 2017 11:01:07 -0500
Message-ID: <20170302160123.30375-4-kolga@netapp.com>
In-Reply-To: <20170302160123.30375-1-kolga@netapp.com>
References: <20170302160123.30375-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Only try clone_file_range if superblocks are the same.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/read_write.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/read_write.c b/fs/read_write.c
index 75084cd..00161bd 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -1543,7 +1543,8 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
 	 * Try cloning first, this is supported by more file systems, and
 	 * more efficient if both clone and copy are supported (e.g. NFS).
 	 */
-	if (file_in->f_op->clone_file_range) {
+	if (inode_in->i_sb == inode_out->i_sb &&
+			file_in->f_op->clone_file_range) {
 		ret = file_in->f_op->clone_file_range(file_in, pos_in,
 				file_out, pos_out, len);
 		if (ret == 0) {
-- 
1.8.3.1

