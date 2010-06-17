From: andros@netapp.com
Subject: [PATCH 6/7] pnfs-post-submit: restore cleanup_layoutcommit
Date: Thu, 17 Jun 2010 15:34:55 -0400
Message-ID: <1276803296-9438-7-git-send-email-andros@netapp.com>
References: <1276803296-9438-1-git-send-email-andros@netapp.com>
 <1276803296-9438-2-git-send-email-andros@netapp.com>
 <1276803296-9438-3-git-send-email-andros@netapp.com>
 <1276803296-9438-4-git-send-email-andros@netapp.com>
 <1276803296-9438-5-git-send-email-andros@netapp.com>
 <1276803296-9438-6-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.212.112.111]:56798 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760306Ab0FQTfc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Jun 2010 15:35:32 -0400
In-Reply-To: <1276803296-9438-6-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4proc.c         |    1 +
 fs/nfs/pnfs.c             |   13 +++++++++++++
 fs/nfs/pnfs.h             |    1 +
 include/linux/nfs4_pnfs.h |    3 +++
 4 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 71cb928..9328a46 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5635,6 +5635,7 @@ static void pnfs_layoutcommit_release(void *lcdata)
 	struct pnfs_layoutcommit_data *data =
 		(struct pnfs_layoutcommit_data *)lcdata;
 
+	pnfs_cleanup_layoutcommit(lcdata);
 	put_rpccred(data->cred);
 	pnfs_layoutcommit_free(lcdata);
 }
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index a2754aa..cdadddd 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1554,6 +1554,19 @@ pnfs_commit(struct nfs_write_data *data, int sync)
 	return trypnfs;
 }
 
+void pnfs_cleanup_layoutcommit(struct pnfs_layoutcommit_data *data)
+{
+	struct nfs_server *nfss = NFS_SERVER(data->args.inode);
+
+	/* TODO: Maybe we should avoid this by allowing the layout driver
+	* to directly xdr its layout on the wire.
+	*/
+	if (nfss->pnfs_curr_ld->ld_io_ops->cleanup_layoutcommit)
+		nfss->pnfs_curr_ld->ld_io_ops->cleanup_layoutcommit(
+					&NFS_I(data->args.inode)->layout,
+					&data->args, data->status);
+}
+
 /*
  * Set up the argument/result storage required for the RPC call.
  */
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 78776f3..ed4191b 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -49,6 +49,7 @@ enum pnfs_try_status _pnfs_try_to_read_data(struct nfs_read_data *,
 int pnfs_initialize(void);
 void pnfs_uninitialize(void);
 void pnfs_layoutcommit_free(struct pnfs_layoutcommit_data *data);
+void pnfs_cleanup_layoutcommit(struct pnfs_layoutcommit_data *data);
 int pnfs_layoutcommit_inode(struct inode *inode, int sync);
 void pnfs_update_last_write(struct nfs_inode *nfsi, loff_t offset, size_t extent);
 void pnfs_need_layoutcommit(struct nfs_inode *nfsi, struct nfs_open_context *ctx);
diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
index 93fccfd..3ff1dc3 100644
--- a/include/linux/nfs4_pnfs.h
+++ b/include/linux/nfs4_pnfs.h
@@ -157,6 +157,9 @@ struct layoutdriver_io_operations {
 	void (*encode_layoutcommit) (struct pnfs_layout_type *layoutid,
 				struct xdr_stream *xdr,
 				const struct pnfs_layoutcommit_arg *args);
+	void (*cleanup_layoutcommit) (struct pnfs_layout_type *layoutid,
+				      struct pnfs_layoutcommit_arg *args,
+				      int status);
 	void (*encode_layoutreturn) (struct pnfs_layout_type *layoutid,
 				struct xdr_stream *xdr,
 				const struct nfs4_pnfs_layoutreturn_arg *args);
-- 
1.6.6

