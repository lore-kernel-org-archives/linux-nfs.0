Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:35703 "EHLO
	mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932224AbcFNTFs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jun 2016 15:05:48 -0400
Received: by mail-io0-f193.google.com with SMTP id n127so408268iof.2
        for <linux-nfs@vger.kernel.org>; Tue, 14 Jun 2016 12:05:47 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 11/12] NFS: Don't count O_DIRECT reads in the inode->i_dio_count
Date: Tue, 14 Jun 2016 15:05:14 -0400
Message-Id: <1465931115-30784-11-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1465931115-30784-10-git-send-email-trond.myklebust@primarydata.com>
References: <1465931115-30784-1-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-2-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-3-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-4-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-5-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-6-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-7-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-8-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-9-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-10-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/direct.c | 11 ++++-------
 1 file changed, 4 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 81b19c0fd3a3..e1376538b473 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -385,11 +385,6 @@ static void nfs_direct_complete(struct nfs_direct_req *dreq, bool write)
 		spin_unlock(&inode->i_lock);
 	}
 
-	if (write)
-		nfs_zap_mapping(inode, inode->i_mapping);
-
-	inode_dio_end(inode);
-
 	if (dreq->iocb) {
 		long res = (long) dreq->error;
 		if (!res)
@@ -488,7 +483,6 @@ static ssize_t nfs_direct_read_schedule_iovec(struct nfs_direct_req *dreq,
 			     &nfs_direct_read_completion_ops);
 	get_dreq(dreq);
 	desc.pg_dreq = dreq;
-	inode_dio_begin(inode);
 
 	while (iov_iter_count(iter)) {
 		struct page **pagevec;
@@ -540,7 +534,6 @@ static ssize_t nfs_direct_read_schedule_iovec(struct nfs_direct_req *dreq,
 	 * generic layer handle the completion.
 	 */
 	if (requested_bytes == 0) {
-		inode_dio_end(inode);
 		nfs_direct_req_release(dreq);
 		return result < 0 ? result : -EIO;
 	}
@@ -771,6 +764,7 @@ static void nfs_direct_commit_schedule(struct nfs_direct_req *dreq)
 static void nfs_direct_write_schedule_work(struct work_struct *work)
 {
 	struct nfs_direct_req *dreq = container_of(work, struct nfs_direct_req, work);
+	struct inode *inode = dreq->inode;
 	int flags = dreq->flags;
 
 	dreq->flags = 0;
@@ -782,6 +776,9 @@ static void nfs_direct_write_schedule_work(struct work_struct *work)
 			nfs_direct_write_reschedule(dreq);
 			break;
 		default:
+			nfs_zap_mapping(inode, inode->i_mapping);
+			inode_dio_end(inode);
+
 			nfs_direct_complete(dreq, true);
 	}
 }
-- 
2.5.5

