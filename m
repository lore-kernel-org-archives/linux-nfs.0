Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:13672 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753269Ab1BDVev (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Feb 2011 16:34:51 -0500
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 32/40] pnfs_submit: wave3 get rid of pnfs_call_data
Date: Fri,  4 Feb 2011 16:33:54 -0500
Message-Id: <1296855242-2592-33-git-send-email-andros@netapp.com>
In-Reply-To: <1296855242-2592-32-git-send-email-andros@netapp.com>
References: <1296855242-2592-1-git-send-email-andros@netapp.com>
 <1296855242-2592-2-git-send-email-andros@netapp.com>
 <1296855242-2592-3-git-send-email-andros@netapp.com>
 <1296855242-2592-4-git-send-email-andros@netapp.com>
 <1296855242-2592-5-git-send-email-andros@netapp.com>
 <1296855242-2592-6-git-send-email-andros@netapp.com>
 <1296855242-2592-7-git-send-email-andros@netapp.com>
 <1296855242-2592-8-git-send-email-andros@netapp.com>
 <1296855242-2592-9-git-send-email-andros@netapp.com>
 <1296855242-2592-10-git-send-email-andros@netapp.com>
 <1296855242-2592-11-git-send-email-andros@netapp.com>
 <1296855242-2592-12-git-send-email-andros@netapp.com>
 <1296855242-2592-13-git-send-email-andros@netapp.com>
 <1296855242-2592-14-git-send-email-andros@netapp.com>
 <1296855242-2592-15-git-send-email-andros@netapp.com>
 <1296855242-2592-16-git-send-email-andros@netapp.com>
 <1296855242-2592-17-git-send-email-andros@netapp.com>
 <1296855242-2592-18-git-send-email-andros@netapp.com>
 <1296855242-2592-19-git-send-email-andros@netapp.com>
 <1296855242-2592-20-git-send-email-andros@netapp.com>
 <1296855242-2592-21-git-send-email-andros@netapp.com>
 <1296855242-2592-22-git-send-email-andros@netapp.com>
 <1296855242-2592-23-git-send-email-andros@netapp.com>
 <1296855242-2592-24-git-send-email-andros@netapp.com>
 <1296855242-2592-25-git-send-email-andros@netapp.com>
 <1296855242-2592-26-git-send-email-andros@netapp.com>
 <1296855242-2592-27-git-send-email-andros@netapp.com>
 <1296855242-2592-28-git-send-email-andros@netapp.com>
 <1296855242-2592-29-git-send-email-andros@netapp.com>
 <1296855242-2592-30-git-send-email-andros@netapp.com>
 <1296855242-2592-31-git-send-email-andros@netapp.com>
 <1296855242-2592-32-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayout.c |    4 ++--
 fs/nfs/pnfs.c           |    2 +-
 include/linux/nfs_xdr.h |   12 +-----------
 3 files changed, 4 insertions(+), 14 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index fa718e1..4c841c0 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -112,14 +112,14 @@ static void filelayout_read_call_done(struct rpc_task *task, void *data)
 	}
 
 	/* Note this may cause RPC to be resent */
-	rdata->pdata.call_ops->rpc_call_done(task, data);
+	rdata->call_ops->rpc_call_done(task, data);
 }
 
 static void filelayout_read_release(void *data)
 {
 	struct nfs_read_data *rdata = (struct nfs_read_data *)data;
 
-	rdata->pdata.call_ops->rpc_release(data);
+	rdata->call_ops->rpc_release(data);
 }
 
 struct rpc_call_ops filelayout_read_call_ops = {
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 76a5e00..e96bd82 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -902,7 +902,7 @@ pnfs_try_to_read_data(struct nfs_read_data *rdata,
 	struct nfs_server *nfss = NFS_SERVER(inode);
 	enum pnfs_try_status trypnfs;
 
-	rdata->pdata.call_ops = call_ops;
+	rdata->call_ops = call_ops;
 
 	dprintk("%s: Reading ino:%lu %u@%llu\n",
 		__func__, inode->i_ino, rdata->args.count, rdata->args.offset);
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 4cf522e..3b2e488 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1004,16 +1004,6 @@ struct nfs_page;
 
 #define NFS_PAGEVEC_SIZE	(8U)
 
-#if defined(CONFIG_NFS_V4_1)
-
-/* pnfs-specific data needed for read, write, and commit calls */
-struct pnfs_call_data {
-	const struct rpc_call_ops *call_ops;
-	u32			orig_count;     /* for retry via MDS */
-	u8			how;            /* for FLUSH_STABLE */
-};
-#endif /* CONFIG_NFS_V4_1 */
-
 struct nfs_read_data {
 	int			flags;
 	struct rpc_task		task;
@@ -1032,7 +1022,7 @@ struct nfs_read_data {
 	unsigned long		timestamp;	/* For lease renewal */
 #endif
 #if defined(CONFIG_NFS_V4_1)
-	struct pnfs_call_data	pdata;
+	const struct rpc_call_ops *call_ops;
 	__u64			orig_offset; /* For filelayout dense stripe */
 #endif /* CONFIG_NFS_V4_1 */
 	struct page		*page_array[NFS_PAGEVEC_SIZE];
-- 
1.6.6

