Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:33405 "EHLO
	mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932418AbcFNTFs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jun 2016 15:05:48 -0400
Received: by mail-io0-f196.google.com with SMTP id 5so418699ioy.0
        for <linux-nfs@vger.kernel.org>; Tue, 14 Jun 2016 12:05:48 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 12/12] NFS: Clean up nfs_direct_complete()
Date: Tue, 14 Jun 2016 15:05:15 -0400
Message-Id: <1465931115-30784-12-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1465931115-30784-11-git-send-email-trond.myklebust@primarydata.com>
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
 <1465931115-30784-11-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/direct.c | 25 ++++++++++---------------
 1 file changed, 10 insertions(+), 15 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index e1376538b473..6a55c43db187 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -372,19 +372,8 @@ out:
  * Synchronous I/O uses a stack-allocated iocb.  Thus we can't trust
  * the iocb is still valid here if this is a synchronous request.
  */
-static void nfs_direct_complete(struct nfs_direct_req *dreq, bool write)
+static void nfs_direct_complete(struct nfs_direct_req *dreq)
 {
-	struct inode *inode = dreq->inode;
-
-	if (dreq->iocb && write) {
-		loff_t pos = dreq->iocb->ki_pos + dreq->count;
-
-		spin_lock(&inode->i_lock);
-		if (i_size_read(inode) < pos)
-			i_size_write(inode, pos);
-		spin_unlock(&inode->i_lock);
-	}
-
 	if (dreq->iocb) {
 		long res = (long) dreq->error;
 		if (!res)
@@ -435,7 +424,7 @@ static void nfs_direct_read_completion(struct nfs_pgio_header *hdr)
 	}
 out_put:
 	if (put_dreq(dreq))
-		nfs_direct_complete(dreq, false);
+		nfs_direct_complete(dreq);
 	hdr->release(hdr);
 }
 
@@ -539,7 +528,7 @@ static ssize_t nfs_direct_read_schedule_iovec(struct nfs_direct_req *dreq,
 	}
 
 	if (put_dreq(dreq))
-		nfs_direct_complete(dreq, false);
+		nfs_direct_complete(dreq);
 	return 0;
 }
 
@@ -764,6 +753,7 @@ static void nfs_direct_commit_schedule(struct nfs_direct_req *dreq)
 static void nfs_direct_write_schedule_work(struct work_struct *work)
 {
 	struct nfs_direct_req *dreq = container_of(work, struct nfs_direct_req, work);
+	loff_t pos = dreq->iocb->ki_pos + dreq->count;
 	struct inode *inode = dreq->inode;
 	int flags = dreq->flags;
 
@@ -776,10 +766,15 @@ static void nfs_direct_write_schedule_work(struct work_struct *work)
 			nfs_direct_write_reschedule(dreq);
 			break;
 		default:
+			spin_lock(&inode->i_lock);
+			if (i_size_read(inode) < pos)
+				i_size_write(inode, pos);
+			spin_unlock(&inode->i_lock);
+
 			nfs_zap_mapping(inode, inode->i_mapping);
 			inode_dio_end(inode);
 
-			nfs_direct_complete(dreq, true);
+			nfs_direct_complete(dreq);
 	}
 }
 
-- 
2.5.5

