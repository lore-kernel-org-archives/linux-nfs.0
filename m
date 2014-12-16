Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f178.google.com ([209.85.192.178]:37354 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751265AbaLPTCu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Dec 2014 14:02:50 -0500
Received: by mail-pd0-f178.google.com with SMTP id r10so14346803pdi.23
        for <linux-nfs@vger.kernel.org>; Tue, 16 Dec 2014 11:02:50 -0800 (PST)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <Trond.Myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH 25/50] nfs41: add a helper to mark layout for return
Date: Tue, 16 Dec 2014 11:01:28 -0800
Message-Id: <1418756513-95187-26-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1418756513-95187-1-git-send-email-loghyr@primarydata.com>
References: <1418756513-95187-1-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Peng Tao <tao.peng@primarydata.com>

It marks all matching layout segments as NFS_LSEG_LAYOUTRETURN,
which is an indicator for pnfs_put_lseg() to send layoutreturn,
and also prevents pnfs_update_layout() from using the returning
segments. Once it is set, it never gets cleared.

It also sets proper io failure bit so that pnfs path can be retried
after PNFS_LAYOUTGET_RETRY_TIMEOUT second.

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
Signed-off-by: Tom Haynes <Thomas.Haynes@primarydata.com>
---
 fs/nfs/pnfs.c | 55 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/pnfs.h |  4 ++++
 2 files changed, 59 insertions(+)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 1b97209..0bd149b 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1479,6 +1479,61 @@ out_forget_reply:
 	goto out;
 }
 
+static void
+pnfs_mark_matching_lsegs_return(struct pnfs_layout_hdr *lo,
+				struct list_head *tmp_list,
+				struct pnfs_layout_range *return_range)
+{
+	struct pnfs_layout_segment *lseg, *next;
+
+	dprintk("%s:Begin lo %p\n", __func__, lo);
+
+	if (list_empty(&lo->plh_segs))
+		return;
+
+	list_for_each_entry_safe(lseg, next, &lo->plh_segs, pls_list)
+		if (should_free_lseg(&lseg->pls_range, return_range)) {
+			dprintk("%s: marking lseg %p iomode %d "
+				"offset %llu length %llu\n", __func__,
+				lseg, lseg->pls_range.iomode,
+				lseg->pls_range.offset,
+				lseg->pls_range.length);
+			set_bit(NFS_LSEG_LAYOUTRETURN, &lseg->pls_flags);
+			mark_lseg_invalid(lseg, tmp_list);
+		}
+}
+
+void pnfs_error_mark_layout_for_return(struct inode *inode,
+				       struct pnfs_layout_segment *lseg)
+{
+	struct pnfs_layout_hdr *lo = NFS_I(inode)->layout;
+	int iomode = pnfs_iomode_to_fail_bit(lseg->pls_range.iomode);
+	struct pnfs_layout_range range = {
+		.iomode = lseg->pls_range.iomode,
+		.offset = 0,
+		.length = NFS4_MAX_UINT64,
+	};
+	LIST_HEAD(free_me);
+
+	spin_lock(&inode->i_lock);
+	/* set failure bit so that pnfs path will be retried later */
+	pnfs_layout_set_fail_bit(lo, iomode);
+	set_bit(NFS_LAYOUT_RETURN, &lo->plh_flags);
+	if (lo->plh_return_iomode == 0)
+		lo->plh_return_iomode = range.iomode;
+	else if (lo->plh_return_iomode != range.iomode)
+		lo->plh_return_iomode = IOMODE_ANY;
+	/*
+	 * mark all matching lsegs so that we are sure to have no live
+	 * segments at hand when sending layoutreturn. See pnfs_put_lseg()
+	 * for how it works.
+	 */
+	pnfs_mark_matching_lsegs_return(lo, &free_me, &range);
+	spin_unlock(&inode->i_lock);
+	pnfs_free_lseg_list(&free_me);
+}
+EXPORT_SYMBOL_GPL(pnfs_error_mark_layout_for_return);
+
 void
 pnfs_generic_pg_init_read(struct nfs_pageio_descriptor *pgio, struct nfs_page *req)
 {
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 6594429..3ce292e 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -38,6 +38,7 @@ enum {
 	NFS_LSEG_VALID = 0,	/* cleared when lseg is recalled/returned */
 	NFS_LSEG_ROC,		/* roc bit received from server */
 	NFS_LSEG_LAYOUTCOMMIT,	/* layoutcommit bit set for layoutcommit */
+	NFS_LSEG_LAYOUTRETURN,	/* layoutreturn bit set for layoutreturn */
 };
 
 /* Individual ip address */
@@ -184,6 +185,7 @@ struct pnfs_layout_hdr {
 	u32			plh_barrier; /* ignore lower seqids */
 	unsigned long		plh_retry_timestamp;
 	unsigned long		plh_flags;
+	enum pnfs_iomode	plh_return_iomode;
 	loff_t			plh_lwb; /* last write byte for layoutcommit */
 	struct rpc_cred		*plh_lc_cred; /* layoutcommit cred */
 	struct inode		*plh_inode;
@@ -274,6 +276,8 @@ void nfs4_deviceid_mark_client_invalid(struct nfs_client *clp);
 int pnfs_read_done_resend_to_mds(struct nfs_pgio_header *);
 int pnfs_write_done_resend_to_mds(struct nfs_pgio_header *);
 struct nfs4_threshold *pnfs_mdsthreshold_alloc(void);
+void pnfs_error_mark_layout_for_return(struct inode *inode,
+				       struct pnfs_layout_segment *lseg);
 
 /* nfs4_deviceid_flags */
 enum {
-- 
1.9.3

