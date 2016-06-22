Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:36835 "EHLO
	mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752326AbcFVUsb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Jun 2016 16:48:31 -0400
Received: by mail-io0-f196.google.com with SMTP id s63so9104716ioi.3
        for <linux-nfs@vger.kernel.org>; Wed, 22 Jun 2016 13:48:31 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 11/13] NFS: Remove racy size manipulations in O_DIRECT
Date: Wed, 22 Jun 2016 16:47:46 -0400
Message-Id: <1466628468-3958-11-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1466628468-3958-10-git-send-email-trond.myklebust@primarydata.com>
References: <1466628468-3958-1-git-send-email-trond.myklebust@primarydata.com>
 <1466628468-3958-2-git-send-email-trond.myklebust@primarydata.com>
 <1466628468-3958-3-git-send-email-trond.myklebust@primarydata.com>
 <1466628468-3958-4-git-send-email-trond.myklebust@primarydata.com>
 <1466628468-3958-5-git-send-email-trond.myklebust@primarydata.com>
 <1466628468-3958-6-git-send-email-trond.myklebust@primarydata.com>
 <1466628468-3958-7-git-send-email-trond.myklebust@primarydata.com>
 <1466628468-3958-8-git-send-email-trond.myklebust@primarydata.com>
 <1466628468-3958-9-git-send-email-trond.myklebust@primarydata.com>
 <1466628468-3958-10-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On success, the RPC callbacks will ensure that we make the appropriate calls
to nfs_writeback_update_inode()

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/direct.c | 16 ----------------
 1 file changed, 16 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 2333e9973802..d96a4b7aa5c0 100644
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

