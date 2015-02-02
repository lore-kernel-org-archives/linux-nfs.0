Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f41.google.com ([209.85.220.41]:38017 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965279AbbBBWlc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Feb 2015 17:41:32 -0500
Received: by mail-pa0-f41.google.com with SMTP id kq14so88000086pab.0
        for <linux-nfs@vger.kernel.org>; Mon, 02 Feb 2015 14:41:32 -0800 (PST)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH v6 49/53] nfs: count DIO good bytes correctly with mirroring
Date: Mon,  2 Feb 2015 14:39:03 -0800
Message-Id: <1422916747-86649-50-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1422916747-86649-1-git-send-email-loghyr@primarydata.com>
References: <1422916747-86649-1-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Peng Tao <tao.peng@primarydata.com>

When resending to MDS, we might resend multiple mirroring
requests to MDS. As a result, nfs_direct_good_bytes() ends
up counting bytes multiple times, causing application to
get wrong return results in read/write syscalls.

Fix it by tracking start of a dreq and checking the range of
pgio header.

Cc: Weston Andros Adamson <dros@primarydata.com>
Signed-off-by: Peng Tao <tao.peng@primarydata.com>
---
 fs/nfs/direct.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 93f8040..7077521 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -88,6 +88,7 @@ struct nfs_direct_req {
 
 	ssize_t			count,		/* bytes actually processed */
 				bytes_left,	/* bytes left to be sent */
+				io_start,	/* start of IO */
 				error;		/* any reported error */
 	struct completion	completion;	/* wait for i/o completion */
 
@@ -130,10 +131,11 @@ nfs_direct_good_bytes(struct nfs_direct_req *dreq, struct nfs_pgio_header *hdr)
 
 	WARN_ON_ONCE(hdr->pgio_mirror_idx >= dreq->mirror_count);
 
-	dreq->mirrors[hdr->pgio_mirror_idx].count += hdr->good_bytes;
-
-	if (hdr->pgio_mirror_idx == 0)
-		dreq->count += hdr->good_bytes;
+	count = dreq->mirrors[hdr->pgio_mirror_idx].count;
+	if (count + dreq->io_start < hdr->io_start + hdr->good_bytes) {
+		count = hdr->io_start + hdr->good_bytes - dreq->io_start;
+		dreq->mirrors[hdr->pgio_mirror_idx].count = count;
+	}
 
 	/* update the dreq->count by finding the minimum agreed count from all
 	 * mirrors */
@@ -600,6 +602,7 @@ ssize_t nfs_file_direct_read(struct kiocb *iocb, struct iov_iter *iter,
 
 	dreq->inode = inode;
 	dreq->bytes_left = count;
+	dreq->io_start = pos;
 	dreq->ctx = get_nfs_open_context(nfs_file_open_context(iocb->ki_filp));
 	l_ctx = nfs_get_lock_context(dreq->ctx);
 	if (IS_ERR(l_ctx)) {
@@ -1008,6 +1011,7 @@ ssize_t nfs_file_direct_write(struct kiocb *iocb, struct iov_iter *iter,
 
 	dreq->inode = inode;
 	dreq->bytes_left = count;
+	dreq->io_start = pos;
 	dreq->ctx = get_nfs_open_context(nfs_file_open_context(iocb->ki_filp));
 	l_ctx = nfs_get_lock_context(dreq->ctx);
 	if (IS_ERR(l_ctx)) {
-- 
1.9.3

