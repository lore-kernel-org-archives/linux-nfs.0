Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:51331 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757753Ab1BKSAn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Feb 2011 13:00:43 -0500
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 04/17] SQUASHME rename nfs_read_data call_ops ONE
Date: Thu, 10 Feb 2011 20:52:37 -0500
Message-Id: <1297389170-26702-5-git-send-email-andros@netapp.com>
In-Reply-To: <1297389170-26702-4-git-send-email-andros@netapp.com>
References: <1297389170-26702-1-git-send-email-andros@netapp.com>
 <1297389170-26702-2-git-send-email-andros@netapp.com>
 <1297389170-26702-3-git-send-email-andros@netapp.com>
 <1297389170-26702-4-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

squash into pnfs_submit-wave3-generic-read

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/pnfs.c           |    2 +-
 include/linux/nfs_xdr.h |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index e96bd82..98dd993 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -902,7 +902,7 @@ pnfs_try_to_read_data(struct nfs_read_data *rdata,
 	struct nfs_server *nfss = NFS_SERVER(inode);
 	enum pnfs_try_status trypnfs;
 
-	rdata->call_ops = call_ops;
+	rdata->mds_ops = call_ops;
 
 	dprintk("%s: Reading ino:%lu %u@%llu\n",
 		__func__, inode->i_ino, rdata->args.count, rdata->args.offset);
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 935d8ff..4121c3e 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1019,7 +1019,7 @@ struct nfs_read_data {
 	unsigned long		timestamp;	/* For lease renewal */
 	struct pnfs_layout_segment *lseg;
 	struct nfs_client	*ds_clp;	/* pNFS data server */
-	const struct rpc_call_ops *call_ops;	/* For pNFS recovery to MDS */
+	const struct rpc_call_ops *mds_ops;
 	int (*read_done_cb) (struct rpc_task *task, struct nfs_read_data *data);
 	__u64			mds_offset;
 	struct page		*page_array[NFS_PAGEVEC_SIZE];
-- 
1.6.6

