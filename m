From: andros@netapp.com
Subject: [PATCH 7/7] pnfs-post-submit: restore setup_layoutcommit
Date: Thu, 17 Jun 2010 15:34:56 -0400
Message-ID: <1276803296-9438-8-git-send-email-andros@netapp.com>
References: <1276803296-9438-1-git-send-email-andros@netapp.com>
 <1276803296-9438-2-git-send-email-andros@netapp.com>
 <1276803296-9438-3-git-send-email-andros@netapp.com>
 <1276803296-9438-4-git-send-email-andros@netapp.com>
 <1276803296-9438-5-git-send-email-andros@netapp.com>
 <1276803296-9438-6-git-send-email-andros@netapp.com>
 <1276803296-9438-7-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.212.112.111]:56799 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760532Ab0FQTfc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Jun 2010 15:35:32 -0400
In-Reply-To: <1276803296-9438-7-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/pnfs.c             |    5 +++++
 include/linux/nfs4_pnfs.h |    3 +++
 2 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index cdadddd..035cdde 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1599,6 +1599,11 @@ pnfs_layoutcommit_setup(struct inode *inode,
 	data->args.bitmask = nfss->attr_bitmask;
 	data->res.server = nfss;
 
+	/* Call layout driver to set the arguments */
+	if (nfss->pnfs_curr_ld->ld_io_ops->setup_layoutcommit)
+		result = nfss->pnfs_curr_ld->ld_io_ops->setup_layoutcommit(
+				&NFS_I(inode)->layout, &data->args);
+
 	dprintk("<-- %s Status %d\n", __func__, result);
 	return result;
 }
diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
index 3ff1dc3..3a150b1 100644
--- a/include/linux/nfs4_pnfs.h
+++ b/include/linux/nfs4_pnfs.h
@@ -154,6 +154,9 @@ struct layoutdriver_io_operations {
 	struct pnfs_layout_segment * (*alloc_lseg) (struct pnfs_layout_type *layoutid, struct nfs4_pnfs_layoutget_res *lgr);
 	void (*free_lseg) (struct pnfs_layout_segment *lseg);
 
+	int (*setup_layoutcommit) (struct pnfs_layout_type *layoutid,
+				struct pnfs_layoutcommit_arg *args);
+
 	void (*encode_layoutcommit) (struct pnfs_layout_type *layoutid,
 				struct xdr_stream *xdr,
 				const struct pnfs_layoutcommit_arg *args);
-- 
1.6.6

