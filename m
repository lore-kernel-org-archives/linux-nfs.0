Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:35589 "EHLO
	mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932174AbcGFWaw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Jul 2016 18:30:52 -0400
Received: by mail-it0-f65.google.com with SMTP id g4so900364ith.2
        for <linux-nfs@vger.kernel.org>; Wed, 06 Jul 2016 15:30:52 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v4 16/28] NFS: Remove racy size manipulations in O_DIRECT
Date: Wed,  6 Jul 2016 18:29:53 -0400
Message-Id: <1467844205-76852-17-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1467844205-76852-16-git-send-email-trond.myklebust@primarydata.com>
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
 <1467844205-76852-13-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-14-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-15-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-16-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On success, the RPC callbacks will ensure that we make the appropriate calls
to nfs_writeback_update_inode()

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/direct.c | 16 ----------------
 1 file changed, 16 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index fb659bb50678..826d4dace0e5 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -376,15 +376,6 @@ static void nfs_direct_complete(struct nfs_direct_req *dreq, bool write)
 {
 	struct inode *inode = dreq->inode;
 
-	if (dreq->iocb && write) {
-		loff_t pos = dreq->iocb->ki_pos + dreq->count;
-
-		spin_lock(&inode->i_lock);
-		if (i_size_read(inode) < pos)
-			i_size_write(inode, pos);
-		spin_unlock(&inode->i_lock);
-	}
-
 	if (write)
 		nfs_zap_mapping(inode, inode->i_mapping);
 
@@ -1058,14 +1049,7 @@ ssize_t nfs_file_direct_write(struct kiocb *iocb, struct iov_iter *iter)
 	if (!result) {
 		result = nfs_direct_wait(dreq);
 		if (result > 0) {
-			struct inode *inode = mapping->host;
-
 			iocb->ki_pos = pos + result;
-			spin_lock(&inode->i_lock);
-			if (i_size_read(inode) < iocb->ki_pos)
-				i_size_write(inode, iocb->ki_pos);
-			spin_unlock(&inode->i_lock);
-
 			/* XXX: should check the generic_write_sync retval */
 			generic_write_sync(iocb, result);
 		}
-- 
2.7.4

