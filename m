Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f173.google.com ([209.85.213.173]:34240 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757158AbbCCTCJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Mar 2015 14:02:09 -0500
Received: by igal13 with SMTP id l13so28090265iga.1
        for <linux-nfs@vger.kernel.org>; Tue, 03 Mar 2015 11:02:08 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] NFS: Don't write enable new pages while an invalidation is proceeding
Date: Tue,  3 Mar 2015 14:02:03 -0500
Message-Id: <1425409323-51301-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1425409323-51301-1-git-send-email-trond.myklebust@primarydata.com>
References: <1425409323-51301-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfs_vm_page_mkwrite() should wait until the page cache invalidation
is finished. This is the second patch in a 2 patch series to deprecate
the NFS client's reliance on nfs_release_page() in the context of
nfs_invalidate_mapping().

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/file.c  | 3 +++
 fs/nfs/inode.c | 1 +
 2 files changed, 4 insertions(+)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 41963ffca597..e679d24c39d3 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -623,6 +623,9 @@ static int nfs_vm_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 	/* make sure the cache has finished storing the page */
 	nfs_fscache_wait_on_page_write(NFS_I(inode), page);
 
+	wait_on_bit_action(&NFS_I(inode)->flags, NFS_INO_INVALIDATING,
+			nfs_wait_bit_killable, TASK_KILLABLE);
+
 	lock_page(page);
 	mapping = page_file_mapping(page);
 	if (mapping != inode->i_mapping)
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 8edb7d049565..d42dff6d5e98 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1035,6 +1035,7 @@ static int nfs_invalidate_mapping(struct inode *inode, struct address_space *map
 
 	if (mapping->nrpages != 0) {
 		if (S_ISREG(inode->i_mode)) {
+			unmap_mapping_range(mapping, 0, 0, 0);
 			ret = nfs_sync_mapping(mapping);
 			if (ret < 0)
 				return ret;
-- 
2.1.0

