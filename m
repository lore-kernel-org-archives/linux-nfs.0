Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f179.google.com ([209.85.192.179]:55737 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753860AbbAVXim (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Jan 2015 18:38:42 -0500
Received: by mail-pd0-f179.google.com with SMTP id v10so4590306pde.10
        for <linux-nfs@vger.kernel.org>; Thu, 22 Jan 2015 15:38:41 -0800 (PST)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH v5 49/51] nfs: count DIO good bytes correctly with mirroring
Date: Thu, 22 Jan 2015 15:36:21 -0800
Message-Id: <1421969783-92997-50-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1421969783-92997-1-git-send-email-loghyr@primarydata.com>
References: <1421969783-92997-1-git-send-email-loghyr@primarydata.com>
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
index 4fad6b7..3715b49 100644
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
@@ -594,6 +596,7 @@ ssize_t nfs_file_direct_read(struct kiocb *iocb, struct iov_iter *iter,
 
 	dreq->inode = inode;
 	dreq->bytes_left = count;
+	dreq->io_start = pos;
 	dreq->ctx = get_nfs_open_context(nfs_file_open_context(iocb->ki_filp));
 	l_ctx = nfs_get_lock_context(dreq->ctx);
 	if (IS_ERR(l_ctx)) {
@@ -1002,6 +1005,7 @@ ssize_t nfs_file_direct_write(struct kiocb *iocb, struct iov_iter *iter,
 
 	dreq->inode = inode;
 	dreq->bytes_left = count;
+	dreq->io_start = pos;
 	dreq->ctx = get_nfs_open_context(nfs_file_open_context(iocb->ki_filp));
 	l_ctx = nfs_get_lock_context(dreq->ctx);
 	if (IS_ERR(l_ctx)) {
-- 
1.9.3

