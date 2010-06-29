Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:53719 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755232Ab0F2LSX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Jun 2010 07:18:23 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfs: fix possible leak in nfs_proc_symlink
Date: Tue, 29 Jun 2010 14:18:19 +0300
Message-Id: <1277810299-13471-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

If only nfs_alloc_fhandle XOR nfs_alloc_fattr returns NULL
the function fails to free the other struct.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/proc.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index 52790a4..1837a05 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -443,7 +443,7 @@ nfs_proc_symlink(struct inode *dir, struct dentry *dentry, struct page *page,
 	fattr = nfs_alloc_fattr();
 	status = -ENOMEM;
 	if (fh == NULL || fattr == NULL)
-		goto out;
+		goto out_free;
 
 	status = rpc_call_sync(NFS_CLIENT(dir), &msg, 0);
 	nfs_mark_for_revalidate(dir);
@@ -455,7 +455,7 @@ nfs_proc_symlink(struct inode *dir, struct dentry *dentry, struct page *page,
 	 */
 	if (status == 0)
 		status = nfs_instantiate(dentry, fh, fattr);
-
+out_free:
 	nfs_free_fattr(fattr);
 	nfs_free_fhandle(fh);
 out:
-- 
1.6.6.1

