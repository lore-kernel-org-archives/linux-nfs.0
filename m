Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:11635 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932814AbcKWSty (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 23 Nov 2016 13:49:54 -0500
From: <Anna.Schumaker@Netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
CC: <Anna.Schumaker@Netapp.com>
Subject: [PATCH] NFS: Remove unused argument from nfs_direct_write_complete()
Date: Wed, 23 Nov 2016 13:49:38 -0500
Message-ID: <20161123184938.13409-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

This parameter hasn't been used since 2a009ec9 (Linux 3.13-rc3), so
let's remove it from this function.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/direct.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 5935975..d7c1f7a 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -105,7 +105,7 @@ struct nfs_direct_req {
 
 static const struct nfs_pgio_completion_ops nfs_direct_write_completion_ops;
 static const struct nfs_commit_completion_ops nfs_direct_commit_completion_ops;
-static void nfs_direct_write_complete(struct nfs_direct_req *dreq, struct inode *inode);
+static void nfs_direct_write_complete(struct nfs_direct_req *dreq);
 static void nfs_direct_write_schedule_work(struct work_struct *work);
 
 static inline void get_dreq(struct nfs_direct_req *dreq)
@@ -674,7 +674,7 @@ static void nfs_direct_write_reschedule(struct nfs_direct_req *dreq)
 	}
 
 	if (put_dreq(dreq))
-		nfs_direct_write_complete(dreq, dreq->inode);
+		nfs_direct_write_complete(dreq);
 }
 
 static void nfs_direct_commit_complete(struct nfs_commit_data *data)
@@ -700,7 +700,7 @@ static void nfs_direct_commit_complete(struct nfs_commit_data *data)
 	}
 
 	if (atomic_dec_and_test(&cinfo.mds->rpcs_out))
-		nfs_direct_write_complete(dreq, data->inode);
+		nfs_direct_write_complete(dreq);
 }
 
 static void nfs_direct_resched_write(struct nfs_commit_info *cinfo,
@@ -751,7 +751,7 @@ static void nfs_direct_write_schedule_work(struct work_struct *work)
 	}
 }
 
-static void nfs_direct_write_complete(struct nfs_direct_req *dreq, struct inode *inode)
+static void nfs_direct_write_complete(struct nfs_direct_req *dreq)
 {
 	schedule_work(&dreq->work); /* Calls nfs_direct_write_schedule_work */
 }
@@ -807,7 +807,7 @@ static void nfs_direct_write_completion(struct nfs_pgio_header *hdr)
 
 out_put:
 	if (put_dreq(dreq))
-		nfs_direct_write_complete(dreq, hdr->inode);
+		nfs_direct_write_complete(dreq);
 	hdr->release(hdr);
 }
 
@@ -936,7 +936,7 @@ static ssize_t nfs_direct_write_schedule_iovec(struct nfs_direct_req *dreq,
 	}
 
 	if (put_dreq(dreq))
-		nfs_direct_write_complete(dreq, dreq->inode);
+		nfs_direct_write_complete(dreq);
 	return 0;
 }
 
-- 
2.10.2

