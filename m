Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yx0-f174.google.com ([209.85.213.174]:35495 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751403Ab2HMOkV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Aug 2012 10:40:21 -0400
Received: by yenl14 with SMTP id l14so1982967yen.19
        for <linux-nfs@vger.kernel.org>; Mon, 13 Aug 2012 07:40:21 -0700 (PDT)
From: Peng Tao <bergwolf@gmail.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, bharrosh@panasas.com,
        Peng Tao <tao.peng@emc.com>
Subject: [PATCH-v2 1/3] NFS: track direct IO left bytes
Date: Mon, 13 Aug 2012 22:39:34 +0800
Message-Id: <1344868776-1739-1-git-send-email-bergwolf@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Peng Tao <tao.peng@emc.com>
---
 fs/nfs/direct.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 34a6282..c39f775 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -78,6 +78,7 @@ struct nfs_direct_req {
 	atomic_t		io_count;	/* i/os we're waiting for */
 	spinlock_t		lock;		/* protect completion state */
 	ssize_t			count,		/* bytes actually processed */
+				bytes_left,	/* bytes left to be sent */
 				error;		/* any reported error */
 	struct completion	completion;	/* wait for i/o completion */
 
@@ -390,6 +391,7 @@ static ssize_t nfs_direct_read_schedule_segment(struct nfs_pageio_descriptor *de
 			user_addr += req_len;
 			pos += req_len;
 			count -= req_len;
+			dreq->bytes_left -= req_len;
 		}
 		/* The nfs_page now hold references to these pages */
 		nfs_direct_release_pages(pagevec, npages);
@@ -456,6 +458,7 @@ static ssize_t nfs_direct_read(struct kiocb *iocb, const struct iovec *iov,
 		goto out;
 
 	dreq->inode = inode;
+	dreq->bytes_left = iov_length(iov, nr_segs);
 	dreq->ctx = get_nfs_open_context(nfs_file_open_context(iocb->ki_filp));
 	dreq->l_ctx = nfs_get_lock_context(dreq->ctx);
 	if (dreq->l_ctx == NULL)
@@ -706,6 +709,7 @@ static ssize_t nfs_direct_write_schedule_segment(struct nfs_pageio_descriptor *d
 			user_addr += req_len;
 			pos += req_len;
 			count -= req_len;
+			dreq->bytes_left -= req_len;
 		}
 		/* The nfs_page now hold references to these pages */
 		nfs_direct_release_pages(pagevec, npages);
@@ -855,6 +859,7 @@ static ssize_t nfs_direct_write(struct kiocb *iocb, const struct iovec *iov,
 		goto out;
 
 	dreq->inode = inode;
+	dreq->bytes_left = count;
 	dreq->ctx = get_nfs_open_context(nfs_file_open_context(iocb->ki_filp));
 	dreq->l_ctx = nfs_get_lock_context(dreq->ctx);
 	if (dreq->l_ctx == NULL)
-- 
1.7.1.262.g5ef3d

