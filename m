Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:35940 "EHLO
	mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932298AbcGFWa5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Jul 2016 18:30:57 -0400
Received: by mail-it0-f65.google.com with SMTP id h190so900920ith.3
        for <linux-nfs@vger.kernel.org>; Wed, 06 Jul 2016 15:30:56 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v4 20/28] NFS: Cleanup nfs_direct_complete()
Date: Wed,  6 Jul 2016 18:29:57 -0400
Message-Id: <1467844205-76852-21-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1467844205-76852-20-git-send-email-trond.myklebust@primarydata.com>
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
 <1467844205-76852-17-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-18-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-19-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-20-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There is only one caller that sets the "write" argument to true,
so just move the call to nfs_zap_mapping() and get rid of the
now redundant argument.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/direct.c | 12 +++++-------
 1 file changed, 5 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 6d0e88096440..c16d33eb1ddf 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -372,13 +372,10 @@ out:
  * Synchronous I/O uses a stack-allocated iocb.  Thus we can't trust
  * the iocb is still valid here if this is a synchronous request.
  */
-static void nfs_direct_complete(struct nfs_direct_req *dreq, bool write)
+static void nfs_direct_complete(struct nfs_direct_req *dreq)
 {
 	struct inode *inode = dreq->inode;
 
-	if (write)
-		nfs_zap_mapping(inode, inode->i_mapping);
-
 	inode_dio_end(inode);
 
 	if (dreq->iocb) {
@@ -431,7 +428,7 @@ static void nfs_direct_read_completion(struct nfs_pgio_header *hdr)
 	}
 out_put:
 	if (put_dreq(dreq))
-		nfs_direct_complete(dreq, false);
+		nfs_direct_complete(dreq);
 	hdr->release(hdr);
 }
 
@@ -537,7 +534,7 @@ static ssize_t nfs_direct_read_schedule_iovec(struct nfs_direct_req *dreq,
 	}
 
 	if (put_dreq(dreq))
-		nfs_direct_complete(dreq, false);
+		nfs_direct_complete(dreq);
 	return 0;
 }
 
@@ -764,7 +761,8 @@ static void nfs_direct_write_schedule_work(struct work_struct *work)
 			nfs_direct_write_reschedule(dreq);
 			break;
 		default:
-			nfs_direct_complete(dreq, true);
+			nfs_zap_mapping(dreq->inode, dreq->inode->i_mapping);
+			nfs_direct_complete(dreq);
 	}
 }
 
-- 
2.7.4

