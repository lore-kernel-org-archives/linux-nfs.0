Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:5841 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932840Ab2DTSsU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Apr 2012 14:48:20 -0400
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH v3 23/25] NFS: add dreq to nfs_commit_info
Date: Fri, 20 Apr 2012 14:47:55 -0400
Message-Id: <1334947677-28864-24-git-send-email-iisaman@netapp.com>
In-Reply-To: <1334947677-28864-1-git-send-email-iisaman@netapp.com>
References: <1334947677-28864-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Need this to pass into nfs_commitdata_init, in order to keep data->dreq
accurate.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/write.c          |    2 ++
 include/linux/nfs_xdr.h |    1 +
 2 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 333d01d..44a93d8 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -506,6 +506,7 @@ static void nfs_init_cinfo_from_inode(struct nfs_commit_info *cinfo,
 	cinfo->lock = &inode->i_lock;
 	cinfo->mds = &NFS_I(inode)->commit_info;
 	cinfo->ds = pnfs_get_ds_info(inode);
+	cinfo->dreq = NULL;
 	cinfo->completion_ops = &nfs_commit_completion_ops;
 }
 
@@ -1431,6 +1432,7 @@ void nfs_init_commit(struct nfs_commit_data *data,
 	data->lseg	  = lseg; /* reference transferred */
 	data->mds_ops     = &nfs_commit_ops;
 	data->completion_ops = cinfo->completion_ops;
+	data->dreq	  = cinfo->dreq;
 
 	data->args.fh     = NFS_FH(data->inode);
 	/* Note: we always request a commit of the entire inode */
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 756152f..3251c22 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1269,6 +1269,7 @@ struct nfs_commit_info {
 	spinlock_t			*lock;
 	struct nfs_mds_commit_info	*mds;
 	struct pnfs_ds_commit_info	*ds;
+	struct nfs_direct_req		*dreq;	/* O_DIRECT request */
 	const struct nfs_commit_completion_ops *completion_ops;
 };
 
-- 
1.7.2.1

