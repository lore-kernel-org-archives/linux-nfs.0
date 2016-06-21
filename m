Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:35621 "EHLO
	mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750707AbcFUVfa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Jun 2016 17:35:30 -0400
Received: by mail-io0-f195.google.com with SMTP id u25so3727550iou.2
        for <linux-nfs@vger.kernel.org>; Tue, 21 Jun 2016 14:35:29 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 12/12] NFS: Clean up nfs_direct_complete()
Date: Tue, 21 Jun 2016 17:34:53 -0400
Message-Id: <1466544893-12058-12-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1466544893-12058-11-git-send-email-trond.myklebust@primarydata.com>
References: <1466544893-12058-1-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-2-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-3-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-4-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-5-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-6-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-7-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-8-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-9-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-10-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-11-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/direct.c | 27 ++++++++++++---------------
 1 file changed, 12 insertions(+), 15 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 92267316290a..598585eac14b 100644
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
 
@@ -775,9 +764,17 @@ static void nfs_direct_write_schedule_work(struct work_struct *work)
 			nfs_direct_write_reschedule(dreq);
 			break;
 		default:
+			if (dreq->iocb) {
+				loff_t pos = dreq->iocb->ki_pos + dreq->count;
+				spin_lock(&inode->i_lock);
+				if (i_size_read(inode) < pos)
+					i_size_write(inode, pos);
+				spin_unlock(&inode->i_lock);
+			}
+
 			nfs_zap_mapping(inode, inode->i_mapping);
 
-			nfs_direct_complete(dreq, true);
+			nfs_direct_complete(dreq);
 	}
 }
 
-- 
2.5.5

