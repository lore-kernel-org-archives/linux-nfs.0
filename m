Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:34077 "EHLO
	mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751870AbcFWUBe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Jun 2016 16:01:34 -0400
Received: by mail-io0-f193.google.com with SMTP id 100so13299734ioh.1
        for <linux-nfs@vger.kernel.org>; Thu, 23 Jun 2016 13:01:34 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v4 14/17] NFS: Cleanup nfs_direct_complete()
Date: Thu, 23 Jun 2016 16:00:46 -0400
Message-Id: <1466712049-5326-14-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1466712049-5326-13-git-send-email-trond.myklebust@primarydata.com>
References: <1466712049-5326-1-git-send-email-trond.myklebust@primarydata.com>
 <1466712049-5326-2-git-send-email-trond.myklebust@primarydata.com>
 <1466712049-5326-3-git-send-email-trond.myklebust@primarydata.com>
 <1466712049-5326-4-git-send-email-trond.myklebust@primarydata.com>
 <1466712049-5326-5-git-send-email-trond.myklebust@primarydata.com>
 <1466712049-5326-6-git-send-email-trond.myklebust@primarydata.com>
 <1466712049-5326-7-git-send-email-trond.myklebust@primarydata.com>
 <1466712049-5326-8-git-send-email-trond.myklebust@primarydata.com>
 <1466712049-5326-9-git-send-email-trond.myklebust@primarydata.com>
 <1466712049-5326-10-git-send-email-trond.myklebust@primarydata.com>
 <1466712049-5326-11-git-send-email-trond.myklebust@primarydata.com>
 <1466712049-5326-12-git-send-email-trond.myklebust@primarydata.com>
 <1466712049-5326-13-git-send-email-trond.myklebust@primarydata.com>
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

