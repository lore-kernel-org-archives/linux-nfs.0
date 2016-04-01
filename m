Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f171.google.com ([209.85.223.171]:33995 "EHLO
	mail-io0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758815AbcDAO3M (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Apr 2016 10:29:12 -0400
Received: by mail-io0-f171.google.com with SMTP id e3so153469345ioa.1
        for <linux-nfs@vger.kernel.org>; Fri, 01 Apr 2016 07:29:12 -0700 (PDT)
From: Weston Andros Adamson <dros@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH 2/2] nfs: add debug to directio "good_bytes" counting
Date: Fri,  1 Apr 2016 10:29:03 -0400
Message-Id: <1459520943-5558-3-git-send-email-dros@primarydata.com>
In-Reply-To: <1459520943-5558-1-git-send-email-dros@primarydata.com>
References: <1459520943-5558-1-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This will pop a warning if we count too many good bytes.

Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
---
 fs/nfs/direct.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 7a0cfd3266e5..5a31f2928530 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -87,6 +87,7 @@ struct nfs_direct_req {
 	int			mirror_count;
 
 	ssize_t			count,		/* bytes actually processed */
+				max_count,	/* max expected count */
 				bytes_left,	/* bytes left to be sent */
 				io_start,	/* start of IO */
 				error;		/* any reported error */
@@ -123,6 +124,8 @@ nfs_direct_good_bytes(struct nfs_direct_req *dreq, struct nfs_pgio_header *hdr)
 	int i;
 	ssize_t count;
 
+	WARN_ON_ONCE(dreq->count >= dreq->max_count);
+
 	if (dreq->mirror_count == 1) {
 		dreq->mirrors[hdr->pgio_mirror_idx].count += hdr->good_bytes;
 		dreq->count += hdr->good_bytes;
@@ -593,7 +596,7 @@ ssize_t nfs_file_direct_read(struct kiocb *iocb, struct iov_iter *iter,
 		goto out_unlock;
 
 	dreq->inode = inode;
-	dreq->bytes_left = count;
+	dreq->bytes_left = dreq->max_count = count;
 	dreq->io_start = pos;
 	dreq->ctx = get_nfs_open_context(nfs_file_open_context(iocb->ki_filp));
 	l_ctx = nfs_get_lock_context(dreq->ctx);
@@ -1026,7 +1029,7 @@ ssize_t nfs_file_direct_write(struct kiocb *iocb, struct iov_iter *iter)
 		goto out_unlock;
 
 	dreq->inode = inode;
-	dreq->bytes_left = iov_iter_count(iter);
+	dreq->bytes_left = dreq->max_count = iov_iter_count(iter);
 	dreq->io_start = pos;
 	dreq->ctx = get_nfs_open_context(nfs_file_open_context(iocb->ki_filp));
 	l_ctx = nfs_get_lock_context(dreq->ctx);
-- 
2.6.4 (Apple Git-63)

