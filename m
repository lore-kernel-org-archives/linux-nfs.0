Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vw0-f46.google.com ([209.85.212.46]:33193 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751741Ab1K3OH7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Nov 2011 09:07:59 -0500
Received: by mail-vw0-f46.google.com with SMTP id fc26so346351vbb.19
        for <linux-nfs@vger.kernel.org>; Wed, 30 Nov 2011 06:07:59 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, khoa@us.ibm.com
Subject: [PATCH] nfs: only do COMMIT for range written with direct I/O
Date: Wed, 30 Nov 2011 09:07:54 -0500
Message-Id: <1322662074-3843-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When given a range to write with unstable writes, the current code
always does a COMMIT of the entire file afterward. This is potentially
expensive on some servers and unnecessary. Instead, just do a COMMIT for
the offset and count that was written.

Khoa, who reported this bug, stated that this made a big difference in
performance in their environment, which I believe involves GPFS on the
server. He didn't pass along any hard numbers so I can't quantify the
gain, but it stands to reason that clustered filesystems might suffer
more contention issues when issuing a commit over the whole file.

Reported-by: Khoa Huynh <khoa@us.ibm.com>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/direct.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 1940f1a..33f2be7 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -77,6 +77,7 @@ struct nfs_direct_req {
 	/* completion state */
 	atomic_t		io_count;	/* i/os we're waiting for */
 	spinlock_t		lock;		/* protect completion state */
+	loff_t			pos;		/* offset into file */
 	ssize_t			count,		/* bytes actually processed */
 				error;		/* any reported error */
 	struct completion	completion;	/* wait for i/o completion */
@@ -584,8 +585,8 @@ static void nfs_direct_commit_schedule(struct nfs_direct_req *dreq)
 	data->cred = msg.rpc_cred;
 
 	data->args.fh = NFS_FH(data->inode);
-	data->args.offset = 0;
-	data->args.count = 0;
+	data->args.offset = dreq->pos;
+	data->args.count = dreq->count;
 	data->args.context = dreq->ctx;
 	data->args.lock_context = dreq->l_ctx;
 	data->res.count = 0;
@@ -877,6 +878,7 @@ static ssize_t nfs_direct_write(struct kiocb *iocb, const struct iovec *iov,
 		sync = NFS_FILE_SYNC;
 
 	dreq->inode = inode;
+	dreq->pos = pos;
 	dreq->ctx = get_nfs_open_context(nfs_file_open_context(iocb->ki_filp));
 	dreq->l_ctx = nfs_get_lock_context(dreq->ctx);
 	if (dreq->l_ctx == NULL)
-- 
1.7.6.4

