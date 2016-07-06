Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:33197 "EHLO
	mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755885AbcGFWat (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Jul 2016 18:30:49 -0400
Received: by mail-it0-f68.google.com with SMTP id y93so926231ita.0
        for <linux-nfs@vger.kernel.org>; Wed, 06 Jul 2016 15:30:48 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v4 12/28] pNFS: Ensure we layoutcommit before revalidating attributes
Date: Wed,  6 Jul 2016 18:29:49 -0400
Message-Id: <1467844205-76852-13-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1467844205-76852-12-git-send-email-trond.myklebust@primarydata.com>
References: <1467844205-76852-1-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-2-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-3-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-4-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-5-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-6-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-7-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-8-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-9-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-10-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-11-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-12-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If we need to update the cached attributes, then we'd better make
sure that we also layoutcommit first. Otherwise, the server may have stale
attributes.

Prior to this patch, the revalidation code tried to "fix" this problem by
simply disabling attributes that would be affected by the layoutcommit.
That approach breaks nfs_writeback_check_extend(), leading to a file size
corruption.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/inode.c | 23 +++++++----------------
 1 file changed, 7 insertions(+), 16 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 4e65a5a8a01b..6c0618eb5d57 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -974,6 +974,13 @@ __nfs_revalidate_inode(struct nfs_server *server, struct inode *inode)
 	if (NFS_STALE(inode))
 		goto out;
 
+	/* pNFS: Attributes aren't updated until we layoutcommit */
+	if (S_ISREG(inode->i_mode)) {
+		status = pnfs_sync_inode(inode, false);
+		if (status)
+			goto out;
+	}
+
 	status = -ENOMEM;
 	fattr = nfs_alloc_fattr();
 	if (fattr == NULL)
@@ -1493,28 +1500,12 @@ static int nfs_inode_attrs_need_update(const struct inode *inode, const struct n
 		((long)nfsi->attr_gencount - (long)nfs_read_attr_generation_counter() > 0);
 }
 
-/*
- * Don't trust the change_attribute, mtime, ctime or size if
- * a pnfs LAYOUTCOMMIT is outstanding
- */
-static void nfs_inode_attrs_handle_layoutcommit(struct inode *inode,
-		struct nfs_fattr *fattr)
-{
-	if (pnfs_layoutcommit_outstanding(inode))
-		fattr->valid &= ~(NFS_ATTR_FATTR_CHANGE |
-				NFS_ATTR_FATTR_MTIME |
-				NFS_ATTR_FATTR_CTIME |
-				NFS_ATTR_FATTR_SIZE);
-}
-
 static int nfs_refresh_inode_locked(struct inode *inode, struct nfs_fattr *fattr)
 {
 	int ret;
 
 	trace_nfs_refresh_inode_enter(inode);
 
-	nfs_inode_attrs_handle_layoutcommit(inode, fattr);
-
 	if (nfs_inode_attrs_need_update(inode, fattr))
 		ret = nfs_update_inode(inode, fattr);
 	else
-- 
2.7.4

